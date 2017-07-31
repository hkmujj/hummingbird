/*一、全部替换DS_CHN_PRD_SERV_AREA_201108为DS_CHN_PRD_SERV_AREA_FEEMONTH
二、全部替换DS_CHN_PRD_OFFER_COMP_201108为DS_CHN_PRD_OFFER_COMP_FEEMONTH
二、全部替换DS_ACT_ACCT_ITEM_201108为DS_ACT_ACCT_ITEM_FEEMONTH
*/
--本脚本的执行时间大约为21秒.
--执行开始
--PPT2
--drop table if exists csttl;
create temporary table csttl as
select distinct a.serv_id,c.offer_comp_instance_id,b.type_name,e.OFFER_COMP_TYPE_DESC1 offerd,OFFER_COMP_TYPE_DESC4,OFFER_COMP_TYPE_DESC6
from 
DS_CHN_PRD_SERV_AREA_FEEMONTH a,--此处改用户表帐期
DIM_PRODUCT b,DS_CHN_PRD_OFFER_COMP_FEEMONTH c,--此处改套餐分析表帐期
DIM_CRM_PRODUCT_OFFER d,DIM_WD_OFFER_NEW_DIR_SECOND e 
where 
a.product_id=b.product_id 
and 
b.type_name in ('注册拨号类','普通电话','移动业务','视讯应用产品') 
and 
a.state='00A' 
and
a.SERV_NUM='1'
and 
a.serv_id=c.serv_id
and 
c.COMP_OFFER_ID=d.offer_id
and 
d.offer_name=OFFER_COMP_TYPE_DESC6
and 
c.OFFER_EXP_DATE>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH'))))
and 
d.offer_kind='C';--此处改方案失效时间，为分析帐期次月初
--执行结束

--执行开始
--PPT2：融合套餐中，各种四级产品分类计数，及该类四级产品总个数
--drop table if exists cstt2;
create temporary table cstt2 as
select distinct type_name,count(type_name) tn from 
csttl where offer_comp_instance_id in 
(
select offer_comp_instance_id from
(select distinct offer_comp_instance_id,count(distinct serv_id) sd from csttl group by 1) a where sd>1
) group by 1;
--drop table if exists cstt22;
create temporary table cstt22 as
select distinct b.type_name,count(distinct a.serv_id) sd2  
from 
DS_CHN_PRD_SERV_AREA_FEEMONTH a,DIM_PRODUCT b
where 
a.state='00A' 
and
a.SERV_NUM='1'
and 
a.product_id=b.product_id
and 
b.type_name in ('注册拨号类','普通电话','移动业务','视讯应用产品') group by 1;
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct a.type_name 四级产品名,a.tn 融合套餐下设备个数,b.sd2 总设备个数 from cstt2 a,cstt22 b where a.type_name=b.type_name;
--执行结束，取结果粘贴到EXCEL表

select * from tmp_PACKGE_NAME_AREA_FEEMONTH limit 10;
