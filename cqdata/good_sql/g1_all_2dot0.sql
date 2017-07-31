--��������ȫ��,��������
--CRM2.0���������

drop table if exists tgm_g1_ls1;
create temp table tgm_g1_ls1 as 
select  distinct 
--region_id, 
d.ORG_NAME ������,b.STAFF_DESC ����Ա��,b.staff_code ������
,c.service_offer_name ��������
,a.*
 from
 (select 
 a.ORDER_ITEM_CD ����������
,a.HANDLE_TIME ����ʱ��,a.FINISH_TIME ����ʱ��,a.PRE_HANDLE_FLAG �Ƿ�Ԥ����
,a.CUST_ORDER_ID �ͻ�������ʶ,a.ORDER_ITEM_ID �������ʶ,a.UNDO_FLAG ������ʶ,
a.ORDER_ITEM_OBJ_ID ������ҵ������ʶ,a.OFFER_KIND ����Ʒ����,a.ASK_SOURCE ������Դ, staff_id,service_offer_id
,a.channel_id
 from  dm_evt_order_item a where a.handle_time between '{yyyy-mm}-01' and '{next_yyyy-mm}-01'
and a.region_id in ('AREA_ID','AREA_ID_324', '301') union 
select a.ORDER_ITEM_CD ����������
,a.HANDLE_TIME ����ʱ��,a.FINISH_TIME ����ʱ��,a.PRE_HANDLE_FLAG �Ƿ�Ԥ����
,a.CUST_ORDER_ID �ͻ�������ʶ,a.ORDER_ITEM_ID �������ʶ,a.UNDO_FLAG ������ʶ,
a.ORDER_ITEM_OBJ_ID ������ҵ������ʶ,a.OFFER_KIND ����Ʒ����,a.ASK_SOURCE ������Դ, staff_id,service_offer_id
,a.channel_id
 from  dm_evt_l_order_item a where a.handle_time between '{yyyy-mm}-01' and '{next_yyyy-mm}-01'
and a.region_id in ('AREA_ID','AREA_ID_324', '301') ) a
-- 1.0���û���
left join DIM_CRM_STAFF b on a.staff_id=b.PARTY_ROLE_ID
-- 2.0���û���
--left join DWD_S_CRM_STAFF b on a.staff_id=b.STAFF_ID 

left join DWD_S_CRM_SERVICE_OFFER c on c.service_offer_id=a.service_offer_id 

-- 1.0����֯��
--left join DIM_CRM_ORGANIZATION d on a.channel_id=d.parent_party_id 
-- 2.0����֯��
left join DWD_S_CRM_ORGANIZATION d on a.CHANNEL_ID =d.party_id

--where a.handle_time between '{yyyy-mm}-01' and '{next_yyyy-mm}-01'
--and a.region_id in ('324','1022', '301')
limit 10000000
;
--4328

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select distinct a.*,b.acc_nbr ����,b.user_name �ͻ�����,b.down_velocity ����, c.product_name ��Ʒ����,b.comments ��ע��Ϣ,b.cust_id �ͻ�����,b.mkt_cust_code ��ͬ��,b.completed_date ���뿢��ʱ��,b.remove_date ������ʱ��,d.mkt_channel_name Ӫά��,d.mkt_region_name ����,d.mkt_grid_name ���� from 
(
select distinct a.*,b.PROD_OFFER_INST_EFF_DATE ����Ʒ��Чʱ��,b.PROD_OFFER_INST_exp_DATE ����ƷʧЧʱ��,b.PROD_OFFER_INST_ID ����Ʒ����ʵ��ID,c.prod_offer_name ����Ʒ����,b.serv_id from 

 tgm_g1_ls1 a,
DS_PRD_OFFER_COMP_DETAIL b,dwd_s_crm_prod_offer c
where 
a.������ҵ������ʶ=b.PROD_OFFER_INST_ID
and b.prod_offer_id=c.prod_offer_id
) a
left join DS_CHN_PRD_SERV_AREA_{yyyymm} b on a.serv_id=b.serv_id 
    --�ֹ�˾�û���
left join DIM_CRM_PRODUCT c on b.product_id=c.product_id
left join dim_zone_area d on  b.mkt_grid_id=d.mkt_grid_id
where 
b.serv_id is not null;

--Ӧ�ͷ�����Ҫ��,������ϵ�绰�ֶ�.
--create temp table temp_ttt1 as 
--select a.*, b.telephone ��ϵ�绰 from tmp_PACKGE_NAME_AREA_FEEMONTH a
--left join DS_PTY_CUST_LAST_DAY b on a.cust_code=b.cust_code
--;
--drop table tmp_PACKGE_NAME_AREA_FEEMONTH;
--create table tmp_PACKGE_NAME_AREA_FEEMONTH as select * from temp_ttt1;
select '33';
