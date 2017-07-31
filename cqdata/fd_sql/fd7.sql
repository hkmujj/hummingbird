-- �ᶼ�����ֻ��嵥--��������,ר��
--�˴����������

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
drop table if exists tgm_ls;
create temp table tgm_ls as 
select distinct a.*
--,inst.acc_nbr adsl_new
--,b.offer_comp_id, prod_offer_id 
,c.offer_name
--, c_prod.offer_name prod_name
--,0.0 score
,phone.enable_flag, phone.intell_flag
--, user_postn_arrive_num
,term.imei, term.factory, term.type
from 
(
select distinct a.*, b.offer_comp_id
, offer_comp_instance_id
--, b.prod_offer_id
from      (
select acc_nbr, user_name, a.com_grid_id
--, jjx_code, user_grp_type
--, down_velocity
,  completed_date
--, remove_date
, serv_id 
, com.com_channel_name, com.com_grid_name, a.mkt_cust_code
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  serv_num=1
and product_id=208511296
and completed_date between '2012-01-01' and '2012-03-10'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state='00A'
 and  b.offer_comp_id in ( 
331961,331962,331964,331965,331966,331967,331968,331969
,	331963 --�����캽90Ԫ����������
,331949 --�����캽�����ֻ��ײ�39����, �������η��治�ܱ����ײͰ�����
,331973
,331976 --�����ײ��ֻ���װ��
 )
where b.offer_comp_id is not null    ) a
left join dim_crm_product_offer c on a.offer_comp_id=c.offer_id 
--left join dim_crm_product_offer c_prod on a.prod_offer_id=c_prod.offer_id 
--order by a.acc_nbr
--distribute by acc_nbr
--����3G���ܻ�����ȡ��3G�����ܻ���ʶ
left join DS_PRD_SERV_3G_LAST_DAY phone on a.serv_id=phone.serv_id
left join DS_CHN_PRD_CUST_33_LAST_DAY mkt on a.mkt_cust_code=mkt.mkt_cust_code
--left join tmp_fd2_AREA_FEEMONTH inst on a.offer_comp_instance_id=inst.offer_comp_instance_id  --������װ������ײ�ʵ��id
left join DS_EVT_TERMINATION_INFO term on a.acc_nbr=term.acc_nbr
;
--������Ϊ2M���£����ײ�Ϊ426����������ܲ�����ֵ��嵥��ͳ��
--�����ڻ�������������Ϊ0�Ĺ۲�״����
--select * from tmp_PACKGE_NAME_AREA_FEEMONTH where down_velocity in ('1M','512K','640K', '1.5M') or offer_comp_id in (121244);

drop table if exists billing;
create temp table billing as 
select acc_nbr, count(*) count from tgm_ls a
left join ds_evt_call_area_33 b on a.acc_nbr=billing_nbr group by 1;

create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select a.*, 0 score, b.count from  tgm_ls a
left join billing b on a.acc_nbr=b.acc_nbr;
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	45	 where offer_name='�����캽50Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	65	 where offer_name='�����캽90Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=95	 where offer_name='�����캽150Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=145	 where offer_name='�����캽250Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=195	 where offer_name='�����캽350Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=245	 where offer_name='�����캽450Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='���߿������Ʒ�ײ�100Ԫ/�£�OCS��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	300	 where offer_name='���߿������Ʒ�ײ�300Ԫ/�£�OCS��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=119		 where offer_name='��e9-4M����ʱ119�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=49		 where offer_name='OCS201108������49Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	189	 where offer_name='201108�����189Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	16	 where offer_name='������800M16�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	50	 where offer_name='���߿������Ʒ�ײ�50Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	46	 where offer_name='�ҵ�e��e6-46�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	26	 where offer_name='����������26�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	96	 where offer_name='�ҵ�e��e6-96 �ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	200	 where offer_name='T2���߿��200�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	89	 where offer_name='OCS201108�����89Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='���߿������Ʒ�ײ�100Ԫ/�£�2GB��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	49	 where offer_name='201108������49Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	300	 where offer_name='T2���߿��300�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	300	 where offer_name='T2���߿��300�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	10	 where offer_name='�ֻ�������10Ԫ��60M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	5	 where offer_name='�ֻ�������5Ԫ��30M';

-- �������ֻ�,������Ҳ������,�����Ǳ��Ѿ�������119����,�ֻ����ټ�119����.
--update tmp_PACKGE_NAME_AREA_FEEMONTH set score=-99 where offer_comp_instance_id in (select offer_comp_instance_id from tmp_fd2_AREA_FEEMONTH);
--update tmp_PACKGE_NAME_AREA_FEEMONTH set score=0 where adsl_new is not null;

--�Լ�,����E9�ײ�, �����еĿ��Ҳ��������,���ײͻ��ֲ�Ӧ����
--ȡ���ײͱ�ʶ,ȡͬ�ײ��µ��ֻ�����,���ж����Ƿ��ڱ�������

--,phone.enable_flag, phone.intell_flag
--update tmp_PACKGE_NAME_AREA_FEEMONTH set score=score+20 where enable_flag=1 and (score<>0  or adsl_new is not null) and offer_name not like '%%���߿��%%' and offer_name not like '%%T2%%';
--update tmp_PACKGE_NAME_AREA_FEEMONTH set score=score+10 where intell_flag=1 and (score<>0 or adsl_new is not null) and offer_name not like '%%���߿��%%' and offer_name not like '%%T2%%';

-- ��ѡ����Ӧ���Ƶ��������ܻ���3G�ֻ�����֮��,����һ���ֻ��ظ��㽱��.

update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	20	 where offer_name='�ֻ�������20Ԫ��150M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=5		 where offer_name='ȫҵ���ѡ���Ű�5Ԫ��100��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=10		 where offer_name='ȫҵ�񳤻���10Ԫ/�£�������Ч��';
--����Ҫ����: ��C�ںϼӷ�
--����: ����Ϊ����̻��ϻ���,��������20��
--update tmp_PACKGE_NAME_AREA_FEEMONTH set score=score+20 where user_postn_arrive_num>0;
select '33';
--* from tmp_g2_33_201110;
