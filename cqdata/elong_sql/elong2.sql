-- �ᶼ�����ֻ��嵥--��������,ר��
--��ͳ��

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH (
       id integer, item1 varchar(200), item2 varchar(200), value integer );
insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 1,'�Ż�����ͳ��', offer_name, count(*) from tmp_elong1_AREA_FEEMONTH
GROUP by  1, 2, 3 order by 1, 2, 3;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 2,'�ײ͸���', '39��Ʒ��ʵ������',count(distinct offer_comp_instance_id) from tmp_elong1_AREA_FEEMONTH where offer_name='�����캽�����ֻ��ײ�39����';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 3,'�ֻ�����', '�ֻ��������',count(distinct acc_nbr) from tmp_elong1_AREA_FEEMONTH where 1=1; --offer_name='�����캽�����ֻ��ײ�39����';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 4,'�����ֻ���������', '�����ֻ��������',count(distinct acc_nbr) from tmp_elong1_AREA_FEEMONTH where completed_date>='2012-01-01 00:00:00'; --offer_name='�����캽�����ֻ��ײ�39����';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 5,'�������ײ��ֻ�����', 'Ӧ���ײ͸������',count(distinct a.acc_nbr) from tmp_elong1_AREA_FEEMONTH a
left join (select acc_nbr from tmp_elong1_AREA_FEEMONTH where offer_name ='�����ײ��ֻ���װ��') b on a.acc_nbr=b.acc_nbr
where a.offer_name='�����캽�����ֻ��ײ�39����' 
and b.acc_nbr is null
;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 15,'���м�װ�ֻ�����', 'ֱ��ȡ�����ֻ���װ��',count(distinct a.acc_nbr) from tmp_elong1_AREA_FEEMONTH a where offer_name='�����ײ��ֻ���װ��';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 25,'���濪ʼ����ܵĴ���', '', 0;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 26,'¼39��������δѡ��������', a.acc_nbr, 0 from tmp_elong1_AREA_FEEMONTH a left join ( select acc_nbr from tmp_elong1_AREA_FEEMONTH where offer_name like '%%�����캽%%Ԫ����������') b on a.acc_nbr=b.acc_nbr
where a.offer_name = '�����캽�����ֻ��ײ�39����' and b.acc_nbr is null;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 26,'¼��������δѡ39������', a.acc_nbr, 0 from tmp_elong1_AREA_FEEMONTH a left join ( select acc_nbr from tmp_elong1_AREA_FEEMONTH where offer_name ='�����캽�����ֻ��ײ�39����') b on a.acc_nbr=b.acc_nbr
where a.offer_name like '%%�����캽%%Ԫ����������' and b.acc_nbr is null;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 27,'¼��װ����δѡ��������', a.acc_nbr, 0 from tmp_elong1_AREA_FEEMONTH a left join ( select acc_nbr from tmp_elong1_AREA_FEEMONTH where offer_name like '%%�����캽%%Ԫ����������') b on a.acc_nbr=b.acc_nbr
where a.offer_name = '�����ײ��ֻ���װ��' and b.acc_nbr is null;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 28,'¼��װ����δѡ39��������', a.acc_nbr, 0 from tmp_elong1_AREA_FEEMONTH a left join ( select acc_nbr from tmp_elong1_AREA_FEEMONTH where offer_name = '�����캽�����ֻ��ײ�39����') b on a.acc_nbr=b.acc_nbr
where a.offer_name = '�����ײ��ֻ���װ��' and b.acc_nbr is null;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 30,'����¼©��װ����', pg_concat(a.acc_nbr||'-'), offer_comp_instance_id 
from tmp_elong1_AREA_FEEMONTH a left join (select acc_nbr from tmp_elong1_AREA_FEEMONTH where offer_name='�����ײ��ֻ���װ��') b on a.acc_nbr=b.acc_nbr
where a.offer_name<>'�����ײ��ֻ���װ��' and b.acc_nbr is null
group by 1,2,4
having count(*)>1;

--ֻ�м�װ����û�����ײͺ����, ˼·Ϊ���װ�����빲39�ĺ��벻������1��
--����������治����
insert into tmp_PACKGE_NAME_AREA_FEEMONTH
select b.* from 
(select 33,'ֻ�м�װ����', a.acc_nbr, b.offer_comp_instance_id from tmp_elong1_AREA_FEEMONTH a left join (select acc_nbr, offer_comp_instance_id from tmp_elong1_AREA_FEEMONTH where offer_name='�����캽�����ֻ��ײ�39����') b on a.acc_nbr=b.acc_nbr
--and  a.offer_comp_instance_id=b.offer_comp_instance_id
where a.offer_name='�����ײ��ֻ���װ��') b
left join tmp_elong1_AREA_FEEMONTH c on c.offer_comp_instance_id=b.offer_comp_instance_id and c.acc_nbr<>b.acc_nbr
where c.offer_comp_instance_id is null;

--���ײͶ���ͬ��ͬ�ŵ�
--���׳�������һ������Ƿ��
insert into tmp_PACKGE_NAME_AREA_FEEMONTH
select '32','ͬ�ײͶ���ͬ��ͬ��',''||a.acc_nbr, b.acc_nbr from tmp_elong1_AREA_FEEMONTH a 
left join tmp_elong1_AREA_FEEMONTH b on a.offer_comp_instance_id=b.offer_comp_instance_id 
and b.offer_name='�����캽�����ֻ��ײ�39����' and b.acc_nbr>a.acc_nbr
where a.offer_name='�����캽�����ֻ��ײ�39����' and a.mkt_cust_code<>b.mkt_cust_code
;

select '33';
--* from tmp_g2_33_201110;
