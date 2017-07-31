--����3G�ֻ���(20120922-20121031)
--�����ֻ��嵥(ֻȡ����)
--���ֿھ�: 1.�û����Ŀ������ڴ���20120922-20121031
--2.��������ʦ�Ŀ����������п������ڴ�������ʱ���
/* ϣ���ܹ���ȡ���ֶ�:
����	�ֻ�����	����	����	�ֻ���	�ʷ�	����	����	������	������	��ע
*/
-- �ᶼ�ֻ����Ͷ���������ʱ���9��20�տ�ʼ, ����ͳ��Ҫ�ų�20-21֮���.

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as
select distinct to_char(a.completed_date,'yyyy-mm-dd') ��������, a.acc_nbr,a.user_name �û�����, a.serv_num �����־, resource_instance_code ����, a.serv_id, a.remove_date, a.mkt_cust_code, cust.cust_created_date ��ͬ�Ž���ʱ��
, cust.user_ad_arrive_num+cust.user_postn_arrive_num AD�ӹ̻�����
, billing_mode_id ����ģʽ
, serv_state
--a.serv_id, a.product_id, a.mkt_cust_code, a.completed_date,b.offer_comp_id, b.offer_comp_instance_id,
--b.prod_offer_inst_id, b.prod_offer_id, prod_offer_inst_created_date
--, a.down_velocity, a.com_grid_id
, mkt.mkt_channel_name, mkt.mkt_grid_name --, a.mkt_cust_code
--, com.com_channel_name, com.com_grid_name --, a.mkt_cust_code
 from ds_chn_prd_serv_AREA_LAST_DAY a 
--left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='00A'
--left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
left join DIM_ZONE_area mkt on a.mkt_grid_id=mkt.mkt_grid_id 
left join DS_CHN_PRD_CUST_AREA_LAST_DAY cust on a.mkt_cust_code=cust.mkt_cust_code
where a.product_id in (
	--'102030001',
	'208511296')
and completed_date between '2012-09-20 00:00:00' and '2012-10-31 23:59:59'
--and completed_date >= '2012-09-20 00:00:00'	-- and '2012-10-31 23:59:59'
--and serv_num = 1
--distributed by (a.acc_nbr)
;

-- �����Ż���ص���ʱ��
drop table if exists tgm_tmp_offer;
create temp table tgm_tmp_offer as
select distinct a.acc_nbr,a.serv_id, b.offer_comp_id, t3.offer_id, t3.offer_name,b.offer_comp_instance_id, b.prod_offer_class_id
,b.prod_offer_id, t4.offer_name t4offer_name
,t5.offer_comp_type_desc3 d3
,t5.offer_comp_type_desc4 d4
,t5.offer_comp_type_desc5 d5
,t5.offer_comp_type_desc6 d6

from tmp_PACKGE_NAME_AREA_FEEMONTH a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='001' and prod_offer_inst_detail_state='001'
left join dim_crm_product_offer t3 on b.prod_offer_id=t3.offer_id 
left join dim_crm_product_offer t4 on b.offer_comp_id=t4.offer_id
left join DIM_WD_OFFER_NEW_DIR_SECOND t5 on b.offer_comp_id=t5.offer_comp_type_id6 
where b.offer_comp_id not in ('330855','334696')
--and t5.offer_comp_type_desc5 not in ('��������ͨ�Ż��ײ�','�����ײͿ�������3M') --���ų����ٵ�
--and t5.offer_comp_type_desc6 not like '%%����������%%' 
--and t5.offer_comp_type_desc6 not like  '%%����ʹ�÷�%%'; --��Уͨ���ܷ�
--�˴�����ʹ���й�t5�����ֶ�, �����Ĭ���������ֶβ���Ϊ��.
;
delete from tgm_tmp_offer where d5 in ('��������ͨ�Ż��ײ�','�����ײͿ�������3M') --���ų����ٵ�
or d6 like  '%%����ʹ�÷�%%'; --��Уͨ���ܷ�

drop table if exists tmp_offer2 ;
create temp table tmp_offer2 as 
select distinct a.*, b.offer_name ������, b.d3 �ײͷ�����, b.d4 �ײͷ����� , c.offer_name �ͻ���
,d.offer_name ���ٰ�, e.offer_name ������
,f.offer_name ��������������
,g.d6 �ֻ���
from tmp_PACKGE_NAME_AREA_FEEMONTH a
-- ������
left join tgm_tmp_offer b on a.acc_nbr=b.acc_nbr and 
(b.d3 in ('�����Ʒ���ײ�����Ʒ', '�ҵ�e��Ʒ���ײ�����Ʒ', '����Ʒ���ײ�����Ʒ','Xta+C') 
       	or b.d4 in ('������-2','���߿���')
) 
and (b.d6 not like '%%����������%%' or b.d6 not in ('��Уͨ���ܷ�4Ԫ/��','��Уͨ�¹���ʹ�÷�4��') )
--�ͻ���
left join tgm_tmp_offer c on a.acc_nbr=c.acc_nbr and c.offer_name like '%%�ͻ���%%'
--���ٰ�
left join tgm_tmp_offer d on a.acc_nbr=d.acc_nbr and d.offer_name like '%%������C����%%'
--������
left join tgm_tmp_offer e on a.acc_nbr=e.acc_nbr and (
       	e.offer_name like '%%����������%%' or e.offer_name in (
'330365' --	�ֻ�����150M��ѣ������£�_������
))
--�������Ѱ�
left join tgm_tmp_offer f on a.acc_nbr=f.acc_nbr and (f.offer_name like '%%�������Ѱ�%%' or f.offer_name like '%%����������%%')
--3G�ֻ���
left join tgm_tmp_offer g on a.acc_nbr=g.acc_nbr and g.d6 like '%%�ֻ����ն��Żݱ�ʶ%%';


--���м�����װ������Ա������,�Ա����ִ�����

-- ȡϵͳ̽�����,�Ƚ���ʱ��ȡ�����ֵ
drop table if exists tmp_ry1;
create temp table tmp_ry1 as 
select distinct acc_nbr, max(register_time) register_time from ds_evt_terminal_info_all_ry where acc_nbr in (select distinct acc_nbr from tmp_offer2) group by acc_nbr;
drop table if exists tmp_ry;
create temp table tmp_ry as select distinct b.* from tmp_ry1 a left join ds_evt_terminal_info_all_ry b on a.acc_nbr=b.acc_nbr and a.register_time=b.register_time;

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH AS select distinct aa.*
,d.ORG_NAME ��������,b.STAFF_DESC ����Ա��,b.staff_code ��������,a.ACCEPT_MODE ������ʽ
--,c.service_offer_name ��������
,a.HANDLE_TIME ����ʱ��
,a.staff_id
--,a.FINISH_TIME ����ʱ��,a.PRE_HANDLE_FLAG �Ƿ�Ԥ����,a.CUST_ORDER_ID �ͻ�������ʶ,
--a.ORDER_ITEM_ID �������ʶ,a.UNDO_FLAG ������ʶ,
--a.ORDER_ITEM_OBJ_ID ������ҵ������ʶ,a.OFFER_KIND ����Ʒ����,a.ASK_SOURCE ������Դ
, ry.esn, ry.type
from tmp_offer2 aa
left join tmp_ry ry on aa.acc_nbr=ry.acc_nbr --̽�����
left join DS_PRD_OFFER_COMP_DETAIL comp on aa.serv_id=comp.serv_id and prod_offer_inst_detail_state='001' and prod_offer_class_id='10'
--left join DM_EVT_l_ORDER_ITEM a on aa.acc_nbr=a.acc_nbr and a.HANDLE_TIME>='2012-06-22 00:00:00'   and service_offer_id=1  
left join DM_EVT_l_ORDER_ITEM a on a.ORDER_ITEM_OBJ_ID=comp.PROD_OFFER_INST_ID and a.HANDLE_TIME>='2012-06-22 00:00:00'   and a.service_offer_id=1  
and a.order_item_obj_type_id in ('318775','313812')
--����ʱ��, ����
--left join dim_crm_staff b on a.staff_id=b.party_role_id
left join  dwd_s_crm_staff b on a.staff_id=b.staff_id  --Ӧ����2.0�����ñ�
left join dwd_s_crm_service_offer c on a.service_offer_id=c.service_offer_id
-- and c.service_offer_name='����'
left join dim_crm_organization d on a.channel_id=d.party_id

and a.HANDLE_TIME>='2012-06-01 00:00:00'  --����ʱ��
distributed by (acc_nbr)
;
-- ɾ�����߿�������,ֻ��������CDMA
delete from tmp_PACKGE_NAME_AREA_FEEMONTH where ������ like '%%���߿���%%';

-- ���ֹ���û����������
update tmp_PACKGE_NAME_AREA_FEEMONTH set ��������='���ӷ��',����Ա��='���ӷ��', ��������='FDFHLH1' where staff_id= 300001026;
update tmp_PACKGE_NAME_AREA_FEEMONTH set ��������='�ᶼ����Ӫҵ��',����Ա��='����÷', ��������='FDCQYYTYXM' where staff_id= 300000267 ; 

--select * from ST_MKT_MBL_FESTIVAL_DETAIL_DM  where area_name like 'ɳƺ��'  and handle_time <'2012-09-25 00:00:00' and handle_time>='2012-09-24 00:00:00' ;
select '33';