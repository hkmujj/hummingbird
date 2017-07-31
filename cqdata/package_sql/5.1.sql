--公众客户热卖套餐个数改资费和新增设备分布率;

--执行开
--drop table if exists csttq;--drop table if exists csttl;
create temporary table csttq as
select distinct b.OFFER_COMP_TYPE_DESC6,c.offer_comp_instance_id,a.product_name,a.serv_id,'新增' bq
from 
tmp_jg_AREA_FEEMONTH a,--竣工表，参见之前脚本里面的竣工清单。
DIM_WD_OFFER_NEW_DIR_SECOND b,
DS_CHN_PRD_OFFER_COMP_FEEMONTH c, --套餐月表，改账期
DIM_CRM_PRODUCT_OFFER d
where 
a.serv_id=c.serv_id 
and 
a.service_offer_name='售卖'
and 
a.offer_comp_name=b.OFFER_COMP_TYPE_DESC6
and 
c.OFFER_EXP_DATE>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01'))))
and 
a.offer_comp_id=c.COMP_OFFER_ID
and 
a.completed_date>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01')) - interval '1 month'))
and 
a.completed_date<(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01'))))
and 
a.serv_id in 
(
select serv_id from tmp_jg_AREA_FEEMONTH --竣工表，参见之前脚本里面的竣工清单。
where 
completed_date>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01')) - interval '1 month'))
and 
completed_date<(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01'))))
and
service_offer_name='售卖'
)
and 
c.COMP_OFFER_ID=d.offer_id
and 
d.offer_kind='C';
--drop table if exists csttw;
create temporary table csttw as
select distinct b.OFFER_COMP_TYPE_DESC6,c.offer_comp_instance_id,a.product_name,a.serv_id,'改资费' bq
from 
tmp_jg_AREA_FEEMONTH a,--竣工表，参见之前脚本里面的竣工清单。
DIM_WD_OFFER_NEW_DIR_SECOND b,
DS_CHN_PRD_OFFER_COMP_FEEMONTH c, --套餐月表，改账期
DIM_CRM_PRODUCT_OFFER d
where 
a.serv_id=c.serv_id 
and 
a.service_offer_name='售卖'
and 
a.offer_comp_name=b.OFFER_COMP_TYPE_DESC6
and 
c.OFFER_EXP_DATE>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01'))))
and 
a.offer_comp_id=c.COMP_OFFER_ID
and 
a.completed_date>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01')) - interval '1 month'))
and 
a.completed_date<(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01')))) 
and 
a.serv_id not in 
(
select serv_id from tmp_jg_AREA_FEEMONTH --竣工表，参见之前脚本里面的竣工清单。
where 
completed_date>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01')) - interval '1 month'))
and 
completed_date<(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01')))) 
and
service_offer_name='新装'
)
and 
c.comp_offer_id=d.offer_id
and 
d.offer_kind='C'
;

--drop table if exists cstte;
create temporary table cstte as
select * from csttq;
insert into cstte select * from csttw;
--drop table if exists cstte1;
create temporary table cstte1 as
select distinct OFFER_COMP_TYPE_DESC6,offer_comp_instance_id,bq,
max(case when product_name like '%%电话%%' then serv_id else null end) as gh,
max(case when product_name like '%%注册虚拨上网%%' then serv_id else null end) as kd,
max(case when product_name like '%%语音CDMA%%' then serv_id else null end) as sj
from 
cstte 
group by 1,2,3
order by 2,1;

--每月新增套餐按设备类型和入网改资费分析结果。
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct a.OFFER_COMP_TYPE_DESC6 六级套餐,a.oid 商品包个数,b.新增固话,b.新增宽带,b.新增CDMA,b.改资费固话,b.改资费宽带,b.改资费CDMA from 
(select distinct OFFER_COMP_TYPE_DESC6,count(distinct offer_comp_instance_id) oid from cstte1 group by 1) a,
(select distinct a.OFFER_COMP_TYPE_DESC6,sum(a.gh) 新增固话,sum(a.kd) 新增宽带,sum(a.sj) 新增CDMA,sum(b.gh1) 改资费固话,sum(b.kd1) 改资费宽带,sum(b.sj1) 改资费CDMA from
(select OFFER_COMP_TYPE_DESC6,count(distinct gh) gh,count(distinct kd) kd,count(distinct sj) sj from cstte1 where bq='新增' group by 1) a,
(select OFFER_COMP_TYPE_DESC6,count(distinct gh) gh1,count(distinct kd) kd1,count(distinct sj) sj1 from cstte1 where bq='改资费' group by 1) b
where a.OFFER_COMP_TYPE_DESC6=b.OFFER_COMP_TYPE_DESC6 group by 1) b
where 
a.OFFER_COMP_TYPE_DESC6=b.OFFER_COMP_TYPE_DESC6
order by 2 desc
;
select * from tmp_PACKGE_NAME_AREA_FEEMONTH limit 20;
--执行结束
