--��������ȫ��,��������
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct 
      to_char(ATIME,'yyyy-mm-dd') ����ʱ��
,to_char(ATIME,'yyyy-mm') �����·�
       ,ORDER_ID �������
	,accept_id �������
       ,product_name ��Ʒ����
       ,SERVICE_offer_name �����ṩ
       ,product_no ��Ʒ����
       ,cust_name  �û�����
	,cust_code
       --,prod_addr  ��װ��ַ
       ,to_char(COMPLETED_DATE,'yyyy-mm-dd') ����ʱ��
,case when accept_state=0 then '�Ѿ�����δ���' when accept_state=1 then '�Ѿ����δȷ��' when accept_state=2 then '�Ѿ�ȷ��' when accept_state=2.1 then '��ȷ��(Ԥ����)' when accept_state=3 then '�Ѿ��ʼ�(��������)' when accept_state=4 then '�ȴ�����(�������)' when accept_state=5 then '�Ѿ�����' else accept_state end ����״̬
	--ACCEPT_STATE ����״̬
	-- 0 �Ѿ�����δ���;1 �Ѿ����δȷ��;2 �Ѿ�ȷ��;2.1 ��ȷ��(Ԥ����);3 �Ѿ��ʼ�(��������);4 �ȴ�����(�������);5 �Ѿ�����
	--,org_name   ��֯����
       ,staff_desc ������
       ,staff_code ������
       --,region_name ��վ����
       --,region_code ��վ����
       ,COM_CHANNEL_NAME ά��Ӫά��
       ,COM_GRID_NAME  ά������
       ,date(now())-date(ATIME) �ͻ��ȴ����� 
       --,'δ����' ������־ 
 from 

(
select t11.*,t12.SERVICE_OFFER_NAME from 
(
select t10.product_name,t9.* from 
(
select t8.staff_desc,t8.staff_code,t7.* from 
(
select t6.COM_CHANNEL_NAME,t6.COM_GRID_NAME,t5.* from
(
select t3.*,t4.mkt_comm_id from 
(
select t2.region_name,t2.region_code,t1.* from 
(
select * from DM_EVT_SR_ACCEPT  where DEAL_EXCH_ID ='AREA_ID'  --����ִ���    
                         --and SERVICE_ID in('10000') --��װ����
                         --and product_id in('102030001','102010002','208511177') --adsl�����adslר�ߣ�ITV
                         --and COMPLETED_DATE>now() --����ʱ����ڵ�ǰʱ��, ��ʱû����
			--and ACCEPT_STATE<>5 --����״̬�������ѿ���, ԭ����ʹ������һ�еĿ���ʱ�����жϿ������
			-- 0 �Ѿ�����δ���;1 �Ѿ����δȷ��;2 �Ѿ�ȷ��;2.1 ��ȷ��(Ԥ����);3 �Ѿ��ʼ�(��������);4 �ȴ�����(�������);5 �Ѿ�����
			
			and atime like '{yyyy-mm}%%'
                         --and UNDO_FLAG=1 --û����
) t1 inner join DIM_CRM_REGION t2 on t1.SUB_EXCH_ID=t2.region_id --��������վ����
) t3 left join (select * from DIM_CHN_RULE where rule_state=1 and rule_type='008') t4 on 
t3.region_code=t4.rule_code  --CRM��վ���������ά������ID
) t5 left join DIM_ZONE_COMM t6 on t5.mkt_comm_id=t6.COM_GRID_ID --������ά����������
) t7 left join DIM_CRM_STAFF t8 on t7.OPER_ID=t8.PARTY_ROLE_ID  --����������������
) t9 left join DIM_PRODUCT t10 on t9.product_id=t10.PRODUCT_ID  --��������Ʒ����
) t11 left join DIM_CRM_SERVICE_OFFER t12 on t11.service_id=t12.SERVICE_OFFER_ID  --�����������ṩ����
) t13 left join (select * from DIM_CRM_ORGANIZATION where state='00A') t14 on 
t13.DEPART_ID=t14.party_id order by to_char(ATIME,'yyyy-mm-dd'); --�����������˵���֯����

--Ӧ�ͷ�����Ҫ��,������ϵ�绰�ֶ�.
create temp table temp_ttt1 as 
select a.*, b.telephone ��ϵ�绰 from tmp_PACKGE_NAME_AREA_FEEMONTH a
left join DS_PTY_CUST_LAST_DAY b on a.cust_code=b.cust_code
;
drop table tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select * from temp_ttt1;
select '33';
