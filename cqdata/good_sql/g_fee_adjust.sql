-- 提调帐清单
-- 如是提当月,则提调帐日表(日累积表,没有后缀)

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct mkt_channel_name 营维部,
mkt_grid_name 营销网格,
product_name 产品名称,
user_name 用户名称,
mkt_cust_code 缴费合同号,
acc_nbr 用户号码,
acct_item_type_desc5 帐目名称,
adjust_charge 调帐金额,
state_date 调帐时间,
reason  调帐原因分类,
adjust_source 调帐来源,
staff_code 调帐工号,
staff_desc 调帐人员

 from 
(
select t5.*,t6.product_name 
 from 
(
select t4.mkt_channel_name,t4.mkt_grid_name,t3.acc_nbr,t3.product_id,mkt_cust_code,user_name,acct_item_type_id,adjust_source,reason
,t3.audit_party_role_id,
to_char(state_date,'yyyy-mm-dd') state_date,sum(adjust_charge) adjust_charge from 
(
select t2.mkt_grid_id,t2.user_name,t2.
acc_nbr,t2.mkt_cust_code,t2.product_id,t1.* 
from ds_act_acct_adjust{day_or_month} t1  --按月份修改
inner join ds_chn_prd_serv_{area}_{last_month} t2   --按月份修改
on t1.serv_id=t2.serv_id where t2.mkt_area_id='{area}'
) t3 inner join dim_zone_area t4
on t3.mkt_grid_id=t4.mkt_grid_id
 group by t4.mkt_channel_name,t4.mkt_grid_name,t3.acc_nbr,t3.product_id,mkt_cust_code,
user_name,acct_item_type_id,adjust_source,reason,to_char(state_date,'yyyy-mm-dd'),audit_party_role_id 
) t5 inner join dim_product t6 on t5.product_id=t6.product_id 
) t7 left join dim_crm_staff t8 on t7.audit_party_role_id=t8.party_role_id 
left join dim_chn_acct_item_type t9 on t7.acct_item_type_id=t9.acct_item_type_id5
order by mkt_channel_name,reason,mkt_cust_code
;
	
select '33';
--* from tmp_g2_33_201110;
