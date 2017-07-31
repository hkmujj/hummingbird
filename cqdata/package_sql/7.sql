--按新套餐签转
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH; 
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct OFFER_COMP_TYPE_DESC6b 新套餐,OFFER_COMP_TYPE_DESC6 旧套餐,count(distinct SERV_ID) 计数 from 
(
select distinct a.*,b.OFFER_COMP_TYPE_DESC4 OFFER_COMP_TYPE_DESC4b,b.OFFER_COMP_TYPE_DESC6 OFFER_COMP_TYPE_DESC6b from 
(
select distinct b.OFFER_COMP_TYPE_DESC4,b.OFFER_COMP_TYPE_DESC6,a.SERV_ID,a.product_name 
from 
tmp_jg_AREA_FEEMONTH a,DIM_WD_OFFER_NEW_DIR_SECOND b,DIM_CRM_PRODUCT_OFFER c
where 
a.offer_comp_id=b.OFFER_COMP_TYPE_ID6
and 
a.offer_comp_id=c.offer_id
and 
c.offer_kind='C'
and 
a.service_offer_name='注销'
and 
a.completed_date>=(Values ((SELECT date_trunc('month', timestamp 'FEEMONTH01')) - interval '1 month'))
and 
a.completed_date<(Values ((SELECT date_trunc('month', timestamp 'FEEMONTH01'))))
) a,
(
select distinct b.OFFER_COMP_TYPE_DESC4,b.OFFER_COMP_TYPE_DESC6,a.SERV_ID,a.product_name  
from 
tmp_jg_AREA_FEEMONTH a,DIM_WD_OFFER_NEW_DIR_SECOND b,DIM_CRM_PRODUCT_OFFER c
where 
a.offer_comp_id=b.OFFER_COMP_TYPE_ID6
and 
a.offer_comp_id=c.offer_id
and 
c.offer_kind='C'
and 
a.service_offer_name='售卖'
and 
a.completed_date>=(Values ((SELECT date_trunc('month', timestamp 'FEEMONTH01')) - interval '1 month'))
and 
a.completed_date<(Values ((SELECT date_trunc('month', timestamp 'FEEMONTH01'))))
) b
where a.SERV_ID=b.SERV_ID
) a group by 1,2 order by 3 desc limit 10;
select * from tmp_PACKGE_NAME_AREA_FEEMONTH;
