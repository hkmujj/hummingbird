--�ᶼ����ӭ������ְ�

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH (
	id int,
	��Ŀ���� varchar(20)
	, �Ƕ� int
	,���� int
	,��̳ int
       ,���� int
,���� int
,���� int
,�ֹ�˾ int
);

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (1,'��װ�������', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
�Ƕ�=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ�Ƕ�Ӫά��') , 
����=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' ) ,
��̳=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ��̳Ӫά��' ) ,
����=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' ) ,
����=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' ) ,
����=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' ) ,
�ֹ�˾=(select count(*) from tmp_fd2_AREA_FEEMONTH where 1=1 )
where ��Ŀ����='��װ�������';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (2, '��װ����Ʒ�����', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
�Ƕ�=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ�Ƕ�Ӫά��' and score>0 ) , 
����=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' and score>0 ) ,
��̳=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ��̳Ӫά��'  and score>0) ,
����=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score>0) ,
����=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score>0) ,
����=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score>0) ,
�ֹ�˾=(select count(*) from tmp_fd2_AREA_FEEMONTH where 1=1  and score>0)
where ��Ŀ����='��װ����Ʒ�����';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (3, '��װ���δ�Ʒ�����', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
�Ƕ�=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ�Ƕ�Ӫά��' and score=0 ) , 
����=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' and score=0 ) ,
��̳=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ��̳Ӫά��'  and score=0) ,
����=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score=0) ,
����=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score=0) ,
����=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score=0) ,
�ֹ�˾=(select count(*) from tmp_fd2_AREA_FEEMONTH where 1=1  and score=0)
where ��Ŀ����='��װ���δ�Ʒ�����';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (4, '��װ�������', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
�Ƕ�=(select sum(score) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ�Ƕ�Ӫά��'  ) , 
����=(select sum(score) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  ) ,
��̳=(select sum(score) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ��̳Ӫά��'  ) ,
����=(select sum(score) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  ) ,
����=(select sum(score) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  ) ,
����=(select sum(score) from tmp_fd2_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  ) ,
�ֹ�˾=(select sum(score) from tmp_fd2_AREA_FEEMONTH where 1=1  )
where ��Ŀ����='��װ�������';


insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (6,'��װ�ֻ�����', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
�Ƕ�=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ�Ƕ�Ӫά��') , 
����=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' ) ,
��̳=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ��̳Ӫά��' ) ,
����=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' ) ,
����=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' ) ,
����=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' ) ,
�ֹ�˾=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where 1=1 )
where ��Ŀ����='��װ�ֻ�����';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (7,'��װ�ֻ��Ʒ�����', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
�Ƕ�=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ�Ƕ�Ӫά��' and score>0 ) , 
����=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' and score>0 ) ,
��̳=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ��̳Ӫά��'  and score>0) ,
����=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score>0) ,
����=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score>0) ,
����=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' and score>0 ) ,
�ֹ�˾=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where 1=1 and score>0 )
where ��Ŀ����='��װ�ֻ��Ʒ�����';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (8,'��װ�ֻ�δ�Ʒ�����', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
�Ƕ�=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ�Ƕ�Ӫά��' and score=0 ) , 
����=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' and score=0 ) ,
��̳=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ��̳Ӫά��'  and score=0) ,
����=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score=0) ,
����=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score=0) ,
����=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' and score=0 ) ,
�ֹ�˾=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where 1=1 and score=0 )
where ��Ŀ����='��װ�ֻ�δ�Ʒ�����';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (9,'��װ�ֻ�����', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
�Ƕ�=(select sum(score) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ�Ƕ�Ӫά��' and score>0 ) , 
����=(select sum(score) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' and score>0 ) ,
��̳=(select sum(score) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ��̳Ӫά��'  and score>0) ,
����=(select sum(score) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score>0) ,
����=(select sum(score) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score>0) ,
����=(select sum(score) from tmp_fd3_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' and score>0 ) ,
�ֹ�˾=(select sum(score) from tmp_fd3_AREA_FEEMONTH where 1=1 and score>0 )
where ��Ŀ����='��װ�ֻ�����';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (18,'�Ͽ�����ٵ�4M����', 
(select count(*) from tmp_fd4_AREA_FEEMONTH where com_channel_name='�ᶼ�Ƕ�Ӫά��' and score>0 ) , 
(select count(*) from tmp_fd4_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' and score>0 ) ,
(select count(*) from tmp_fd4_AREA_FEEMONTH where com_channel_name='�ᶼ��̳Ӫά��'  and score>0) ,
(select count(*) from tmp_fd4_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score>0) ,
(select count(*) from tmp_fd4_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score>0) ,
(select count(*) from tmp_fd4_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' and score>0 ) ,
(select count(*) from tmp_fd4_AREA_FEEMONTH where 1=1 and score>0 )
)
;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (19,'�Ͽ�����ٵ�4M����', 
(select sum(score) from tmp_fd4_AREA_FEEMONTH where com_channel_name='�ᶼ�Ƕ�Ӫά��' and score>0 ) , 
(select sum(score) from tmp_fd4_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' and score>0 ) ,
(select sum(score) from tmp_fd4_AREA_FEEMONTH where com_channel_name='�ᶼ��̳Ӫά��'  and score>0) ,
(select sum(score) from tmp_fd4_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score>0) ,
(select sum(score) from tmp_fd4_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��'  and score>0) ,
(select sum(score) from tmp_fd4_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��' and score>0 ) ,
(select sum(score) from tmp_fd4_AREA_FEEMONTH where 1=1 and score>0 )
)
;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (21,'����������', 
(select sum(score) from tmp_fd5_AREA_FEEMONTH where com_channel_name='�ᶼ�Ƕ�Ӫά��') , 
(select sum(score) from tmp_fd5_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��') ,
(select sum(score) from tmp_fd5_AREA_FEEMONTH where com_channel_name='�ᶼ��̳Ӫά��') ,
(select sum(score) from tmp_fd5_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��') ,
(select sum(score) from tmp_fd5_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��') ,
(select sum(score) from tmp_fd5_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��') ,
(select sum(score) from tmp_fd5_AREA_FEEMONTH where 1=1 )
)
;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (31,'�ֻ��������', 
(select sum(score) from tmp_fd6_AREA_FEEMONTH where com_channel_name='�ᶼ�Ƕ�Ӫά��') , 
(select sum(score) from tmp_fd6_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��') ,
(select sum(score) from tmp_fd6_AREA_FEEMONTH where com_channel_name='�ᶼ��̳Ӫά��') ,
(select sum(score) from tmp_fd6_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��') ,
(select sum(score) from tmp_fd6_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��') ,
(select sum(score) from tmp_fd6_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��') ,
(select sum(score) from tmp_fd6_AREA_FEEMONTH where 1=1  )
)
;
insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (31,'iTV��������', 
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where com_channel_name='�ᶼ�Ƕ�Ӫά��') , 
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��') ,
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where com_channel_name='�ᶼ��̳Ӫά��') ,
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��') ,
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��') ,
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where com_channel_name='�ᶼ����Ӫά��') ,
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where 1=1  )
)
;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values(80,'����칫�ӷ�',
	0, 0, 1000, 0, 0, 0, 1000);

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (97,'�ܻ���', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
�Ƕ�=(select sum(�Ƕ�) from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ���� in ('��װ�������', '��װ�ֻ�����', '�Ͽ�����ٵ�4M����', '����������', '�ֻ��������', 'FTTH����������ӷ�', '��ҵӦ�û���', '����칫�ӷ�', 'iTV��������') )  
,����=(select sum(����) from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ���� in ('��װ�������', '��װ�ֻ�����', '�Ͽ�����ٵ�4M����', '����������', '�ֻ��������', 'FTTH����������ӷ�', '��ҵӦ�û���', '����칫�ӷ�', 'iTV��������') )  
,��̳=(select sum(��̳) from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ���� in ('��װ�������', '��װ�ֻ�����', '�Ͽ�����ٵ�4M����', '����������', '�ֻ��������', 'FTTH����������ӷ�', '��ҵӦ�û���', '����칫�ӷ�', 'iTV��������') )  
,����=(select sum(����) from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ���� in ('��װ�������', '��װ�ֻ�����', '�Ͽ�����ٵ�4M����', '����������', '�ֻ��������', 'FTTH����������ӷ�', '��ҵӦ�û���', '����칫�ӷ�', 'iTV��������') )  
,����=(select sum(����) from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ���� in ('��װ�������', '��װ�ֻ�����', '�Ͽ�����ٵ�4M����', '����������', '�ֻ��������', 'FTTH����������ӷ�', '��ҵӦ�û���', '����칫�ӷ�', 'iTV��������') )  
,����=(select sum(����) from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ���� in ('��װ�������', '��װ�ֻ�����', '�Ͽ�����ٵ�4M����', '����������', '�ֻ��������', 'FTTH����������ӷ�', '��ҵӦ�û���', '����칫�ӷ�', 'iTV��������') )  
,�ֹ�˾=(select sum(�ֹ�˾) from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ���� in ('��װ�������', '��װ�ֻ�����', '�Ͽ�����ٵ�4M����', '����������', '�ֻ��������', 'FTTH����������ӷ�', '��ҵӦ�û���', '����칫�ӷ�', 'iTV��������') )  
where ��Ŀ����='�ܻ���';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (98,'T1ֵ', 110500,100000,55000,35000,60000,43000,403500);
insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (99,'���Ȱٷֱ�'
	, (select �Ƕ� from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ����='�ܻ���')*1.0/110500.0*100
	, (select ���� from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ����='�ܻ���')/100000.0*100
	, (select ��̳ from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ����='�ܻ���')/55000.0*100
	, (select ���� from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ����='�ܻ���')/35000.0*100
	, (select ���� from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ����='�ܻ���')/60000.0*100
	, (select ���� from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ����='�ܻ���')/43000.0*100
	, (select �ֹ�˾ from tmp_PACKGE_NAME_AREA_FEEMONTH where ��Ŀ����='�ܻ���')/403500.0*100
	--,100000,55000,35000,60000,43000,403500
);
select 33;
--* from tmp_g2_33_201110;
