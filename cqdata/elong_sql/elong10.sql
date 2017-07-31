--�ᶼ76�ײ��嵥
--76�ײ�Ϊ�������: �̻����58�ײ�, ����30�ײ�,ʵ��18,����76, ������������2M,�ϻ�

--1.��58�ײ��嵥, 7��1���Ժ󿢹���
--2.����ͬ��ͬ���µ��ֻ�,���Ƿ�������30�ײ�
--3.����ÿ���ϵ������Ż�, ���Ż�Ӧͬʱ��һ���ֻ�����,��֤���ֻ��Ǻϻ�,��������.

--��ȡE8-58�嵥(�̻�,���,��ͬ��)
--��ȡ����30�������嵥(�ֻ�,����,��ͬ��)
--������ͬ��ͬ��.
drop table if exists tgm_t1;
create temp table tgm_t1 as 
select a.acc_nbr,a.serv_id, a.product_id, a.mkt_cust_code, a.completed_date,b.offer_comp_id, b.offer_comp_instance_id,
b.prod_offer_inst_id, b.prod_offer_id, prod_offer_inst_created_date
, a.down_velocity, a.com_grid_id
 from ds_chn_prd_serv_mkt_AREA_LAST_DAY a 
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='00A'

where 
a.product_id in ('102030001','208511296')
--and a.acc_nbr='023-02370722812'
--and b.offer_comp_id in ('334603' --334603	334604	e8-2M-58����ʱ�ײͣ�12�棩_������
--,'333006' --333006	333007	�����C����2M����ŵ30Ԫ��_������
--319557	332229	�����������Ѱ�24Ԫ��30Ԫ
--319557	334891	�����������Ѱ�24Ԫ��30Ԫ
and b.prod_offer_id in ('334604', '333007', '332229', '334891'
)
--distributed by a.acc_nbr
;

--select * from tgm_t1 order by offer_comp_instance_id;
--58�嵥
--��58, ������30���κϻ����ٵ�
--��58, ������, ���ֻ�����������30Ԫ��
--��58, ������, ��������30Ԫ�ֻ��ϻ���
--��58, ������, ���ֻ��ϻ�,����������30Ԫ��

--select 
--count(distinct acc_nbr)
--from tgm_t1 where 
--product_id='102030001'
-- and 
--offer_comp_id='334603'
--;

--437
--410  ����410���������

-- �޿����C���ٷ�����58�ײ�
--select a.acc_nbr,b.acc_nbr from tgm_t1 a 
--left join tgm_t1 b on a.serv_id=b.serv_id and b.offer_comp_id='333006'
--left join tgm_t1 b on a.offer_comp_instance_id=b.offer_comp_instance_id and b.product_id='102030001' and b.
--where a.product_id='102030001' and a.offer_comp_id='334603' and b.acc_nbr is null
--order by a.acc_nbr;

-- ������, ��C�����벻������30��
create temp table tgm_t2 as 
select a.acc_nbr "E8-58�������", a.completed_date �������ʱ��, a.prod_offer_inst_created_date E8����ʱ��, 
case when b.acc_nbr is null then '' else '��' end  �����C����, b.prod_offer_inst_created_date ��C���ٿ���ʱ��, 
c.acc_nbr ���ٰ��ֻ�����, c.completed_date �ֻ�����ʱ��, 
case when d.acc_nbr is null then '' else '����' end �ֻ��ײͷ�������30, d.prod_offer_inst_created_date ��������ʱ��
 from tgm_t1 a 
left join tgm_t1 b on a.serv_id=b.serv_id and b.offer_comp_id='333006'
left join tgm_t1 c on b.offer_comp_instance_id=c.offer_comp_instance_id and c.product_id='208511296' --and c.offer_comp_id='332229'
left join tgm_t1 d on c.serv_id=d.serv_id and d.offer_comp_id='319557'
where a.product_id='102030001' and a.offer_comp_id='334603' 
order by a.acc_nbr;
----------------------------
---------------------------


drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select * from tgm_t2;
/*
select
	e.MKT_CHANNEL_name Ӫ����Ӫά��,
	e.MKT_REGION_NAME Ӫ������������,
	e.MKT_GRID_NAME  Ӫ��������,
	k.COM_CHANNEL_NAME ά����Ӫά��,
	k.COM_GRID_NAME ά��������,
	s.serv_id,
	s.acc_nbr �û�����,
	s.user_name �û���,
	s.mkt_cust_code ��ͬ��,
	s.prod_addr �û���ַ,
	s.DOWN_VELOCITY ���д���,
	d.PRODUCT_NAME ��Ʒ�ļ�����,
	to_char(a.OFFER_COMPLETED_DATE,'YYYY-MM-DD') �ײͿ���ʱ��,
	to_char(a.offer_eff_date,'YYYY-MM-DD') �ײ���Чʱ��,
	a.comp_offer_id ��Ʒ��id,
	b.offer_comp_type_desc6 �����Ż�����,
	'' ��������,
	c.staff_code ������,
	c.staff_desc ������

from tgm_t2 a 
left join DIM_WD_OFFER_NEW_DIR_SECOND as b
on a.COMP_OFFER_ID = b.offer_comp_type_id6
left join DIM_CRM_STAFF as c
on a.OPER_ID=c.party_role_id		--��������Ա��
left join DIM_PRODUCT as d
on s.PRODUCT_ID = d.PRODUCT_ID		--������Ʒ�ļ�����
left join DIM_ZONE_area as e
on s.MKT_GRID_ID  = e.MKT_GRID_ID 	--����Ӫ����
left join DIM_ZONE_COMM as k
on s.COM_GRID_ID  = k.COM_GRID_ID 	--����ά����

where b.OFFER_COMP_TYPE_ID6 in(

'330424',--�������ڶ����ֻ�����1M
'330516',--�������������ֻ�����1M
'330518',--���������Ĳ��ֻ�����1M
'330525',--���������岿�ֻ�����1M
'330529',--��������װ�ڶ��������ֻ�����2M
'330531',--��������װ�����������ֻ�����2M

'330675',--��ŵ����119Ԫ����1M
'330398',--��ŵ����119Ԫ����2M
'330677',--��ŵ����119Ԫ����3M
'332319',--��ŵ����119Ԫ���ٵ�4M
'330669',--��ŵ����149Ԫ����1M
'330395',--��ŵ����149Ԫ����2M
'330671',--��ŵ����149Ԫ����3M
'332317',--��ŵ����149Ԫ���ٵ�4M

'334275',--�����ܻ��������2M(1��)
'334719',--�����ܻ��������2M(1��)(�ڶ����ֻ�)
'334325',--OCS�����ܻ��������2M(1��)
'334721',--OCS�����ܻ��������2M(1��) (�ڶ����ֻ�)

'331867',--��������û���ŵ���ٰ�

'333001',--�����C����1M����ŵ20Ԫ����������
'333006',--�����C����2M����ŵ30Ԫ����������
'333008',--�����C����3M����ŵ50Ԫ����������
'334282',--OCS�����C����1M����ŵ20Ԫ����������
'334291',--OCS�����C����2M����ŵ30Ԫ����������
'334293',--OCS�����C����3M����ŵ50Ԫ����������

'333212',--�������512K���ܷ�1Ԫ��Լ����
'332995',--�������1M���ܷ�5Ԫ��Լ����
'333353',--�������1M���ܷ�10Ԫ��Լ����
'332992',--�������2M���ܷ�5Ԫ��Լ����
'333351',--�������2M���ܷ�10Ԫ��Լ����
'333357',--�������2M���ܷ�20Ԫ��Լ����
'333120',--�������3M���ܷ�10Ԫ��Լ����
'333344',--�������3M���ܷ�20Ԫ��Լ����

'331069',--��װiTV�������1M
'333040',--��װiTV����2M�Ż�Ӧ������
'333817',--��װiTV�������4MӦ������

'330766',--Ԥ��96Ԫ����1M(��ɽ)Ԥ������
'330769',--Ԥ��192Ԫ����2M(��ɽ)Ԥ������
'332900',--���������ٰ���96-1M��Ԥ������
'332903',--���������ٰ���192-2M��Ԥ������
'333373',--Ԥ��500Ԫ�������1MԤ������
'333368',--Ԥ��500Ԫ�������1M(OCS)Ԥ������
'333375',--Ԥ��1000Ԫ�������2MԤ������
'333371',--Ԥ��1000Ԫ�������2M(OCS)Ԥ������

'334208', --	ƽ��FTTH�ײ����ʷ�����1.5M��
'334121', --	ƽ��FTTH�ײ����ʷ�����1M��
'334126', --	ƽ��FTTH�ײ����ʷ�����4M��
'334212', --	ƽ��FTTH�ײ����ʷ�����3M��
'334123', --	ƽ��FTTH�ײ����ʷ�����2M��
'334118', --	ƽ��FTTH�ײ����ʷ�����512K��
'334210', --	ƽ��FTTH�ײ����ʷ�����2.5M��

'332046',--�����캽�����ײͿ�����ٰ���������
'334695'--�����ײͿ������3M��������
)
and d.PRODUCT_NAME in ( 'ADSLע���鲦����')
order by �ײͿ���ʱ�� desc
;
update tmp_PACKGE_NAME_AREA_FEEMONTH set ��������='����������' where ��Ʒ��id in (
'330424',--�������ڶ����ֻ�����1M
'330516',--�������������ֻ�����1M
'330518',--���������Ĳ��ֻ�����1M
'330525',--���������岿�ֻ�����1M
'330529',--��������װ�ڶ��������ֻ�����2M
'330531');--��������װ�����������ֻ�����2M

update tmp_PACKGE_NAME_AREA_FEEMONTH set ��������='��ŵ119����' where ��Ʒ��id in (
'330675',--��ŵ����119Ԫ����1M
'330398',--��ŵ����119Ԫ����2M
'330677',--��ŵ����119Ԫ����3M
'332319',--��ŵ����119Ԫ���ٵ�4M
'330669',--��ŵ����149Ԫ����1M
'330395',--��ŵ����149Ԫ����2M
'330671',--��ŵ����149Ԫ����3M
'332317');--��ŵ����149Ԫ���ٵ�4M

update tmp_PACKGE_NAME_AREA_FEEMONTH set ��������='�����ܻ�����' where ��Ʒ��id in (
'334275',--�����ܻ��������2M(1��)
'334719',--�����ܻ��������2M(1��)(�ڶ����ֻ�)
'334325',--OCS�����ܻ��������2M(1��)
'334721');--OCS�����ܻ��������2M(1��) (�ڶ����ֻ�)

update tmp_PACKGE_NAME_AREA_FEEMONTH set ��������='�����û�����' where ��Ʒ��id in (
'331867');--��������û���ŵ���ٰ�

update tmp_PACKGE_NAME_AREA_FEEMONTH set ��������='�����C����' where ��Ʒ��id in (
'333001',--�����C����1M����ŵ20Ԫ����������
'333006',--�����C����2M����ŵ30Ԫ����������
'333008',--�����C����3M����ŵ50Ԫ����������
'334282',--OCS�����C����1M����ŵ20Ԫ����������
'334291',--OCS�����C����2M����ŵ30Ԫ����������
'334293');--OCS�����C����3M����ŵ50Ԫ����������

update tmp_PACKGE_NAME_AREA_FEEMONTH set ��������='��Լ����' where ��Ʒ��id in (
'333212',--�������512K���ܷ�1Ԫ��Լ����
'332995',--�������1M���ܷ�5Ԫ��Լ����
'333353',--�������1M���ܷ�10Ԫ��Լ����
'332992',--�������2M���ܷ�5Ԫ��Լ����
'333351',--�������2M���ܷ�10Ԫ��Լ����
'333357',--�������2M���ܷ�20Ԫ��Լ����
'333120',--�������3M���ܷ�10Ԫ��Լ����
'333344');--�������3M���ܷ�20Ԫ��Լ����

update tmp_PACKGE_NAME_AREA_FEEMONTH set ��������='��װiTV����' where ��Ʒ��id in (
'331069',--��װiTV�������1M
'333040',--��װiTV����2M�Ż�Ӧ������
'333817');--��װiTV�������4MӦ������

update tmp_PACKGE_NAME_AREA_FEEMONTH set ��������='Ԥ������' where ��Ʒ��id in (
'330766',--Ԥ��96Ԫ����1M(��ɽ)Ԥ������
'330769',--Ԥ��192Ԫ����2M(��ɽ)Ԥ������
'332900',--���������ٰ���96-1M��Ԥ������
'332903',--���������ٰ���192-2M��Ԥ������
'333373',--Ԥ��500Ԫ�������1MԤ������
'333368',--Ԥ��500Ԫ�������1M(OCS)Ԥ������
'333375',--Ԥ��1000Ԫ�������2MԤ������
'333371');--Ԥ��1000Ԫ�������2M(OCS)Ԥ������

update tmp_PACKGE_NAME_AREA_FEEMONTH set ��������='��������' where ��Ʒ��id in (
'332046',--�����캽�����ײͿ�����ٰ���������
'334695');--�����ײͿ������3M��������

update tmp_PACKGE_NAME_AREA_FEEMONTH set ��������='FTTHǨת����' where ��Ʒ��id in (
'334208', --	ƽ��FTTH�ײ����ʷ�����1.5M��
'334121', --	ƽ��FTTH�ײ����ʷ�����1M��
'334126', --	ƽ��FTTH�ײ����ʷ�����4M��
'334212', --	ƽ��FTTH�ײ����ʷ�����3M��
'334123', --	ƽ��FTTH�ײ����ʷ�����2M��
'334118', --	ƽ��FTTH�ײ����ʷ�����512K��
'334210'); --	ƽ��FTTH�ײ����ʷ�����2.5M��

*/
select '33';
--* from tmp_g2_33_201110;
