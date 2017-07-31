-- �ᶼ���������嵥
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select a.*
--,b.offer_comp_id, prod_offer_id 
,c.offer_name, c_prod.offer_name prod_name
,0.0 score
from 
(
select a.*, b.offer_comp_id, b.prod_offer_id, offer_comp_instance_id
from      (
select acc_nbr, user_name, a.com_grid_id, jjx_code, user_grp_type
, down_velocity,  completed_date, remove_date, serv_id
, com.com_channel_name, com.com_grid_name
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  serv_num=1
and product_id=102030001
and completed_date between '2012-01-01' and '2012-03-10'
-- or remove_date between '2012-01-01' and '2013-01-01'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state='00A'
--and case when a.completed_date>'2012-01-01' then b.prod_offer_inst_state='00A' else b.prod_offer_inst_state<>'00A' end
 and b.offer_comp_id not in (-99, 0
-- ,325038  --ȫ����������������1M�� ���ٵ��������, ��һ�������п���������������2M�Ļ����Ż���Ʒ
 )
    ) a
left join dim_crm_product_offer c on a.offer_comp_id=c.offer_id 
left join dim_crm_product_offer c_prod on a.prod_offer_id=c_prod.offer_id 
order by a.acc_nbr

;
--������Ϊ2M���£����ײ�Ϊ426�����������ܲ�����ֵ��嵥��ͳ��
--�����ڻ�������������Ϊ0�Ĺ۲�״����
--select * from tmp_PACKGE_NAME_AREA_FEEMONTH where down_velocity in ('1M','512K','640K', '1.5M') or offer_comp_id in (121244);

update tmp_PACKGE_NAME_AREA_FEEMONTH set score=888/12 where offer_name='��08����e8��2MAD��װ888Ԫ���ײͣ�����)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=288/48 where offer_name='2M*ѧ���ڼ�B288Ԫ(����+ʱ�����)';
-- ѧ���ڼ����ǻ��4����¼,Ҫɾ�Ƚ��鷳,�ɴ�ÿ����1/4Ǯ.
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='��08����e8��2MAD��װ78Ԫ���ײͣ�����)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='�޹̻�ADSL 2M����ʱ78�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='��08����e8��2M��ADת78Ԫ���ײͣ�����)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='��������e8-2M�������78Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=88 where offer_name='��������e8-2M�������88Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=988/12 where offer_name='��������e8-2M�������988Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=88 where offer_name='2M��������88Ԫ/���ײͳ�ŵ24���£����ڣ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=88 where offer_name='2M��������88Ԫ/��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=89 where offer_name='ȫ��������e9-ADSL2M����ʱ89�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=99 where offer_name='ȫ��������e9-ADSL2M����ʱ99�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=99 where offer_name='ȫ���֣�e9���ײ�2M����ʱ99Ԫ�ײͣ����أ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=118 where offer_name='�ҵ�e��e8-4M118�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=119 where offer_name='��e9-4M����ʱ119�ײ�';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=119 where offer_name in ( '��ŵ����119Ԫ����1M' ,'��ŵ����119Ԫ����2M' ,'��ŵ����119Ԫ����3M');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=119 where offer_name='��e9-4M����ʱ119�ײͣ�ȫ���Ѱ棩';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=149 where offer_name='��e9-4M����ʱ149�ײͣ�ȫ���Ѱ棩';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=688/12 where offer_name='e��1M688Ԫ���ײͣ��Ż���' and down_velocity not in ('1M','1.5M');

--��ί��֯�� ӦΪ����ר��,ÿ��65Ԫ
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=65 where offer_name='ADSL�鲦Э��۵�Ԫ[ADSL��������]' and user_name='�й��������ᶼ��ίԱ����֯��';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=198 where offer_name='ADSL�鲦Э��۵�Ԫ[ADSL��������]' and user_name='���������ɷ��ز��������޹�˾';


--���� ���ֿ���ADSLЭ���,ϵͳδ���Զ�ȡ�÷�ֵ
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where acc_nbr in (
--�ᶼ��ס�������𵥿���5����78/�£���ӷ֣�лл 
'023-02370702650',
'023-02370705531',
'023-02370702652',
'023-02370723886',
'023-02370722190',
--�ᶼ����ִ����ӵ�����1����78/�£���ӷ֣�лл 
'023-02370702583',
--�ᶼ�ع���������������6����78/�£���ӷ� 
'023-02370702702',
'023-02370702646',
'023-02370702658',
'023-02370702798',
'023-02370702332',
'023-02370710780'
)
; 
--����װͬʱ�ְ����˳�ŵ119����4M��serv_id�����.
create temp table tmp_ls1 as select serv_id from tmp_PACKGE_NAME_AREA_FEEMONTH where offer_name in ('��ŵ����119Ԫ����1M' ,'��ŵ����119Ԫ����2M' ,'��ŵ����119Ԫ����3M');

create temp table tmp_ls2 as 
select a.*, b.serv_id tishu from tmp_PACKGE_NAME_AREA_FEEMONTH a 
left join tmp_ls1 b on a.serv_id=b.serv_id;
--������װ�����ײ�ͬʱ�ְ�����ŵ119�����,����Ӧ��119���ּ���
update tmp_ls2 set score=0 where tishu is not null and offer_name not in ('��ŵ����119Ԫ����1M' ,'��ŵ����119Ԫ����2M' ,'��ŵ����119Ԫ����3M') ;

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select * from tmp_ls2;
select '33';
--* from tmp_g2_33_201110;