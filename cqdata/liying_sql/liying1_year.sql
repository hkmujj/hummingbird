--������������仯�����, Ҫ��������:
--���� X����������  ռ�����  ������������ ����C������ ������� iTV����
--XXӪά��
--XXӪά��
--����
--�ϼ�
--
--ȷ��1:��ָ��������,���ǵ�������?
--���ű�ȡ���������û�,�ڵ��´���������
--��1��: ȡ�õ��������豸, ������Ӫά��, ��Ʒ����, ��ÿ���豸�����Ƿ��������ı�־,���ݿ���ʱ��
--��2��: ȡ��ÿ�豸�ĵ����Żݺ���úϼ�
--ͳ�Ƶó�ÿ��Ӫά���ĵ�����������,����������, ����ÿ����Ʒ����������

drop table if exists tmp_tgm_t1;
create temp table tmp_tgm_t1 as 
select serv_id, mkt_cust_id, mkt_channel_id, mkt_grid_id, com_channel_id, com_grid_id
--,acct_item_type_id5
, sum(charge) charge
--, income_flag
--select * 
 from DS_CHN_ACT_SERV_INCOME_{yyyymm} where mkt_area_id={area}
 and income_flag=1
 group by 1,2,3,4,5,6 
 --limit 10
 ;

select  count(*), sum(charge) from tmp_tgm_t1;

drop table if exists tmp_tgm_t2;
create temp table tmp_tgm_t2 as 
select a.*, case when b.completed_date like '{yyyy}%%' then 1 else 0 end new_flag
--, b.product_id 
, product_name
,mkt.mkt_channel_name
from tmp_tgm_t1 a left join ds_chn_prd_serv_{area}_{yyyymm} b on a.serv_id=b.serv_id
left join dim_crm_product product on b.product_id=product.product_id 
left join DIM_ZONE_area mkt on a.mkt_grid_id=mkt.mkt_grid_id
--limit 10
;

drop table if exists tmp_t3;
create temp table tmp_t3
(item varchar(40), channel varchar(40), charge decimal(16,2)); 

insert into tmp_t3
select '�ܷ���',mkt_channel_name, sum(charge) from tmp_tgm_t2 
group by 1,2  
union
select '��������',mkt_channel_name, sum(charge) from tmp_tgm_t2 
where new_flag=1 group by 1,2  
union
select '����iTV',mkt_channel_name, sum(charge) from tmp_tgm_t2 
where new_flag=1  and product_name='iTV' group by 1,2 
union
select '�����ֻ�',mkt_channel_name, sum(charge) from tmp_tgm_t2 
where new_flag=1  and product_name='�ֻ�' group by 1,2 
union
select '�������',mkt_channel_name, sum(charge) from tmp_tgm_t2 
where new_flag=1  and product_name='ADSL�������' group by 1,2   
union
select '�����̻�',mkt_channel_name, sum(charge) from tmp_tgm_t2 
where new_flag=1  and product_name='�̶��绰' group by 1,2   
;
drop table tmp_tgm_t1;
drop table tmp_tgm_t2;
--select   ��Ա   as   [��Ա\Ʒ��],sum(case   when   Ʒ��= 'a '   then   ����   else   0   end)   as   a,sum(case   when   Ʒ��= 'b '   then   ����   else   0   end)as   b   from   @a   group   by   ��Ա 
drop table if exists tmp_PACKGE_NAME_{area}_{yyyymm};
create table tmp_PACKGE_NAME_{area}_{yyyymm} as 
select channel, sum(case when item='��������' then charge else 0 end) ��������
, sum(case when item='�ܷ���' then charge else 0 end) �ܷ���
, 0.0 ռ�����
, 0.0 ������������
, sum(case when item='����iTV' then charge else 0 end) ����iTV
, sum(case when item='�����ֻ�' then charge else 0 end) �����ֻ�
, sum(case when item='�������' then charge else 0 end) �������
, sum(case when item='�����̻�' then charge else 0 end) �����̻�
from tmp_t3
group by 1;

select '33';
--* from tmp_g2_33_201110;
