--�����鿨12Ԫ�����嵥

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct t15.*,t16.OFFER_COMP_TYPE_DESC6 �ײ����� from 
(
select t13.*,t14.COMP_OFFER_ID ��Ʒ���� from 
(
select distinct to_char(ATIME,'yyyy-mm') �����·�
       ,ORDER_ID �������
       ,accept_id ������
       ,product_name ��Ʒ����
       ,SERVICE_offer_name �����ṩ
       ,product_no ��Ʒ����
       ,serv_id �û���ʶ
       ,RESOURCE_INSTANCE_CODE �ֻ�����
       ,user_name  �û�����
       ,CUST_ADDRESS  �ͻ���ַ
       ,to_char(ATIME,'yyyy-mm-dd') ����ʱ��
       ,org_name   ��֯����
       ,staff_desc ������
       ,staff_code ������
 from (
select t9.*,t10.SERVICE_OFFER_NAME from 
(
select t8.product_name,t7.* from 
(
select t6.staff_desc,t6.staff_code,t5.* from 
(
select t3.*,t4.CUST_ADDRESS from 
(
select t2.user_name,t2.RESOURCE_INSTANCE_CODE,t2.cust_id,t1.* from 
(
select ATIME,ORDER_ID,accept_id,product_id,product_no,serv_id,COMPLETED_DATE,DEPART_ID,OPER_ID,service_id from DM_EVT_SR_ACCEPT  
where DEAL_EXCH_ID ='{area_id}'  --����ִ���    
                         and SERVICE_ID in('100535', '100001') --���Ϸ���
                         and product_id='208511296' --����CDMA
                         and UNDO_FLAG=1 --û����
                         and to_char(ATIME,'yyyy')='2012') t1 
                         inner join DS_CHN_PRD_SERV_{area}_{yyyymmdd} t2 on t1.serv_id=t2.serv_id 
) t3 inner join DS_PTY_CUST_{yyyymmdd} t4 on t3.cust_id=t4.cust_id
) t5 left join DIM_CRM_STAFF t6 on t5.OPER_ID=t6.PARTY_ROLE_ID  --����������������
) t7 left join DIM_PRODUCT t8 on t7.product_id=t8.PRODUCT_ID  --��������Ʒ����
) t9 left join DIM_CRM_SERVICE_OFFER t10 on t9.service_id=t10.SERVICE_OFFER_ID  --�����������ṩ����
) t11 left join (select * from DIM_CRM_ORGANIZATION where state='00A') t12 on t11.DEPART_ID=t12.party_id --�����������˵���֯����
) t13 inner join DS_CHN_PRD_OFFER_COMP_{yyyymmdd} t14 on t13.�û���ʶ=t14.serv_id where t14.COMP_OFFER_ID='324768'
) t15 inner join DIM_WD_OFFER_NEW_DIR_SECOND t16 on t15.��Ʒ����=t16.OFFER_COMP_TYPE_ID6
order by �������
;	
select '33';
--* from tmp_g2_33_201110;
