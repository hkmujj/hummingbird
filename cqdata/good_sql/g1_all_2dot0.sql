--月受理工单全量,不含撤单
--CRM2.0后的受理工单

drop table if exists tgm_g1_ls1;
create temp table tgm_g1_ls1 as 
select  distinct 
--region_id, 
d.ORG_NAME 受理部门,b.STAFF_DESC 受理员工,b.staff_code 受理工号
,c.service_offer_name 受理类型
,a.*
 from
 (select 
 a.ORDER_ITEM_CD 订单项类型
,a.HANDLE_TIME 受理时间,a.FINISH_TIME 竣工时间,a.PRE_HANDLE_FLAG 是否预受理
,a.CUST_ORDER_ID 客户订单标识,a.ORDER_ITEM_ID 订单项标识,a.UNDO_FLAG 撤单标识,
a.ORDER_ITEM_OBJ_ID 订单项业务对象标识,a.OFFER_KIND 销售品类型,a.ASK_SOURCE 受理来源, staff_id,service_offer_id
,a.channel_id
 from  dm_evt_order_item a where a.handle_time between '{yyyy-mm}-01' and '{next_yyyy-mm}-01'
and a.region_id in ('AREA_ID','AREA_ID_324', '301') union 
select a.ORDER_ITEM_CD 订单项类型
,a.HANDLE_TIME 受理时间,a.FINISH_TIME 竣工时间,a.PRE_HANDLE_FLAG 是否预受理
,a.CUST_ORDER_ID 客户订单标识,a.ORDER_ITEM_ID 订单项标识,a.UNDO_FLAG 撤单标识,
a.ORDER_ITEM_OBJ_ID 订单项业务对象标识,a.OFFER_KIND 销售品类型,a.ASK_SOURCE 受理来源, staff_id,service_offer_id
,a.channel_id
 from  dm_evt_l_order_item a where a.handle_time between '{yyyy-mm}-01' and '{next_yyyy-mm}-01'
and a.region_id in ('AREA_ID','AREA_ID_324', '301') ) a
-- 1.0的用户表
left join DIM_CRM_STAFF b on a.staff_id=b.PARTY_ROLE_ID
-- 2.0的用户表
--left join DWD_S_CRM_STAFF b on a.staff_id=b.STAFF_ID 

left join DWD_S_CRM_SERVICE_OFFER c on c.service_offer_id=a.service_offer_id 

-- 1.0的组织表
--left join DIM_CRM_ORGANIZATION d on a.channel_id=d.parent_party_id 
-- 2.0的组织表
left join DWD_S_CRM_ORGANIZATION d on a.CHANNEL_ID =d.party_id

--where a.handle_time between '{yyyy-mm}-01' and '{next_yyyy-mm}-01'
--and a.region_id in ('324','1022', '301')
limit 10000000
;
--4328

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select distinct a.*,b.acc_nbr 号码,b.user_name 客户名称,b.down_velocity 带宽, c.product_name 产品名称,b.comments 备注信息,b.cust_id 客户编码,b.mkt_cust_code 合同号,b.completed_date 号码竣工时间,b.remove_date 号码拆机时间,d.mkt_channel_name 营维部,d.mkt_region_name 区域,d.mkt_grid_name 网格 from 
(
select distinct a.*,b.PROD_OFFER_INST_EFF_DATE 销售品生效时间,b.PROD_OFFER_INST_exp_DATE 销售品失效时间,b.PROD_OFFER_INST_ID 销售品共享实例ID,c.prod_offer_name 销售品名称,b.serv_id from 

 tgm_g1_ls1 a,
DS_PRD_OFFER_COMP_DETAIL b,dwd_s_crm_prod_offer c
where 
a.订单项业务对象标识=b.PROD_OFFER_INST_ID
and b.prod_offer_id=c.prod_offer_id
) a
left join DS_CHN_PRD_SERV_AREA_{yyyymm} b on a.serv_id=b.serv_id 
    --分公司用户表
left join DIM_CRM_PRODUCT c on b.product_id=c.product_id
left join dim_zone_area d on  b.mkt_grid_id=d.mkt_grid_id
where 
b.serv_id is not null;

--应客服中心要求,增加联系电话字段.
--create temp table temp_ttt1 as 
--select a.*, b.telephone 联系电话 from tmp_PACKGE_NAME_AREA_FEEMONTH a
--left join DS_PTY_CUST_LAST_DAY b on a.cust_code=b.cust_code
--;
--drop table tmp_PACKGE_NAME_AREA_FEEMONTH;
--create table tmp_PACKGE_NAME_AREA_FEEMONTH as select * from temp_ttt1;
select '33';
