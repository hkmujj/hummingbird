--��ֹ�˾E8����嵥
--���ű���ִ��ʱ����10������
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select 
distinct 
a.acc_nbr ����,a.product_id, a.prod_offer_id ��Ʒʵ��ID,a.mkt_cust_code,a.offer_comp_id ��Ʒ��ʵ��ID,
a.PROD_OFFER_INST_eff_DATE ��Ʒ��Чʱ��,a.PROD_OFFER_INST_EXP_DATE ��ƷʧЧʱ��,a.pname ��Ʒ����,
b.offer_name ��Ʒ������
--,b.eff_date, b.exp_date
,c.*
 from
(
select a.acc_nbr,a.product_id,b.prod_offer_id,b.offer_comp_id,a.mkt_cust_code,c.offer_name pname,
b.PROD_OFFER_INST_eff_DATE,b.PROD_OFFER_INST_EXP_DATE
from 
DS_CHN_PRD_SERV_AREA_FEEMONTH a,DS_PRD_OFFER_COMP_DETAIL

 b,DIM_CRM_PRODUCT_OFFER c 
where 
a.product_id='102030001'--�޶���Ʒ����
and a.serv_id=b.serv_id 
and 
b.prod_offer_id=c.offer_id
and 
b.PROD_OFFER_INST_D_EXP_DATE>='NEXT_MONTH_TIME'
--and a.state='00A'
and a.serv_num=1
) a ,DIM_CRM_PRODUCT_OFFER b 
left join DIM_WD_OFFER_NEW_DIR_SECOND c on b.offer_id=c.offer_comp_type_id6
where a.offer_comp_id=b.offer_id
and c.offer_comp_type_desc0='�ҵ�e��'
;

select '33';
--* from tmp_g2_33_201110;

