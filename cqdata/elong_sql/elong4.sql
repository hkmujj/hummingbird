-- �ᶼ�����ֻ�, E9����
--��ͳ��

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH (
       id integer, item1 varchar(200), item2 varchar(200), value integer , t1 varchar(200), t2 varchar(200));
insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 1,'�Ż�����ͳ��', offer_name, count(*),'','' from tmp_elong3_AREA_FEEMONTH
GROUP by  1, 2, 3 order by 1, 2, 3;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 2,'�ײ͸���', 'e9��Ʒ��ʵ������',count(distinct offer_comp_instance_id) , '', '' from tmp_elong3_AREA_FEEMONTH where offer_name not in (
'e���ֻ��������ȫ���Ѱ棩' --331494
, 'e���ֻ������' --328071	--
,'ȫҵ���ֻ������5Ԫ/��/����������Ч��' --319290
);

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 3,'�ֻ�����', '�ֻ��������',count(distinct acc_nbr) , '','' from tmp_elong3_AREA_FEEMONTH where 1=1; --offer_name='�����캽�����ֻ��ײ�39����';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 4,'�����ֻ���������', '�����ֻ��������',count(distinct acc_nbr), '', '' from tmp_elong3_AREA_FEEMONTH where completed_date>='2012-01-01 00:00:00'; --offer_name='�����캽�����ֻ��ײ�39����';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 5,'�������ײ��ֻ�����', 'Ӧ���ײ͸������',count(distinct a.acc_nbr) ,'','' from tmp_elong3_AREA_FEEMONTH a
left join (select acc_nbr from tmp_elong3_AREA_FEEMONTH where offer_name in ('e���ֻ������','e���ֻ��������ȫ���Ѱ棩','ȫҵ���ֻ������5Ԫ/��/����������Ч��' --319290
) ) b on a.acc_nbr=b.acc_nbr
where a.offer_name  not in (
'e���ֻ��������ȫ���Ѱ棩' --331494
, 'e���ֻ������' --328071	--
,'ȫҵ���ֻ������5Ԫ/��/����������Ч��' --319290
)
and b.acc_nbr is null
;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 15,'���м�װ�ֻ�����', 'ֱ��ȡE���ֻ���װ��',count(distinct a.acc_nbr) ,'' ,'' from tmp_elong3_AREA_FEEMONTH a where offer_name in ('e���ֻ������','e���ֻ��������ȫ���Ѱ棩','ȫҵ���ֻ������5Ԫ/��/����������Ч��' --319290
);

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 25,'���濪ʼ����ܵĴ���', '', 0, '','';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 28,'¼��װ����δѡe9��������', a.acc_nbr, 0 ,a.staff_desc, a.com_grid_name from tmp_elong3_AREA_FEEMONTH a left join ( select acc_nbr from tmp_elong3_AREA_FEEMONTH where offer_name not in ('e���ֻ������','e���ֻ��������ȫ���Ѱ棩','ȫҵ���ֻ������5Ԫ/��/����������Ч��' --319290
) ) b on a.acc_nbr=b.acc_nbr
where a.offer_name  in ('e���ֻ������','e���ֻ��������ȫ���Ѱ棩','ȫҵ���ֻ������5Ԫ/��/����������Ч��' --319290
)  and b.acc_nbr is null;

-- ���װ������:
create temp table tmp0 as  
select distinct acc_nbr from tmp_elong3_AREA_FEEMONTH a where a.offer_name in ( 'e���ֻ������','e���ֻ��������ȫ���Ѱ棩'
--319290	1319290	
,'ȫҵ���ֻ������5Ԫ/��/����������Ч��' --	100298272882
,'ȫҵ���ֻ������5Ԫ/��/����������Ч��' --319290
);
-- ���װ��ͬ�ŵ�ʵ��
create temp table tmp_id as select distinct offer_comp_instance_id from tmp_elong3_AREA_FEEMONTH where acc_nbr in (select acc_nbr from tmp0);
--���л�����,���޹������ʣ��ȫ��,�����1��Ϊ����
create temp table tmp3 as select distinct acc_nbr, staff_desc, com_grid_name, offer_name, offer_comp_instance_id from tmp_elong3_AREA_FEEMONTH where offer_comp_instance_id not in (select * from tmp_id);
create temp table tmp4 as 
select offer_comp_instance_id from tmp3 
where offer_comp_instance_id<>-99 group by 1 having count(*)>1;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select distinct 29,'¼���������޼�װ����',b.acc_nbr, b.offer_comp_instance_id,b.staff_desc, b.com_grid_name from tmp4 a left join tmp_elong3_AREA_FEEMONTH b on a.offer_comp_instance_id=b.offer_comp_instance_id ;

-- ����: δ¼V����, ͬ�ײͶ���ͬV��Ⱥ��, ��V��Ⱥ��δ¼��������Ż���Ʒ��
--13310275328	108885	313835	vpn����Ⱥ(�������)Ⱥ��1-1000000����CDMA
--023-70708080	108885	62190	vpn����Ⱥ(�������)Ⱥ��1-1000000������ͨ�绰	100192796468
insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select distinct 33,'δ¼V����',b.acc_nbr, b.offer_comp_instance_id,b.staff_desc, b.com_grid_name from tmp_elong3_AREA_FEEMONTH b
where b.group_id is null
;
insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select distinct 44,'ͬ�ײͶ���ͬV����',a.offer_comp_instance_id||':'||a.acc_nbr, a.offer_comp_instance_id,a.staff_desc, a.com_grid_name from tmp_elong3_AREA_FEEMONTH a left join tmp_elong3_AREA_FEEMONTH b on a.offer_comp_instance_id=b.offer_comp_instance_id where a.group_id<>b.group_id and a.group_id is not null and b.group_id is not null
order by a.offer_comp_instance_id;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select distinct 46,'ͬ�ײͶ���ͬ��ͬ��',a.offer_comp_instance_id||':'||a.acc_nbr, a.offer_comp_instance_id,a.staff_desc, a.com_grid_name from tmp_elong3_AREA_FEEMONTH a left join tmp_elong3_AREA_FEEMONTH b on a.offer_comp_instance_id=b.offer_comp_instance_id where a.mkt_cust_code<>b.mkt_cust_code  and a.offer_comp_instance_id<>-99
order by a.offer_comp_instance_id;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select distinct 54,'��V����δ��������ѵ�',a.acc_nbr, a.offer_comp_instance_id,a.staff_desc, a.com_grid_name from tmp_elong3_AREA_FEEMONTH a 
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='00A' and b.prod_offer_id in ('62190','313835')
where b.serv_id is null
--order by a.offer_comp_instance_id;
;

select '33';
--* from tmp_g2_33_201110;
