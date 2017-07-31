--���ڿͻ������ײ͸������ʷѺ������豸�ֲ���;

--ִ�п�
--drop table if exists csttq;--drop table if exists csttl;
create temporary table csttq as
select distinct b.OFFER_COMP_TYPE_DESC6,c.offer_comp_instance_id,a.product_name,a.serv_id,'����' bq
from 
tmp_jg_AREA_FEEMONTH a,--�������μ�֮ǰ�ű�����Ŀ����嵥��
DIM_WD_OFFER_NEW_DIR_SECOND b,
DS_CHN_PRD_OFFER_COMP_FEEMONTH c, --�ײ��±�������
DIM_CRM_PRODUCT_OFFER d
where 
a.serv_id=c.serv_id 
and 
a.service_offer_name='����'
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
a.serv_id in 
(
select serv_id from tmp_jg_AREA_FEEMONTH --�������μ�֮ǰ�ű�����Ŀ����嵥��
where 
completed_date>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01')) - interval '1 month'))
and 
completed_date<(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01'))))
and
service_offer_name='����'
)
and 
c.COMP_OFFER_ID=d.offer_id
and 
d.offer_kind='C';
--drop table if exists csttw;
create temporary table csttw as
select distinct b.OFFER_COMP_TYPE_DESC6,c.offer_comp_instance_id,a.product_name,a.serv_id,'���ʷ�' bq
from 
tmp_jg_AREA_FEEMONTH a,--�������μ�֮ǰ�ű�����Ŀ����嵥��
DIM_WD_OFFER_NEW_DIR_SECOND b,
DS_CHN_PRD_OFFER_COMP_FEEMONTH c, --�ײ��±�������
DIM_CRM_PRODUCT_OFFER d
where 
a.serv_id=c.serv_id 
and 
a.service_offer_name='����'
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
a.serv_id not in 
(
select serv_id from tmp_jg_AREA_FEEMONTH --�������μ�֮ǰ�ű�����Ŀ����嵥��
where 
completed_date>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01')) - interval '1 month'))
and 
completed_date<(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH01')))) 
and
service_offer_name='��װ'
)
and 
c.comp_offer_id=d.offer_id
and 
d.offer_kind='C'
;

--drop table if exists cstte;
create temporary table cstte as
select * from csttq;
insert into cstte select * from csttw;
--drop table if exists cstte1;
create temporary table cstte1 as
select distinct OFFER_COMP_TYPE_DESC6,offer_comp_instance_id,bq,
max(case when product_name like '%%�绰%%' then serv_id else null end) as gh,
max(case when product_name like '%%ע���鲦����%%' then serv_id else null end) as kd,
max(case when product_name like '%%����CDMA%%' then serv_id else null end) as sj
from 
cstte 
group by 1,2,3
order by 2,1;

--ÿ�������ײͰ��豸���ͺ��������ʷѷ��������
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct a.OFFER_COMP_TYPE_DESC6 �����ײ�,a.oid ��Ʒ������,b.�����̻�,b.�������,b.����CDMA,b.���ʷѹ̻�,b.���ʷѿ��,b.���ʷ�CDMA from 
(select distinct OFFER_COMP_TYPE_DESC6,count(distinct offer_comp_instance_id) oid from cstte1 group by 1) a,
(select distinct a.OFFER_COMP_TYPE_DESC6,sum(a.gh) �����̻�,sum(a.kd) �������,sum(a.sj) ����CDMA,sum(b.gh1) ���ʷѹ̻�,sum(b.kd1) ���ʷѿ��,sum(b.sj1) ���ʷ�CDMA from
(select OFFER_COMP_TYPE_DESC6,count(distinct gh) gh,count(distinct kd) kd,count(distinct sj) sj from cstte1 where bq='����' group by 1) a,
(select OFFER_COMP_TYPE_DESC6,count(distinct gh) gh1,count(distinct kd) kd1,count(distinct sj) sj1 from cstte1 where bq='���ʷ�' group by 1) b
where a.OFFER_COMP_TYPE_DESC6=b.OFFER_COMP_TYPE_DESC6 group by 1) b
where 
a.OFFER_COMP_TYPE_DESC6=b.OFFER_COMP_TYPE_DESC6
order by 2 desc
;
select * from tmp_PACKGE_NAME_AREA_FEEMONTH limit 20;
--ִ�н���
