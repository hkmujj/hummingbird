-- 天翼龙卡清单

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct a.*
,c.offer_name
,phone.enable_flag, phone.intell_flag
from 
(
select distinct a.*, b.comp_offer_id
,to_char(b.OFFER_COMPLETED_DATE,'YYYY-MM-DD') 套餐竣工时间,
to_char(b.offer_eff_date,'YYYY-MM-DD') 套餐生效时间
, offer_comp_instance_id
from      (
select acc_nbr, user_name, a.com_grid_id
,  completed_date
, serv_id 
, com.com_channel_name 维护营维部, com.com_grid_name 维护网格, a.mkt_cust_code

from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  serv_num=1 and product_id=208511296) a
left join DS_CHN_PRD_OFFER_COMP_LAST_DAY
--ds_prd_offer_comp_detail 
b on a.serv_id=b.serv_id 
--and b.prod_offer_inst_state='001'
 where  b.comp_offer_id in ( 
319557 --天翼龙卡
,332028 )
   ) a
left join dim_crm_product_offer c on a.comp_offer_id=c.offer_id 
--left join dim_crm_product_offer c_prod on a.prod_offer_id=c_prod.offer_id 
--order by a.acc_nbr
--distribute by acc_nbr
--关联3G智能机表以取得3G和智能机标识
left join DS_PRD_SERV_3G_LAST_DAY phone on a.serv_id=phone.serv_id
;
--重新通过建临时表来查询该手机的最新串码信息
create temp table temp1 as 
select a.*, term.* from tmp_PACKGE_NAME_AREA_FEEMONTH a
left join 

(select a.acc_nbr ter_acc, b.type, b.esn from 
(select acc_nbr , max(register_time) reg from ds_evt_terminal_info_all_ry term where acc_nbr in (select acc_nbr from tmp_PACKGE_NAME_AREA_FEEMONTH) group by 1) a left join ds_evt_terminal_info_all_ry b on a.acc_nbr=b.acc_nbr and a.reg=b.register_time )
 term 
on a.acc_nbr=term.ter_acc
;
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select * from temp1;
drop table temp1;
select '33';
--* from tmp_g2_33_201110;

