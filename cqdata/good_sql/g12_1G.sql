--
--3G����Ա1G���������嵥
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select b.acc_nbr,b.user_name, prod_offer_inst_created_date
from ds_prd_offer_comp_detail a
left join ds_chn_prd_serv_{area}_{yyyymm} b on a.serv_id=b.serv_id
--left join dim_crm_product_offer t3 on a.offer_comp_id=t3.offer_id
--where a.offer_comp_id=333857 --��Ա��500M
where a.offer_comp_id in ('10004657','10004662') --��,Ԥ��,����ͨ, 
--Ԥ���ķᶼû���ҵ�ʵ��,����û����Ʒ������
--and a.prod_offer_inst_state='00A'
--and a.prod_offer_inst_state='001'  --ʹ�����״̬,��ʾ��ǰ������Ч,��ʹ�����Ѿ����
and a.prod_offer_inst_detail_state='001' --ʹ�����״̬,���п��ܱ�ʾCRM��ǰ��״̬
and b.serv_id is not null
;
select 'AREA';
--* from tmp_g2_AREA_201110;

