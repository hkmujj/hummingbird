-- 提裸手机清单
-- 未做基础优惠, 可能按标准资费出费的商品

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
-- 提裸资费手机
drop table if exists tmp_tgm1;
create temp table tmp_tgm1 as 
select a.acc_nbr, b.offer_comp_id
, a.serv_id, a.serv_state, a.state, a.serv_num
,a.remove_flag, a.remove_date
, t3.offer_id,t3.offer_name
,d.offer_comp_type_id6
 from ds_chn_prd_serv_mkt_AREA_LAST_DAY a 
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='001'
left join dim_crm_product_offer t3 on b.prod_offer_id=t3.offer_id 
left join DIM_WD_OFFER_NEW_DIR_SECOND d on b.offer_comp_id=d.offer_comp_type_id6 
and d.base_flag=1 

where a.product_id=208511296 
--and a.offln_flg=0 
and a.remove_flag<>'T'
--and t3.offer_id is not null
--and b.serv_id is null
--and d.offer_comp_type_id6 is null
--limit 1000
;
drop table  if exists tgm_elong5_2;
create temp table tgm_elong5_2 as select distinct acc_nbr from tmp_tgm1 where offer_comp_type_id6 is not null
or offer_id in ('315452' --	上网CDMA
,'315934' --	e6-11新手机26元套餐（24个月）
,'316089'
,'316090'
,'316091'
,'316373'
,'316374'
,'316378'
,'316385'
,'316849'
,'1605045'
,'1605043'
,'412189'
,'412203'
,'1605046'
,'322890'
)
;
create table tmp_PACKGE_NAME_AREA_FEEMONTH AS 
select a.acc_nbr
,a.serv_id, a.state, a.serv_state, a.serv_num
from tmp_tgm1 a left join tgm_elong5_2 b on a.acc_nbr =b.acc_nbr 
where b.acc_nbr is null
order by 1
;

drop table if exists tmp_accept_xxy;
create temp table tmp_accept_xxy as 
select * from dm_evt_sr_accept where serv_id in (select serv_id from tmp_elong5_AREA_FEEMONTH);

create temp table tmp_result as 
select a.acc_nbr
, a.state, a.serv_state, a.serv_num 
--,a.serv_id
, b.atime
--, b.offer_id, b.service_id, oper_id
, cust_name
,accept_id
,service.service_offer_name
,staff.staff_code, staff_desc
 from (select distinct serv_id,acc_nbr,serv_state, state, serv_num from  tmp_elong5_AREA_FEEMONTH )
 A
left join 
(select * from tmp_accept_xxy where accept_id in 
(select accept_id from 
(
select serv_id, max(accept_id) accept_id from tmp_accept_xxy
group by 1
) max_accept_id
)
) b on a.serv_id=b.serv_id
left join DIM_CRM_SERVICE_OFFER service on service_id=service.service_offer_id
left join DIM_CRM_STAFF staff on oper_id=staff.party_role_id
where b.serv_id is not null and service.service_offer_name<>'拆机'
;

drop table tmp_elong5_AREA_FEEMONTH;
create table tmp_elong5_AREA_FEEMONTH as select * from tmp_result;

select '33';
--* from tmp_g2_33_201110;
