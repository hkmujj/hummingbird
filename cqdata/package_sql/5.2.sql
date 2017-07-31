--执行开始
--公众客户流失套餐;
--drop table if exists csttl;
create temporary table csttl as
select distinct b.OFFER_COMP_TYPE_DESC6,count(distinct c.offer_comp_instance_id) oid
from 
tmp_jg_AREA_FEEMONTH a,--竣工表，参见之前脚本里面的竣工清单。
DIM_WD_OFFER_NEW_DIR_SECOND b,
DS_CHN_PRD_OFFER_COMP_FEEMONTH c, --套餐月表，改账期
DIM_CRM_PRODUCT_OFFER d
where 
a.serv_id=c.serv_id 
and 
a.service_offer_name='注销'
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
c.comp_offer_id=d.offer_id
and 
d.offer_kind='C'
group by 1
;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct OFFER_COMP_TYPE_DESC6 套餐六级名称,oid 商品包个数 from csttl order by 2 desc limit 50;
select * from tmp_PACKGE_NAME_AREA_FEEMONTH;
--执行结束

