-- �ᶼ����iTV������
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
--create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
create temp table tgm_ls as 
select a.*
,inst.acc_nbr adsl_new
--,b.offer_comp_id, prod_offer_id 
,c.offer_name
--, c_prod.offer_name prod_name
--,0.0 score
,phone.enable_flag, phone.intell_flag
, user_postn_arrive_num
from 
(
select distinct a.*, b.offer_comp_id
, offer_comp_instance_id
--, b.prod_offer_id
from      (
select acc_nbr, user_name, a.com_grid_id, jjx_code, user_grp_type
, down_velocity,  completed_date, remove_date, serv_id 
, com.com_channel_name, com.com_grid_name, a.mkt_cust_code
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  serv_num=1
and product_id=208511177
and completed_date >='2012-01-01'
-- or remove_date between '2012-01-01' and '2013-01-01'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state='00A'
 and  b.offer_comp_id not in ( -99, 0 
,331949 --�����캽�����ֻ��ײ�39����, �������η��治�ܱ����ײͰ�����
,331558 --���ܻ�����������
 )
    ) a
left join dim_crm_product_offer c on a.offer_comp_id=c.offer_id 
--left join dim_crm_product_offer c_prod on a.prod_offer_id=c_prod.offer_id 
--order by a.acc_nbr
--distribute by acc_nbr
--����3G���ܻ�����ȡ��3G�����ܻ���ʶ
left join DS_PRD_SERV_3G_LAST_DAY phone on a.serv_id=phone.serv_id
left join DS_CHN_PRD_CUST_33_LAST_DAY mkt on a.mkt_cust_code=mkt.mkt_cust_code
left join tmp_fd2_AREA_FEEMONTH inst on a.offer_comp_instance_id=inst.offer_comp_instance_id  --������װ������ײ�ʵ��id
;
--������Ϊ2M���£����ײ�Ϊ426����������ܲ�����ֵ��嵥��ͳ��
--�����ڻ�������������Ϊ0�Ĺ۲�״����
--select * from tmp_PACKGE_NAME_AREA_FEEMONTH where down_velocity in ('1M','512K','640K', '1.5M') or offer_comp_id in (121244);


create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select *, 0 score from  tgm_ls ;
drop table tgm_ls;
update tmp_PACKGE_NAME_AREA_FEEMONTH set score= 28		 where offer_name in ('iTV����28Ԫ���£����ޣ������飩','iTV����28Ԫ���£����ޣ�','iTV���������28Ԫ���£�E�ң�','iTV���������28Ԫ���£���E��-���û���');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score= 298/12		 where offer_name in ('iTV����298Ԫ���꣨���ޣ������飩','iTV����298Ԫ���꣨���ޣ������飩','iTV����298Ԫ���꣨���ޣ�');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score= 20		 where offer_name in ('iTV�����Ա�������','iTV�����Ա�������');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score= 28 where offer_name in ('�������e8-2M�������88Ԫ/��','�������e8-1M�������78Ԫ/��','�������e8-2M�������988Ԫ/��','�������e8-2M�������888Ԫ/��','�������e8-1M�������888Ԫ/��','2M�������88Ԫ/��') and adsl_new is null;

--������װiTV,������װ����Ѿ�������������������Ļ���,��iTV������Ʒ�
--������298�ײ���Ӧ��.
--update tmp_PACKGE_NAME_AREA_FEEMONTH set score=0 where adsl_new is not null;

select '33';
--* from tmp_g2_33_201110;
