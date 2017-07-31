-- 丰都新增手机清单--翼龙部分,专题
--此处不再算积分

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct a.*
--,inst.acc_nbr adsl_new
--,b.offer_comp_id, prod_offer_id 
,c.offer_name
--, c_prod.offer_name prod_name
--,0.0 score
,phone.enable_flag, phone.intell_flag
--, user_postn_arrive_num
--,term.imei, term.factory, term.type
from 
(
select distinct a.*, b.offer_comp_id, 
--,to_char(b.OFFER_COMPLETED_DATE,'YYYY-MM-DD') 套餐竣工时间,
--to_char(b.offer_eff_date,'YYYY-MM-DD') 套餐生效时间
to_char(prod_offer_inst_created_date, 'YYYY-MM-DD') 销售品实例创建时间
--prod_offer_inst_created_date 销售品实例创建时间
, offer_comp_instance_id
--, b.prod_offer_id
from      (
select acc_nbr, user_name, a.com_grid_id
--, jjx_code, user_grp_type
--, down_velocity
,  completed_date
--, remove_date
, serv_id 
, com.com_channel_name, com.com_grid_name, a.mkt_cust_code
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  
--serv_num=1 and 	--注释此句,以便把欠费的包含进来
serv_state='2HA' and state='001' and 
product_id=208511296
--and completed_date >='2012-01-01'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state='001'
 where  b.offer_comp_id in ( 
331961,331962,331964,331965,331966,331967,331968,331969
,	331963 --天翼领航90元翼龙语音包
,331444
,331956
,331949 --天翼领航翼龙手机套餐39档次, 基础档次反面不能表明套餐包档次
,331973
,331976 --翼龙套餐手机加装包
,332929 --新天翼领航20元翼龙语音包 
,332122	,
331971	,
332931	,
331956	,
331969	,
332960	,
332442	,
331967	,
332174	,
331965	,
332936	,
332964	,
331973	,
332929	,
331961	,
332933	,
332966	,
332119	,
331963

 )
   ) a
left join dim_crm_product_offer c on a.offer_comp_id=c.offer_id 
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
