-- �ᶼ�����ֻ��嵥
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
select distinct a.*
, b.offer_comp_id
, offer_comp_instance_id
--, b.prod_offer_id
from      (
select acc_nbr, user_name, a.com_grid_id, jjx_code, user_grp_type
, down_velocity,  completed_date, remove_date, serv_id 
, com.com_channel_name, com.com_grid_name, a.mkt_cust_code
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where 
-- serv_num=1 �õ����־,��Щ��װ�ֻ��û�û�н���,����13310271726 13310271975  13310271973  13310271972,û�и㶮, ��������,�ɴ�Ӳ��ʱ���־,ֻȡδ�����
remove_date>'2012-03-01'
and product_id=208511296
and completed_date between '2012-01-01' and '2012-03-11'

-- or remove_date between '2012-01-01' and '2013-01-01'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state='00A'
 and  b.offer_comp_id not in ( -99, 0 
, 317758  --���顿���߿��EVDO����ʶ��
,327766 -- 2011����WLAN����10Сʱ��CDMA��
,331444 -- 3G���繺3G��200M
--,331494  --e���ֻ��������ȫ���Ѱ棩 ���Żݰ����ں���,����Щ�ֻ�����ֻ�д���װ��
,331598 --OCS��ŵ�Żݹ���25Ԫ��
,331594 --��ŵ�Żݹ���25Ԫ��
--,317056 --ȫҵ�񳤻���10Ԫ/�£�������Ч�� Ӧ��10����
,329522 --�ֻ�����30M���
--,327917 --�ֻ�������10Ԫ��60M  Ӧ��10����
--,327914 --�ֻ�������5Ԫ��30M Ӧ��5����
--,331963 --�����캽90Ԫ����������
,331949 --�����캽�����ֻ��ײ�39����, �������η��治�ܱ����ײͰ�����
,331558 --���ܻ�����������
,326580 --[IVPN]���ڳ�Ա�������
,327771 --2011����WLAN����10Сʱ��OCS��
,331448 --3G���繺3G��200M��Ԥ��
,321877 --�����������3���£�
,332046 --�����캽�����ײͿ�����ٰ�
--,330149 --����칫���ܰ����ɰ󶨣�
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

-- ���������ĵ����������,�����ֵ�����Ż���Ʒ����,��������Ʒ��.
insert into tgm_ls  
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
select distinct a.*
--, b.offer_comp_id
, b.prod_offer_id
, offer_comp_instance_id
--, b.prod_offer_id
from      (
select acc_nbr, user_name, a.com_grid_id, jjx_code, user_grp_type
, down_velocity,  completed_date, remove_date, serv_id 
, com.com_channel_name, com.com_grid_name, a.mkt_cust_code
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  serv_num=1
and product_id=208511296
and completed_date between '2012-01-01' and '2012-03-11'
-- or remove_date between '2012-01-01' and '2013-01-01'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state='00A'
 and  b.offer_comp_id not in ( -99, 0 
,331949 --�����캽�����ֻ��ײ�39����, �������η��治�ܱ����ײͰ�����
,331558 --���ܻ�����������
 )
    ) a
--left join dim_crm_product_offer c on a.offer_comp_id=c.offer_id 
left join dim_crm_product_offer c on a.prod_offer_id=c.offer_id  
--����3G���ܻ�����ȡ��3G�����ܻ���ʶ
left join DS_PRD_SERV_3G_LAST_DAY phone on a.serv_id=phone.serv_id
left join DS_CHN_PRD_CUST_33_LAST_DAY mkt on a.mkt_cust_code=mkt.mkt_cust_code
left join tmp_fd2_AREA_FEEMONTH inst on a.offer_comp_instance_id=inst.offer_comp_instance_id  --������װ������ײ�ʵ��id
where c.offer_name like '%%�����������Ѱ�%%'
;


create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select *, 0 score from  tgm_ls ;
drop table tgm_ls;
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	5	 where offer_name='e���ֻ������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	6	 where offer_name in ('�������6Ԫ�ײ�', '�Żݹ���6Ԫ��ŵ');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	6	 where offer_name in ('OCS������ͨ��6Ԫ�ײ�','OCS������ͨ����2011��');
-- update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	6	 where offer_name in ('OCS���������ײ�','���������ײ�');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	6	 where offer_name='OCS������ͨ��6Ԫ�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	10	 where offer_name='ȫ����������C��װ10Ԫ�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	16	 where offer_name='������800M16�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	18	 where offer_name='����������18�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	19	 where offer_name='OCS������19�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	19	 where offer_name='Ԥ����T9�ײ�19Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	19	 where offer_name='������19�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	19	 where offer_name='T9�ײ�19Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	20	 where offer_name='OCS�ֻ�������20Ԫ��150M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	26	 where offer_name='E6-11������26Ԫ�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	26	 where offer_name='����������26�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	29	 where offer_name='�����캽20Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	30	 where offer_name='OCS�ֻ�������30Ԫ��300M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	35	 where offer_name='С��ͨ���û�35Ԫ�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	39	 where offer_name='������39�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	39	 where offer_name='OCS������39�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	39	 where offer_name='T9�ײ�39Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	39	 where offer_name='Ԥ����T9�ײ�39Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	45	 where offer_name='�����캽50Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	46	 where offer_name='�ҵ�e��e6-46�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	49	 where offer_name='201108������49Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=49		 where offer_name='OCS201108������49Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	50	 where offer_name='�����������Ѱ�44Ԫ��50Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	55	 where offer_name='С��ͨ���û�55Ԫ�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	59	 where offer_name='OCS201108�����59Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	59	 where offer_name='201108�����59Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	50	 where offer_name='���߿������Ʒ�ײ�50Ԫ/�£�OCS��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	50	 where offer_name='�ֻ�������50Ԫ��800M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	50	 where offer_name='���߿������Ʒ�ײ�50Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	55	 where offer_name='С��ͨ���û�55Ԫ�ײ�(�޲���)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	65	 where offer_name='�����캽90Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	69	 where offer_name='201108������69Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	88	 where offer_name='��ͨ�������߿��88Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	89	 where offer_name='201108�����89Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	89	 where offer_name='ȫ��������e9-ADSL2M����ʱ89�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	89	 where offer_name='OCS201108�����89Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='�����������Ѱ�94Ԫ��100Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=95	 where offer_name='�����캽150Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	96	 where offer_name='�ҵ�e��e6-96 �ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	99	 where offer_name='ȫ��������e9-ADSL2M����ʱ99�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='�ֻ�������100Ԫ��2G';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='T2���߿��100�ײͣ�Ԥ��6���£�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='T2���߿��100�ײͣ���Ʒ����';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='���߿������Ʒ�ײ�100Ԫ/�£�OCS��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='���߿������Ʒ�ײ�100Ԫ/�£�2GB��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='T2���߿��100�ײͣ���Ʒ��600��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	120	 where offer_name='�����������Ѱ�114Ԫ��120Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	119	 where offer_name='��e9-4M����ʱ119�ײͣ�ȫ���Ѱ棩';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=119		 where offer_name='��e9-4M����ʱ119�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score= 119		 where offer_name in ('��ŵ����119Ԫ����1M','��ŵ����119Ԫ����2M','��ŵ����119Ԫ����3M');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	129	 where offer_name='201108�����129Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	129	 where offer_name='OCS201108������129Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	150	 where offer_name='�����������Ѱ�144Ԫ��150Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=145	 where offer_name='�����캽250Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	149	 where offer_name='��e9-4M����ʱ149�ײͣ�ȫ���Ѱ棩';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	189	 where offer_name='201108�����189Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=195	 where offer_name='�����캽350Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	200	 where offer_name='���߿������Ʒ�ײ�200Ԫ/�£�OCS��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	200	 where offer_name='T2���߿��200�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=245	 where offer_name='�����캽450Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	259	 where offer_name='����e9-8M����ʱ259�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	300	 where offer_name='���߿������Ʒ�ײ�300Ԫ/�£�OCS��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	300	 where offer_name='T2���߿��300�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	300	 where offer_name='T2���߿��300�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	389	 where offer_name='201108�����389Ԫ';

-- �������ֻ�,������Ҳ������,�����Ǳ��Ѿ�������119����,�ֻ����ټ�119����.
--update tmp_PACKGE_NAME_AREA_FEEMONTH set score=-99 where offer_comp_instance_id in (select offer_comp_instance_id from tmp_fd2_AREA_FEEMONTH);
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=0 where adsl_new is not null;

--�Լ�,����E9�ײ�, �����еĿ��Ҳ��������,���ײͻ��ֲ�Ӧ����
--ȡ���ײͱ�ʶ,ȡͬ�ײ��µ��ֻ�����,���ж����Ƿ��ڱ�������

-- 1.���������ƻ�����30�ֵ����ܻ������� 
update tmp_PACKGE_NAME_AREA_FEEMONTH set intell_flag=1 where offer_name like '%%����������';
-- 2.�����ֻ���"���ܻ��Żݹ���ŵ25Ԫ"������,����Ϊ���ܻ�.  
--֮ǰҪ�ȵ��ϼ�-����ű�-�������25Ԫ�ֻ���redo
-- update tmp_PACKGE_NAME_AREA_FEEMONTH set intell_flag=1 where acc_nbr in 
-- (select acc_nbr from tmp_g9_cdma_25_33_201202 )
--;  --���䲻��֧��,ֻ������ʱ��
create temp table tgm_ls_2 as select a.*, case when b.acc_nbr is not null then 1 else 0 end ���ܻ��Żݹ� from tmp_PACKGE_NAME_AREA_FEEMONTH a
left join tmp_g9_cdma_25_33_201202 b on a.acc_nbr=b.acc_nbr;
drop table tmp_PACKGE_NAME_AREA_FEEMONTH ;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select * from tgm_ls_2;
update tmp_PACKGE_NAME_AREA_FEEMONTH set intell_flag=1, enable_flag=1 where ���ܻ��Żݹ�=1;
-- �������ֻ���,3G�ֻ���ʶҲ��Ϊ1
update tmp_PACKGE_NAME_AREA_FEEMONTH set enable_flag=1 where intell_flag=1;

--,phone.enable_flag, phone.intell_flag
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=score+20 where enable_flag=1 and (score<>0  or adsl_new is not null) and offer_name not like '%%���߿��%%' and offer_name not like '%%T2%%';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=score+10 where intell_flag=1 and (score<>0 or adsl_new is not null) and offer_name not like '%%���߿��%%' and offer_name not like '%%T2%%';
-- ��ѡ����Ӧ���Ƶ��������ܻ���3G�ֻ�����֮��,����һ���ֻ��ظ��㽱��.

update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	1	 where offer_name='ȫҵ���ѡ���Ű�1Ԫ��15��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	3	 where offer_name='ȫҵ���ѡ���Ű�3Ԫ��50��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	5	 where offer_name='OCSȫҵ���ѡ���Ű�5Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	20	 where offer_name='�ֻ�������20Ԫ��150M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	10	 where offer_name='ȫҵ���ѡ���Ű�10Ԫ��200��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	20	 where offer_name='��������Խ�20Ԫ�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=5		 where offer_name='ȫҵ���ѡ���Ű�5Ԫ��100��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=10		 where offer_name='ȫҵ�񳤻���10Ԫ/�£�������Ч��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	10	 where offer_name='�ֻ�������10Ԫ��60M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	5	 where offer_name='�ֻ�������5Ԫ��30M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	5	 where offer_name='ȫҵ��5Ԫ���ſ�ѡ����������Ч��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	5	 where offer_name='ȫҵ���ѡ���Ű�5Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	30	 where offer_name='�ֻ�������30Ԫ��300M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	5	 where offer_name='OCS�ֻ�������5Ԫ��30M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	10	 where offer_name='����칫���ܰ����ɰ󶨣�';

-- �������: ���ܻ��Żݹ���(�����25Ԫ��ŵ������),Ӧͳһ��30�����ܻ�����
-- ��С�����: �����ƻ�Ӧȫ����30��
-- ë��ָ��: ��������,6Ԫ��144���Ѱ��ֿ�����ֵĻ�, ���ܻ������ظ���

--����Ҫ����: ��C�ںϼӷ�

--����: ����Ϊ����̻��ϻ���,��������20��
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=score+20 where user_postn_arrive_num>0;
select '33';
--* from tmp_g2_33_201110;
