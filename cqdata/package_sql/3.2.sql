/*һ��ȫ���滻DS_CHN_PRD_SERV_AREA_201108ΪDS_CHN_PRD_SERV_AREA_FEEMONTH
����ȫ���滻DS_CHN_PRD_OFFER_COMP_201108ΪDS_CHN_PRD_OFFER_COMP_FEEMONTH
����ȫ���滻DS_ACT_ACCT_ITEM_201108ΪDS_ACT_ACCT_ITEM_FEEMONTH
*/
--ִ�п�ʼ
--PPT2
--  drop table if exists csttl;
create temporary table csttl as
select distinct a.serv_id,c.offer_comp_instance_id,b.type_name,e.OFFER_COMP_TYPE_DESC1 offerd,OFFER_COMP_TYPE_DESC4,OFFER_COMP_TYPE_DESC6
from 
DS_CHN_PRD_SERV_AREA_FEEMONTH a,--�˴����û�������
DIM_PRODUCT b,DS_CHN_PRD_OFFER_COMP_FEEMONTH c,--�˴����ײͷ���������
DIM_CRM_PRODUCT_OFFER d,DIM_WD_OFFER_NEW_DIR_SECOND e 
where 
a.product_id=b.product_id 
and 
b.type_name in ('ע�Ღ����','��ͨ�绰','�ƶ�ҵ��','��ѶӦ�ò�Ʒ') 
and 
a.state='00A' 
and
a.SERV_NUM='1'
and 
a.serv_id=c.serv_id
and 
c.COMP_OFFER_ID=d.offer_id
and 
d.offer_name=OFFER_COMP_TYPE_DESC6
and 
c.OFFER_EXP_DATE>=(Values ((SELECT date_trunc('month', TIMESTAMP 'FEEMONTH'))))
and 
d.offer_kind='C';--�˴��ķ���ʧЧʱ�䣬Ϊ�������ڴ��³�
--ִ�н���

--ִ�п�ʼ
--PPT2���ں��ײ��У������ļ���Ʒ����������������ļ���Ʒ�ܸ���
--  drop table if exists cstt2;
create temporary table cstt2 as
select distinct type_name,count(type_name) tn from 
csttl where offer_comp_instance_id in 
(
select offer_comp_instance_id from
(select distinct offer_comp_instance_id,count(distinct serv_id) sd from csttl group by 1) a where sd>1
) group by 1;
--  drop table if exists cstt22;
create temporary table cstt22 as
select distinct b.type_name,count(distinct a.serv_id) sd2  
from 
DS_CHN_PRD_SERV_AREA_FEEMONTH a,DIM_PRODUCT b
where 
a.state='00A' 
and
a.SERV_NUM='1'
and 
a.product_id=b.product_id
and 
b.type_name in ('ע�Ღ����','��ͨ�绰','�ƶ�ҵ��','��ѶӦ�ò�Ʒ') group by 1;
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct a.type_name �ļ���Ʒ��,a.tn �ں��ײ����豸����,b.sd2 ���豸���� from cstt2 a,cstt22 b where a.type_name=b.type_name;
--ִ�н�����ȡ���ճ����EXCEL��

--ִ�п�ʼ
--PPT2����Ʒ�����ں��ײ���Ʒ������
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct a.һ���ײ�Ŀ¼,a.�ں��ײ������Ʒ������,b.��Ʒ���ܸ��� from
(
--�ں��ײ������Ʒ������
select distinct substring(offerd from 1 for 5) һ���ײ�Ŀ¼,count(distinct offer_comp_instance_id) �ں��ײ������Ʒ������ from 
csttl where offer_comp_instance_id in 
(
select offer_comp_instance_id from
(select distinct offer_comp_instance_id,count(distinct serv_id) sd from csttl group by 1) a where sd>1
) group by 1) a,
(--��Ʒ���ܸ���
select distinct substring(offerd from 1 for 5) һ���ײ�Ŀ¼,count(distinct offer_comp_instance_id) ��Ʒ���ܸ��� from csttl group by 1 order by 1
) b where a.һ���ײ�Ŀ¼=b.һ���ײ�Ŀ¼;
select * from tmp_PACKGE_NAME_AREA_FEEMONTH limit 10;

--ִ�н�����ȡ���ճ����EXCEL��

--ִ�п�ʼ
--PPT3
--һ���ײ����͸���
-- drop table if exists cstt3;
create temporary table cstt3 as
select distinct offerd һ���ײ����,count(distinct offer_comp_instance_id) ��Ʒ������ 
from 
csttl 
group by 1;
-- drop table if exists cstt4;
create temporary table cstt4 as
select distinct a.offerd һ���ײ����,sum(amount) ��Ʒ���¹��豸����
from 
csttl a,DS_ACT_ACCT_ITEM_FEEMONTH b
where 
a.serv_id=b.serv_id
group by 1;
--һ���ײ͸����豸����ARPUֵ
select distinct a.һ���ײ����,a.��Ʒ������,b.��Ʒ���¹��豸����,b.��Ʒ���¹��豸����/a.��Ʒ������ arpu
from 
cstt3 a,cstt4 b
where 
a.һ���ײ����=b.һ���ײ����;
--ִ�н�����ȡ���ճ����EXCEL��

--ִ�п�ʼ
--PPT3
--�ļ��ײ����͸������ҵ�E���࣬���Ҫ����������������offerd='XXXXXXX�ײ�'�������Ҫ�ٽ�һ�����������ײͣ��뽫OFFER_COMP_TYPE_DESC4��ΪOFFER_COMP_TYPE_DESC6
-- drop table if exists cstt5;
create temporary table cstt5 as
select distinct OFFER_COMP_TYPE_DESC4 �ļ��ײ����,count(distinct offer_comp_instance_id) ��Ʒ������ 
from 
csttl 
where 
offerd='�ҵ�e��Ʒ���ײ�����Ʒ'
group by 1;
-- drop table if exists cstt6;
create temporary table cstt6 as
select distinct a.OFFER_COMP_TYPE_DESC4 �ļ��ײ����,sum(amount) ��Ʒ���¹��豸����
from 
csttl a,DS_ACT_ACCT_ITEM_FEEMONTH b
where 
a.serv_id=b.serv_id
and 
a.offerd='�ҵ�e��Ʒ���ײ�����Ʒ'
group by 1;
--�ļ��ײ�ARPUֵ
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct a.�ļ��ײ����,a.��Ʒ������,b.��Ʒ���¹��豸����,b.��Ʒ���¹��豸����/a.��Ʒ������ arpu
from 
cstt5 a,cstt6 b
where 
a.�ļ��ײ����=b.�ļ��ײ����;
--ִ�н�����ȡ���ճ����EXCEL��

select * from tmp_PACKGE_NAME_AREA_FEEMONTH limit 10;

