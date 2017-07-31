-- ������嵥(��ǰ��)
-- �����ᵱ��,��������ձ�(���ۻ���,û�к�׺)
-- ��д�ű�,�����ۻ������±�ṹ��һ��.

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct mkt_channel_name Ӫά��,
mkt_grid_name Ӫ������,
product_name ��Ʒ����,
user_name �û�����,
mkt_cust_code �ɷѺ�ͬ��,
acc_nbr �û�����,
acct_item_type_desc5 ��Ŀ����,
adjust_charge ���ʽ��,
state_date ����ʱ��,
reason  ����ԭ�����,
adjust_source ������Դ,
staff_code ���ʹ���,
staff_desc ������Ա

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
from ds_act_acct_adjust{day_or_month} t1  --���·��޸�
inner join ds_chn_prd_serv_{area}_{last_month} t2   --���·��޸�
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
