-- �ᶼe9�ֻ��嵥--ר��

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
select distinct a.*, b.offer_comp_id
, offer_comp_instance_id
--, prod_offer_inst_id

--, b.prod_offer_id
from      (
select distinct a.acc_nbr, user_name, a.com_grid_id
--, jjx_code, user_grp_type
--, down_velocity
,  completed_date
--, remove_date
, a.serv_id 
, com.com_channel_name, com.com_grid_name, a.mkt_cust_code
, b.group_id, b.member_role_id --Ⱥid, Ⱥ��Ա����
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
left join dm_prd_crm_service_grp_member b on a.serv_id=b.serv_id
and b.member_role_id in ('80','36','62')
where  
serv_num=1
and 
product_id=208511296
--and completed_date >='2012-01-01'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state='00A'
 where  b.offer_comp_id in ( 
	--e9�ֻ��Ļ�,��Ҫ�������·���: e�ҹ����, ȫ����119,ȫ����149
331494  --e���ֻ������ȫ���Ѱ�
,319290
--13388962056	ȫҵ���ֻ������5Ԫ/��/����������Ч��,ȫ���֣�e9���ײ�2M����ʱ99Ԫ�ײͣ����أ����ϣ�,�ֻ��̻��弶V��	319290,321655,315656	ȫҵ���ֻ������5Ԫ/��/����������Ч��_������,ȫ���֣�e9���ײ�2M����ʱ99Ԫ�ײͣ����أ����ϣ�_������,vpn����Ⱥ(�������)Ⱥ��1-1000000����CDMA
,331516	--92790330	None	��e9-4M����ʱ119�ײ�
,328071	--90655518	None	e���ֻ������
,331488	--90792107	None	��e9-4M����ʱ149�ײͣ�ȫ���Ѱ棩
,331517	--��e9-4M����ʱ119�ײ�_������
,328072	--e���ֻ������_������
,331489	--��e9-4M����ʱ149�ײͣ�ȫ���Ѱ棩_������
,331495	--e���ֻ��������ȫ���Ѱ棩_������
,325498	--ȫ��������e9-ADSL2M����ʱ99�ײ�_������
,331508	--��e9-4M����ʱ119�ײͣ�ȫ���Ѱ棩_������
,331507  --��e9-4M����ʱ119�ײͣ�ȫ���Ѱ棩
--,330675 --��ŵ����119Ԫ����1M
--,330398 --��ŵ����119Ԫ����2M
--,330677 --��ŵ����119Ԫ����3M
,331488 --��e9-4M����ʱ149�ײͣ�ȫ���Ѱ棩
--,329628 --��e9-4M����ʱ119�ײ�
--,331516 --������329628һ��...
,324806	--ȫ���֣�e9���ײ�2M����ʱ99Ԫ�ײͣ����أ�_������
,324805	--324806	ȫ���֣�e9���ײ�2M����ʱ99Ԫ�ײͣ����أ�_������
,325497	--ȫ��������e9-ADSL2M����ʱ99�ײ�_������
,329628	--��e9-4M����ʱ119�ײ�_������
,329639	--��e9-4M����ʱ189�ײͣ���iTV��_������
,324805	--ȫ���֣�e9���ײ�2M����ʱ99Ԫ�ײͣ����أ�_������
,276905	--��e9�ײ�2M����ʱ99Ԫ�ײͣ����أ�_������
,316905	--��e9�ײ�2M����ʱ99Ԫ�ײͣ����أ�_������
,325468	--ȫ��������e9-ADSL1M����ʱ79�ײ�_������
,321655	--ȫ���֣�e9���ײ�2M����ʱ99Ԫ�ײͣ����أ����ϣ�_������
,316901	--��e9�ײ�1M����ʱ89Ԫ�ײͣ����أ�_������
,327977	--327978	�ҵ�e��e6-66�ײ�_������
,327987	--327988	�ҵ�e��e6-96 �ײ�_������

 )
   ) a
left join dim_crm_product_offer c on a.offer_comp_id=c.offer_id 
--left join dim_crm_product_offer c_prod on a.prod_offer_id=c_prod.offer_id 
--order by a.acc_nbr
--distribute by acc_nbr
--����3G���ܻ�����ȡ��3G�����ܻ���ʶ
left join DS_PRD_SERV_3G_LAST_DAY phone on a.serv_id=phone.serv_id
;
--����ͨ������ʱ������ѯ���ֻ������´�����Ϣ
create temp table temp1 as 
select a.*, term.* from tmp_PACKGE_NAME_AREA_FEEMONTH a
left join 

(select a.acc_nbr ter_acc, b.type, b.esn from 
(select acc_nbr , max(register_time) reg from ds_evt_terminal_info_all_ry term where acc_nbr in (select acc_nbr from tmp_PACKGE_NAME_AREA_FEEMONTH) group by 1) a left join ds_evt_terminal_info_all_ry b on a.acc_nbr=b.acc_nbr and a.reg=b.register_time )
 term 
on a.acc_nbr=term.ter_acc
;

--���˲��ֺ����漰����Ʒʵ�������������������
create temp table temp2_accept as 
select * from dm_evt_sr_accept where offer_comp_instance_id in 
(select offer_comp_instance_id from temp1) and service_id=20000;

create temp table temp3_accept_max as  
select offer_comp_instance_id, max(produce_id) produce_id from temp2_accept group by 1;

create temp table temp3_accept as 
select b.* from temp3_accept_max a left join temp2_accept b on 
a.offer_comp_instance_id=b.offer_comp_instance_id and a.produce_id=b.produce_id;

create temp table temp2 as 
select distinct a.*, b.oper_id, b.terminal_ip --, b.atime
,t8.staff_desc,t8.staff_code
from temp1 a
left join temp3_accept b on 
--a.serv_id=b.serv_id and 
--b.service_id=20000 --����
--and 
a.offer_comp_instance_id = b.offer_comp_instance_id
--and 
--a.prod_offer_inst_id = b.product_offer_instance_id
left join DIM_CRM_STAFF t8 on b.OPER_ID=t8.PARTY_ROLE_ID  --����������������
;
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select distinct * from temp2;
drop table temp1;
select '33';
--* from tmp_g2_33_201110;
--20120510 ������ȡgroup_id,��member_role_id(Ⱥid,��Ⱥ��Ա����)
