--
--Ա��500M���������嵥
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select b.acc_nbr,b.user_name, prod_offer_inst_created_date
from ds_prd_offer_comp_detail a
left join ds_chn_prd_serv_{area}_{yyyymm} b on a.serv_id=b.serv_id
--left join dim_crm_product_offer t3 on a.offer_comp_id=t3.offer_id
--where a.offer_comp_id=333857 --��Ա��500M
where a.offer_comp_id in ('333874','333858') --��Ա��500M (2013����Ϊ��, ����Ҫ��OCS��)
--and a.prod_offer_inst_state='00A'
--and a.prod_offer_inst_state='001'  --ʹ�����״̬,��ʾ��ǰ������Ч,��ʹ�����Ѿ����
and a.prod_offer_inst_detail_state='001' --ʹ�����״̬,���п��ܱ�ʾCRM��ǰ��״̬
--323847 --Ա������500M
and b.serv_id is not null
;
select 'AREA';
--* from tmp_g2_AREA_201110;

