--专题稽核: 未与宽带或固话合户, 但办理后付费的清单

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as
select distinct to_char(a.completed_date,'yyyy-mm-dd') 竣工日期, a.acc_nbr,a.user_name 用户姓名, a.serv_num 到达标志, a.resource_instance_code 串码, a.serv_id, a.remove_date, a.mkt_cust_code
--, cust.cust_created_date 合同号建立时间
--, cust.user_ad_arrive_num+cust.user_postn_arrive_num AD加固话数量
--,sum(case when mkt_cust.product_id in (102030001, 101010001) then 1 else 0 end) adsl_pstn_count
, a.billing_mode_id 付费模式
, a.serv_state
--a.serv_id, a.product_id, a.mkt_cust_code, a.completed_date,b.offer_comp_id, b.offer_comp_instance_id,
--b.prod_offer_inst_id, b.prod_offer_id, prod_offer_inst_created_date
--, a.down_velocity, a.com_grid_id
, mkt.mkt_channel_name, mkt.mkt_grid_name --, a.mkt_cust_code
--, com.com_channel_name, com.com_grid_name --, a.mkt_cust_code
 from ds_chn_prd_serv_AREA_LAST_DAY a 
--left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='00A'
--left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
left join DIM_ZONE_area mkt on a.mkt_grid_id=mkt.mkt_grid_id 
--left join DS_CHN_PRD_CUST_AREA_LAST_DAY cust on a.mkt_cust_code=cust.mkt_cust_code
--left join ds_chn_prd_serv_AREA_LAST_DAY mkt_cust on a.mkt_cust_code=mkt_cust.mkt_cust_code and mkt_cust.serv_num=1
where a.product_id in (
	--'102030001',
	'208511296')
--#and completed_date between '2012-09-20 00:00:00' and '2012-10-31 23:59:59'
and a.serv_num=1
and a.completed_date >= '2012-10-26 00:00:00'	-- and '2012-10-31 23:59:59'
--and serv_num = 1
--distributed by (a.acc_nbr)
;

-- 营销客户日表没有更新了,现在要取同合同号下的宽带和固话数量只有通过用户表重新统计

drop table if exists tmp_tgm_jh_sg;
create temp table tmp_tgm_jh_sg as 
select a.*, sum(case when mkt_cust.product_id in (102030001, 101010001) then 1 else 0 end) adsl_pstn_count 
from  tmp_PACKGE_NAME_AREA_FEEMONTH a
left join ds_chn_prd_serv_AREA_LAST_DAY mkt_cust on a.mkt_cust_code=mkt_cust.mkt_cust_code and mkt_cust.serv_num=1
group by a.*
;

drop table  tmp_PACKGE_NAME_AREA_FEEMONTH;
create table  tmp_PACKGE_NAME_AREA_FEEMONTH  as 
	select * from tmp_tgm_jg_sg;
-- 建立优惠相关的临时表

drop table if exists tmp_offer2 ;
create temp table tmp_offer2 as 
select distinct a.*
from tmp_PACKGE_NAME_AREA_FEEMONTH a
;


--还有加上新装的受理员工工号,以便区分代理商

-- 取系统探测机型,先建临时表取得最大值
drop table if exists tmp_ry1;
create temp table tmp_ry1 as 
select distinct acc_nbr, max(register_time) register_time from ds_evt_terminal_info_all_ry where acc_nbr in (select distinct acc_nbr from tmp_offer2) group by acc_nbr;
drop table if exists tmp_ry;
create temp table tmp_ry as select distinct b.* from tmp_ry1 a left join ds_evt_terminal_info_all_ry b on a.acc_nbr=b.acc_nbr and a.register_time=b.register_time;

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH AS select distinct aa.*
,d.ORG_NAME 受理部门,b.STAFF_DESC 受理员工,b.staff_code 受理工号,a.ACCEPT_MODE 受理方式
--,c.service_offer_name 受理类型
,a.HANDLE_TIME 受理时间
,a.staff_id
--,a.FINISH_TIME 竣工时间,a.PRE_HANDLE_FLAG 是否预受理,a.CUST_ORDER_ID 客户订单标识,
--a.ORDER_ITEM_ID 订单项标识,a.UNDO_FLAG 撤单标识,
--a.ORDER_ITEM_OBJ_ID 订单项业务对象标识,a.OFFER_KIND 销售品类型,a.ASK_SOURCE 受理来源
, ry.esn, ry.type
from tmp_offer2 aa
left join tmp_ry ry on aa.acc_nbr=ry.acc_nbr --探测机型
left join DS_PRD_OFFER_COMP_DETAIL comp on aa.serv_id=comp.serv_id and prod_offer_inst_detail_state='001' and prod_offer_class_id='10'
--left join DM_EVT_l_ORDER_ITEM a on aa.acc_nbr=a.acc_nbr and a.HANDLE_TIME>='2012-06-22 00:00:00'   and service_offer_id=1  
left join DM_EVT_l_ORDER_ITEM a on a.ORDER_ITEM_OBJ_ID=comp.PROD_OFFER_INST_ID and a.HANDLE_TIME>='2012-06-22 00:00:00'   and a.service_offer_id=1  
and a.order_item_obj_type_id in ('318775','313812')
--受理时间, 订购
--left join dim_crm_staff b on a.staff_id=b.party_role_id
left join  dwd_s_crm_staff b on a.staff_id=b.staff_id  --应该用2.0的配置表
left join dwd_s_crm_service_offer c on a.service_offer_id=c.service_offer_id
-- and c.service_offer_name='订购'
left join dim_crm_organization d on a.channel_id=d.party_id

and a.HANDLE_TIME>='2012-06-01 00:00:00'  --受理时间
distributed by (acc_nbr)
;
-- 删除无线宽带号码,只保留语音CDMA
--delete from tmp_PACKGE_NAME_AREA_FEEMONTH where 基础包 like '%%无线宽带%%';

-- 部分工号没有配置姓名
update tmp_PACKGE_NAME_AREA_FEEMONTH set 受理部门='龙河烽火',受理员工='龙河烽火', 受理工号='FDFHLH1' where staff_id= 300001026;
update tmp_PACKGE_NAME_AREA_FEEMONTH set 受理部门='丰都中心营业厅',受理员工='杨秀梅', 受理工号='FDCQYYTYXM' where staff_id= 300000267 ; 

--select * from ST_MKT_MBL_FESTIVAL_DETAIL_DM  where area_name like '沙坪坝'  and handle_time <'2012-09-25 00:00:00' and handle_time>='2012-09-24 00:00:00' ;
select '33';

