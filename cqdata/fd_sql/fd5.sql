-- �ᶼ��ʧ����嵥
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select a.*
--,b.offer_comp_id, prod_offer_id 
,c.offer_name
--, c_prod.offer_name prod_name
,0.0 score
from 
(
select  distinct a.*, b.offer_comp_id
--, b.prod_offer_id
--, b.prod_offer_inst_exp_date, b.prod_offer_inst_d_exp_date
,b.offer_comp_instance_id
--,b.prod_offer_inst_state_date
from      (
select acc_nbr, user_name, a.com_grid_id, jjx_code, user_grp_type
, down_velocity,  completed_date, remove_date, serv_id
, com.com_channel_name, com.com_grid_name
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  serv_num<>1
and product_id=102030001
and remove_date between '2012-01-01' and '2012-02-29'
-- or remove_date between '2012-01-01' and '2013-01-01'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state<>'00A'
and b.prod_offer_inst_state_date>='2012-01-01'  --����2012����޸�ΪʧЧ��
--and case when a.completed_date>'2012-01-01' then b.prod_offer_inst_state='00A' else b.prod_offer_inst_state<>'00A' end
 and b.offer_comp_id not in (-99, 0
 ,325038  --ȫ���������������1M�� ���ٵ��������, ��һ������п���������������2M�Ļ����Ż���Ʒ
 )
    ) a
left join dim_crm_product_offer c on a.offer_comp_id=c.offer_id 
--left join dim_crm_product_offer c_prod on a.prod_offer_id=c_prod.offer_id 
order by a.acc_nbr

;
--������Ϊ2M���£����ײ�Ϊ426����������ܲ�����ֵ��嵥��ͳ��
--�����ڻ�������������Ϊ0�Ĺ۲�״����
--select * from tmp_PACKGE_NAME_AREA_FEEMONTH where down_velocity in ('1M','512K','640K', '1.5M') or offer_comp_id in (121244);

update tmp_PACKGE_NAME_AREA_FEEMONTH set score=688/12 where offer_name='��08����e8��1MAD��װ688Ԫ���ײͳ�ŵ12���£����²�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=588/12 where offer_name='��08����e8��1M����ʱAD��װ588Ԫ���ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=58 where offer_name='��08����e8��1M����ʱAD��װ58Ԫ���ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=58 where offer_name='��08����e8��1M����ʱ��ADת58Ԫ���ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='��08����e8��2MAD��װ78Ԫ���ײͣ�����)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=888/12 where offer_name='��08����e8��2MAD��װ888Ԫ���ײͣ�����)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=688/12 where offer_name='e��1M688Ԫ���ײͣ��Ż���';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=50 where offer_name='None' or offer_name is null;
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=118 where offer_name='�ҵ�e��e8-4M118�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=119 where offer_name='��e9-4M����ʱ119�ײͣ�ȫ���Ѱ棩';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=99 where offer_name='��e9�ײ�2M����ʱ99Ԫ�ײͣ����أ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=568/12 where offer_name='Ԥ��1000Ԫ��12���£�ǰ̨�շѣ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=99 where offer_name='ȫ���֣�e9���ײ�2M����ʱ99Ԫ�ײͣ����أ����ϣ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='�������e8-1M�������78Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=788/12 where offer_name in ('��08����e8��1MAD��װ788Ԫ���ײͳ�ŵ12���£����ڣ�','e8��Ϣ��԰1M����ʱ��ADת788Ԫ���ײ�');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=99 where offer_name='ȫ���֣�e9���ײ�2M����ʱ99Ԫ�ײͣ����أ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='��08����e8��2M��ADת78Ԫ���ײͣ�����)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=99 where offer_name='ȫ��������e9-ADSL2M����ʱ99�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=48 where offer_name='��08����e8��1MAD��װ48Ԫ���ײͳ�ŵ12���£����ڣ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=688/12 where offer_name='��08����e8��1M��ADת688Ԫ���ײͳ�ŵ12���£����²�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='��08����e8��1M��ADת78Ԫ���ײ�';

--���в��ֺ������ظ�, ��������,Ҫɾ��
delete from tmp_PACKGE_NAME_AREA_FEEMONTH where score=0;
update tmp_PACKGE_NAME_AREA_FEEMONTH set offer_comp_instance_id=0 where offer_comp_instance_id is null;
create temp table tmp_t3 as 
select b.* from (
select acc_nbr, min(offer_comp_instance_id) min_id from tmp_PACKGE_NAME_AREA_FEEMONTH group by 1) a 
left join tmp_PACKGE_NAME_AREA_FEEMONTH b on a.acc_nbr=b.acc_nbr and a.min_id=b.offer_comp_instance_id;
drop table tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select * from tmp_t3;
drop table tmp_t3;
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=-score ;
select '33';
--* from tmp_g2_33_201110;

