-- �ᶼ�ֻ���ʧ�嵥
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
--create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
create temp table tgm_ls as 
select a.*
--,b.offer_comp_id, prod_offer_id 
,c.offer_name
--, c_prod.offer_name prod_name
--,0.0 score
,inst.acc_nbr adsl_del
,phone.enable_flag, phone.intell_flag
from 
(
select distinct a.*, b.offer_comp_id
,b.offer_comp_instance_id
--, b.prod_offer_id
from      (
select acc_nbr, user_name, a.com_grid_id, jjx_code, user_grp_type
, down_velocity,  completed_date, remove_date, serv_id
, com.com_channel_name, com.com_grid_name
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  serv_num<>1
and product_id=208511296
and remove_date between '2012-01-01' and '2022-01-01'
and completed_date<'2012-01-01'
-- or remove_date between '2012-01-01' and '2013-01-01'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state<>'00A'
 and  b.offer_comp_id not in ( -99, 0 
, 317758  --���顿���߿��EVDO����ʶ��
,327766 -- 2011����WLAN����10Сʱ��CDMA��
,331444 -- 3G���繺3G��200M
,331494  --e���ֻ��������ȫ���Ѱ棩
,331598 --OCS��ŵ�Żݹ���25Ԫ��
,331594 --��ŵ�Żݹ���25Ԫ��
--,317056 --ȫҵ�񳤻���10Ԫ/�£�������Ч�� Ӧ��10����
,329522 --�ֻ�����30M���
,327917 --�ֻ�������10Ԫ��60M  Ӧ��10����
,327914 --�ֻ�������5Ԫ��30M Ӧ��5����
--,331963 --�����캽90Ԫ����������
,331949 --�����캽�����ֻ��ײ�39����, �������η��治�ܱ����ײͰ�����
,331558 --���ܻ�����������
,314547	--E6�ƶ��ؼ��ײ�V����
,319198	--����ײ�136��81600����
,321877	--�����������3���£�
,317876	--��������ֵ��ѡ������5Ԫ��
,108885	--�󸶷�_����V�����л���
,315656	--�ֻ��̻��弶V��
,315481	--��������UIM����������
,319389	--�������������5Ԫ���ѣ����ŷ�չ�û���
,330352	--������Ѷȫ�ܿ�1Ԫ��
,317022	--����ײ�99��39600����
,315482	--[IVPN]���ڳ�Ա�������
,324078	--������Ѷ������
,316014	--[e6-11]e6-11ÿ������10Ԫ��24���£�[��133/153]
,321560	--ȫҵ���ѡ���Ű�1Ԫ��15��
 )
    ) a
left join dim_crm_product_offer c on a.offer_comp_id=c.offer_id 
--left join dim_crm_product_offer c_prod on a.prod_offer_id=c_prod.offer_id 
--order by a.acc_nbr
--distribute by acc_nbr
--����3G���ܻ�����ȡ��3G�����ܻ���ʶ
left join tmp_fd5_AREA_FEEMONTH inst on a.offer_comp_instance_id=inst.offer_comp_instance_id
left join DS_PRD_SERV_3G_LAST_DAY phone on a.serv_id=phone.serv_id
;
--������Ϊ2M���£����ײ�Ϊ426����������ܲ�����ֵ��嵥��ͳ��
--�����ڻ�������������Ϊ0�Ĺ۲�״����
--select * from tmp_PACKGE_NAME_AREA_FEEMONTH where down_velocity in ('1M','512K','640K', '1.5M') or offer_comp_id in (121244);


create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select *, 0 score from  tgm_ls ;
drop table tgm_ls;
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	6	 where offer_name in ('�������6Ԫ�ײ�', '�Żݹ���6Ԫ��ŵ');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	6	 where offer_name='OCS������ͨ��6Ԫ�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	6	 where offer_name='OCS������ͨ��6Ԫ�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	10	 where offer_name='ȫ����������C��װ10Ԫ�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	16	 where offer_name='������800M16�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	18	 where offer_name='����������18�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	19	 where offer_name='OCS������19�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	19	 where offer_name='Ԥ����T9�ײ�19Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	19	 where offer_name='������19�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	19	 where offer_name='T9�ײ�19Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	26	 where offer_name='E6-11������26Ԫ�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	26	 where offer_name='����������26�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	35	 where offer_name='С��ͨ���û�35Ԫ�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	39	 where offer_name='������39�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	39	 where offer_name='OCS������39�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	39	 where offer_name='T9�ײ�39Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	45	 where offer_name='�����캽50Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	46	 where offer_name='�ҵ�e��e6-46�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	49	 where offer_name='201108������49Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=49		 where offer_name='OCS201108������49Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	59	 where offer_name='OCS201108�����59Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	59	 where offer_name='201108�����59Ԫ';

update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	50	 where offer_name='���߿������Ʒ�ײ�50Ԫ/�£�OCS��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	50	 where offer_name='���߿������Ʒ�ײ�50Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	55	 where offer_name='С��ͨ���û�55Ԫ�ײ�(�޲���)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	65	 where offer_name='�����캽90Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	69	 where offer_name='201108������69Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	89	 where offer_name='201108�����89Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	89	 where offer_name='ȫ��������e9-ADSL2M����ʱ89�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	89	 where offer_name='OCS201108�����89Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=95	 where offer_name='�����캽150Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	96	 where offer_name='�ҵ�e��e6-96 �ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	99	 where offer_name='ȫ��������e9-ADSL2M����ʱ99�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='T2���߿��100�ײͣ�Ԥ��6���£�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='���߿������Ʒ�ײ�100Ԫ/�£�OCS��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='���߿������Ʒ�ײ�100Ԫ/�£�2GB��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	119	 where offer_name='��e9-4M����ʱ119�ײͣ�ȫ���Ѱ棩';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=119		 where offer_name='��e9-4M����ʱ119�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score= 119		 where offer_name in ('��ŵ����119Ԫ����1M','��ŵ����119Ԫ����2M','��ŵ����119Ԫ����3M');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	129	 where offer_name='201108�����129Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=145	 where offer_name='�����캽250Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	149	 where offer_name='��e9-4M����ʱ149�ײͣ�ȫ���Ѱ棩';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	189	 where offer_name='201108�����189Ԫ';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=195	 where offer_name='�����캽350Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	200	 where offer_name='���߿������Ʒ�ײ�200Ԫ/�£�OCS��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	200	 where offer_name='T2���߿��200�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=245	 where offer_name='�����캽450Ԫ����������';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	300	 where offer_name='���߿������Ʒ�ײ�300Ԫ/�£�OCS��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	300	 where offer_name='T2���߿��300�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	26	 where offer_name in ('[e6-11]26Ԫ��150���ӣ��Ϲ̻�+���ֻ���[��153]','�������ֻ��棭26�ײ͹���150����');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	46 where offer_name in ('e6�ƶ��ؼ�46�ײͣ��Ϲ̻������ֻ���','�ƶ��ؼ�46Ԫ�ײͣ��ֻ��̻��棩');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	26 where offer_name in ('[e6-11]26Ԫ��150���ӣ��Ϲ̻�+���ֻ���[��133/153]','�ƶ��ؼ�26Ԫ�ײ���150���ӣ��ֻ��̻��棩','����ؼ�E6-26Ԫ�ײͣ��ֻ�+�̻���');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=96 where offer_name='�ƶ��ؼ�96Ԫ�ײͣ��ֻ��̻��棩';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=99	 where offer_name in ('ȫ���֣�e9���ײ�2M����ʱ99Ԫ�ײͣ����أ����ϣ�','��e9�ײ�2M����ʱ99Ԫ�ײͣ����أ�');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=100	 where offer_name='�̼�����X100';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=89	 where offer_name='����3G�����89�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=189	 where offer_name='T1����189�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=100	 where offer_name='�̼�����T100';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=136	 where offer_name='����ͨ���ֻ�+�̻���136Ԫ�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=129	 where offer_name='T3����129�ײͣ����û�������Ч��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=49	 where offer_name='T3����49�ײͣ����û�������Ч��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=89	 where offer_name='T3����89�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=6	 where offer_name='OCS�������ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=30	 where offer_name='ȫ��������30Ԫ�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=5	 where offer_name='����Ʒ����T4����5�ײ�';

update tmp_PACKGE_NAME_AREA_FEEMONTH set score=-score;

--�Լ�,����E9�ײ�, �����еĿ��Ҳ��������,���ײͻ��ֲ�Ӧ����
--ȡ���ײͱ�ʶ,ȡͬ�ײ��µ��ֻ�����,���ж����Ƿ��ڱ�������
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=0 where adsl_del is not null;

--,phone.enable_flag, phone.intell_flag
--������ʧ�û�,�Ƿ�Ҳ��3G�ֻ�,�����ֻ�����?
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=score-20 where enable_flag=1 and offer_name not like '%%T2%%' and offer_name not like '%%���߿��%%' and score<>0;
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=score-10 where intell_flag=1 and offer_name not like '%%T2%%' and offer_name not like '%%���߿��%%' and score<>0;

--����Ҫ����: ��C�ںϼӷ�
select '33';
--* from tmp_g2_33_201110;
