--ִ�п�ʼ
--���ڿͻ���ʧ�ײ�;
--drop table if exists csttl;
create temporary table csttl as
select distinct b.OFFER_COMP_TYPE_DESC6,count(distinct c.offer_comp_instance_id) oid
from 
tmp_jg_AREA_FEEMONTH a,--�������μ�֮ǰ�ű�����Ŀ����嵥��
DIM_WD_OFFER_NEW_DIR_SECOND b,
DS_CHN_PRD_OFFER_COMP_FEEMONTH c, --�ײ��±�������
DIM_CRM_PRODUCT_OFFER d
where 
a.serv_id=c.serv_id 
and 
a.service_offer_name='ע��'
and 
a.offer_comp_name=b.OFFER_COMP_TYPE_DESC6
and 
c.OFFER_EXP_DATE>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01'))))
and 
a.offer_comp_id=c.COMP_OFFER_ID
and 
a.completed_date>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01')) - interval '1 month'))
and 
a.completed_date<(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01'))))
and 
c.comp_offer_id=d.offer_id
and 
d.offer_kind='C'
group by 1
;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct OFFER_COMP_TYPE_DESC6 �ײ���������,oid ��Ʒ������ from csttl order by 2 desc limit 50;
select * from tmp_PACKGE_NAME_AREA_FEEMONTH;
--ִ�н���

