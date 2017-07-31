
--从这里开始执行。注意，这个表是静态表。 表名必须修改，否则，其他分公司工号无法操作csjg这个表。--表名请自行修改，格式为xx_PACKGE_NAME，注意，更改表名要用全部替换，并且记住表名，其他脚本会用到竣工表。
--需要修改的主要是用户表，和套餐分析表后面会标注。
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;        
create table tmp_PACKGE_NAME_AREA_FEEMONTH  --此表是分析账期当月的所有竣工工单信息。建议导出备份本地。
(
ORG_NAME    varchar(60),     --受理部门
STAFF_DESC    varchar(60),   --受理员工
ATIME        TIMESTAMP,  --受理时间
COMPLETED_DATE  TIMESTAMP,    --受理竣工时间
UNDO_FLAG    CHARACTER(1),    --撤单标识
ACCEPT_STATE   VARCHAR(300),    --竣工标识
ACCEPT_ID   VARCHAR(20),       --受理编码
ORDER_ID    VARCHAR(20),       --订单编码
SERVICE_OFFER_NAME   varchar(60),     --受理类型
offer_id      varchar(60),        --商品编码
offer_comp_id    varchar(60),      --商品包编码
offer_name   varchar(60),         --商品名称
offer_comp_name   varchar(60),    --商品包名称
eff    TIMESTAMP,          --商品生效时间
exp    TIMESTAMP,          --商品失效时间
com  TIMESTAMP,           --号码竣工时间
rem  TIMESTAMP,           --号码失效时间
serv_id   decimal(16,0),   --设备ID
mkt_cust_code    varchar(30),  --合同号
cust_id    varchar(30),     --客户ID
acc_nbr   varchar(20),     --产品号码
product_name   varchar(60),     --产品四级名称
comments   varchar(250)     --备注信息
)
DISTRIBUTED BY (ACCEPT_ID);
insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select distinct a.ORG_NAME,a.STAFF_DESC,a.ATIME,a.COMPLETED_DATE,a.UNDO_FLAG,a.lov_name,a.ACCEPT_ID,a.ORDER_ID,a.SERVICE_OFFER_NAME,
a.offer_id,a.offer_comp_id,a.offer_name,a.offer_comp_name,a.eff,a.exp,a.com,a.rem,a.serv_id,a.mkt_cust_code,a.cust_id,a.acc_nbr,b.product_comments,a.comments
from 
(
select distinct 
a.ORG_NAME,a.STAFF_DESC,a.ATIME,a.COMPLETED_DATE,a.UNDO_FLAG,a.lov_name,a.ACCEPT_ID,a.ORDER_ID,a.SERVICE_OFFER_NAME,
a.offer_id,a.offer_comp_id,a.offer_name,a.offer_comp_name,b.acc_nbr,b.serv_id,b.mkt_cust_code,b.cust_id,b.comments,c.PROD_OFFER_INST_EFF_DATE eff,c.PROD_OFFER_INST_exp_DATE exp,b.product_id,b.completed_date com,b.remove_date rem from 
(
select distinct 
a.ORG_NAME,a.STAFF_DESC,a.ATIME,a.product_offer_instance_id,a.COMPLETED_DATE,a.UNDO_FLAG,a.lov_name,a.ACCEPT_ID,a.ORDER_ID,a.SERVICE_OFFER_NAME,
a.offer_id,a.offer_comp_id,a.offer_name,b.offer_name offer_comp_name from  
(
select distinct 
a.ORG_NAME,a.STAFF_DESC,a.ATIME,a.product_offer_instance_id,a.COMPLETED_DATE,a.UNDO_FLAG,a.lov_name,a.ACCEPT_ID,a.ORDER_ID,a.SERVICE_OFFER_NAME,
a.offer_id,a.offer_comp_id,b.offer_name from 
(
select distinct 
d.ORG_NAME,b.STAFF_DESC,a.ATIME,a.product_offer_instance_id,a.COMPLETED_DATE,a.UNDO_FLAG,f.lov_name,a.ACCEPT_ID,a.ORDER_ID,c.SERVICE_OFFER_NAME,
a.offer_id,a.offer_comp_id
from 
DM_EVT_SR_ACCEPT a,DIM_CRM_STAFF b,DIM_CRM_SERVICE_OFFER c,DIM_CRM_ORGANIZATION d,DIM_CRM_PRODUCT e,DIM_LOV_CONFIG f
where 
c.service_offer_id=a.SERVICE_ID 
and a.oper_id=b.PARTY_ROLE_ID  
and a.DEAL_EXCH_ID='AREA_ID'                   --此处是分公司代码，请自行修改为本分公司代码--查询方法 select distinct DEAL_EXCH_ID,count(distinct serv_id) s from DS_CHN_PRD_SERV_AREA_FEEMONTH group by 1 order by 2 desc limit 1。
and a.DEPART_ID=d.PARTY_ID      
and a.completed_date>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01')) - interval '1 month')) --此处是竣工时间，大于分析账期当月月初零点，此处已经用函数替代，无需修改
and a.completed_date<(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01'))))  --此处是竣工时间，小于分析账期次月月初零点，此处已经用函数替代，无需修改
and a.product_id=e.PRODUCT_id   
and a.ACCEPT_STATE=f.lov_code  
and f.table_name='DM_EVT_SR_ACCEPT'  
and f.COLUMN_NAME='ACCEPT_STATE'           --如果觉得全量工单查询慢，在此处增加:and service_id in ('20000','22000')
) a left join DIM_CRM_PRODUCT_OFFER b on a.offer_id=b.offer_id
) a left join DIM_CRM_PRODUCT_OFFER b on a.offer_comp_id=b.offer_id
) a,DS_CHN_PRD_SERV_AREA_FEEMONTH b,DS_PRD_OFFER_COMP_DETAIL c --此处自行设置DS_CHN_PRD_SERV用户信息表的日期，分析当月账期
where 
a.product_offer_instance_id=c.prod_offer_inst_id   
and 
b.serv_id=c.serv_id    
) a,DIM_CRM_PRODUCT b 
where 
a.product_id=b.product_id;  --替换产品名称
create temporary table cst1 as   --这里开始是取销售品实例表无法取到的受理套餐记录，以前销售品实例表有问题，有小部分套餐在实例表中取不到，只有在套餐分析表中取。
select distinct 
a.ORG_NAME,a.STAFF_DESC,a.ATIME,a.product_offer_instance_id,a.COMPLETED_DATE,a.UNDO_FLAG,a.lov_name,a.ACCEPT_ID,a.ORDER_ID,a.SERVICE_OFFER_NAME,
a.offer_name,b.offer_name offer_comp_name from  
(
select 
a.ORG_NAME,a.STAFF_DESC,a.ATIME,a.product_offer_instance_id,a.COMPLETED_DATE,a.UNDO_FLAG,a.lov_name,a.ACCEPT_ID,a.ORDER_ID,a.SERVICE_OFFER_NAME,
a.offer_id,a.offer_comp_id,b.offer_name from 
(
select 
d.ORG_NAME,b.STAFF_DESC,a.ATIME,a.product_offer_instance_id,a.COMPLETED_DATE,a.UNDO_FLAG,f.lov_name,a.ACCEPT_ID,a.ORDER_ID,c.SERVICE_OFFER_NAME,
a.offer_id,a.offer_comp_id
from 
DM_EVT_SR_ACCEPT a,DIM_CRM_STAFF b,DIM_CRM_SERVICE_OFFER c,DIM_CRM_ORGANIZATION d,DIM_CRM_PRODUCT e,DIM_LOV_CONFIG f
where 
c.service_offer_id=a.SERVICE_ID 
and a.oper_id=b.PARTY_ROLE_ID
and a.DEAL_EXCH_ID='AREA_ID'
and a.DEPART_ID=d.PARTY_ID
and a.completed_date>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01')) - interval '1 month'))
and a.product_id=e.PRODUCT_id
and a.ACCEPT_STATE=f.lov_code
and f.table_name='DM_EVT_SR_ACCEPT'
and f.COLUMN_NAME='ACCEPT_STATE'    
) a left join DIM_CRM_PRODUCT_OFFER b on a.offer_id=b.offer_id 
) a left join DIM_CRM_PRODUCT_OFFER b on a.offer_comp_id=b.offer_id;
create temporary table cst10 as 
select distinct a.accept_id from cst1 a,tmp_PACKGE_NAME_AREA_FEEMONTH b where a.accept_id=b.accept_id;
create temporary table cst2 as
select distinct a.*,b.accept_id ac from cst1 a left join cst10 b on a.accept_id=b.accept_id; 
create temporary table cst12 as
select distinct ORG_NAME,STAFF_DESC,ATIME,product_offer_instance_id,COMPLETED_DATE,UNDO_FLAG,lov_name,ACCEPT_ID,ORDER_ID,SERVICE_OFFER_NAME,
offer_name,offer_comp_name from cst2 where ac is null;                                    
insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select a.ORG_NAME,a.STAFF_DESC,a.ATIME,a.COMPLETED_DATE,a.UNDO_FLAG,a.lov_name,a.ACCEPT_ID,a.ORDER_ID,a.SERVICE_OFFER_NAME,
a.offer_id,a.offer_comp_id,a.offer_name,a.offer_comp_name,a.eff,a.exp,a.com,a.rem,a.serv_id,a.mkt_cust_code,a.cust_id,a.acc_nbr,b.product_comments,a.comments
from 
(
select 
a.ORG_NAME,a.STAFF_DESC,a.ATIME,a.COMPLETED_DATE,a.UNDO_FLAG,a.lov_name,a.ACCEPT_ID,a.ORDER_ID,a.SERVICE_OFFER_NAME,
a.offer_id,a.offer_comp_id,a.offer_name,a.offer_comp_name,b.acc_nbr,b.serv_id,b.mkt_cust_code,b.cust_id,b.comments,c.OFFER_EFF_DATE eff,c.OFFER_exp_DATE exp,b.completed_date com,b.remove_date rem,b.product_id from 
(
select 
a.ORG_NAME,a.STAFF_DESC,a.ATIME,a.OFFER_COMP_INSTANCE_ID,a.COMPLETED_DATE,a.UNDO_FLAG,a.lov_name,a.ACCEPT_ID,a.ORDER_ID,a.SERVICE_OFFER_NAME,
a.offer_id,a.offer_comp_id,a.offer_name,b.offer_name offer_comp_name from  
(
select 
a.ORG_NAME,a.STAFF_DESC,a.ATIME,a.OFFER_COMP_INSTANCE_ID,a.COMPLETED_DATE,a.UNDO_FLAG,a.lov_name,a.ACCEPT_ID,a.ORDER_ID,a.SERVICE_OFFER_NAME,
a.offer_id,a.offer_comp_id,b.offer_name from 
(
select  
d.ORG_NAME,b.STAFF_DESC,a.ATIME,a.OFFER_COMP_INSTANCE_ID,a.COMPLETED_DATE,a.UNDO_FLAG,f.lov_name,a.ACCEPT_ID,a.ORDER_ID,c.SERVICE_OFFER_NAME,
a.offer_id,a.offer_comp_id
from 
DM_EVT_SR_ACCEPT a,DIM_CRM_STAFF b,DIM_CRM_SERVICE_OFFER c,DIM_CRM_ORGANIZATION d,DIM_CRM_PRODUCT e,DIM_LOV_CONFIG f
where 
c.service_offer_id=a.SERVICE_ID 
and a.oper_id=b.PARTY_ROLE_ID
and a.DEPART_ID=d.PARTY_ID
and a.DEAL_EXCH_ID='AREA_ID'   --此处为分公司代码
and a.completed_date>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01')) - interval '1 month')) 
and a.completed_date<(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01'))))  
and a.product_id=e.PRODUCT_id
and a.ACCEPT_STATE=f.lov_code
and f.table_name='DM_EVT_SR_ACCEPT'
and f.COLUMN_NAME='ACCEPT_STATE'   
and a.accept_id in (select accept_id from cst12)
) a left join DIM_CRM_PRODUCT_OFFER b on a.offer_id=b.offer_id 
) a left join DIM_CRM_PRODUCT_OFFER b on a.offer_comp_id=b.offer_id 
) a,DS_CHN_PRD_SERV_AREA_FEEMONTH b,ds_chn_prd_offer_comp_FEEMONTH c                 --此处两个表，分别是用户表和套餐分析表，均为月表，设置为分析当月账期
where 
a.OFFER_COMP_INSTANCE_ID=c.offer_comp_instance_id 
and 
b.serv_id=c.serv_id 
) a,DIM_CRM_PRODUCT b 
where 
a.product_id=b.product_id;
--这里结束是取销售品实例表无法取到的受理套餐记录，已经将结果添加到tmp_PACKGE_NAME_AREA_FEEMONTH

--执行开始
--处理售卖商品错误归并商品包的记录。
--drop table if exists css;
create temporary table css as
select distinct ORG_NAME,STAFF_DESC,ATIME,COMPLETED_DATE,UNDO_FLAG,ACCEPT_STATE,ACCEPT_ID,ORDER_ID,SERVICE_OFFER_NAME,
offer_id,offer_comp_id,offer_name,offer_name offer_comp_name,eff,exp,com,rem,serv_id,mkt_cust_code,cust_id,acc_nbr,product_name,comments
from 
tmp_PACKGE_NAME_AREA_FEEMONTH  
where 
offer_name in ('手机上网包5元包30M','手机上网包10元包60M','手机上网包20元包150M','手机上网包30元包300M','手机上网包50元包800M','手机上网包100元包2G','全业务可选短信包1元包15条_基础包',
'全业务可选短信包3元包50条_基础包','全业务可选短信包5元包100条_基础包','全业务可选短信包10元包200条_基础包','全业务可选短信包20元包400条_基础包','增值礼包C网通信助理3元每月','增值礼包天翼视讯5元每月','增值礼包热线手机报2元每月',
'增值礼包音乐下载5元每月','增值礼包七彩铃音5元每月','增值礼包天翼快讯2元每月','增值礼包新闻早晚报2元每月','OCS增值礼包新闻早晚报2元每月')
and service_offer_name in ('注销','售卖');
delete from tmp_PACKGE_NAME_AREA_FEEMONTH
where
offer_name in ('手机上网包5元包30M','手机上网包10元包60M','手机上网包20元包150M','手机上网包30元包300M','手机上网包50元包800M','手机上网包100元包2G','全业务可选短信包1元包15条_基础包',
'全业务可选短信包3元包50条_基础包','全业务可选短信包5元包100条_基础包','全业务可选短信包10元包200条_基础包','全业务可选短信包20元包400条_基础包','增值礼包C网通信助理3元每月','增值礼包天翼视讯5元每月','增值礼包热线手机报2元每月',
'增值礼包音乐下载5元每月','增值礼包七彩铃音5元每月','增值礼包天翼快讯2元每月','增值礼包新闻早晚报2元每月','OCS增值礼包新闻早晚报2元每月');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH
select distinct * from 
css;
--执行结束
--至此，分析账期当月所有受理信息已经在tmp_PACKGE_NAME_AREA_FEEMONTH中。包含大部分受理信息。配合收款记录，可以进行自动稽核。

select * from tmp_PACKGE_NAME_AREA_FEEMONTH limit 10;
