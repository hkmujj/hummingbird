--���ݼ�����ȿ����
--��ֹ�˾��Ӫά��4M���ռ��
--���ű���ִ��ʱ����10������
--1���ܱ�
--�ֹ�˾���Լ��ֹ�˾4M�û�����ռ�Լ��ֹ�˾���п���û���ռ��
--2��	�嵥��
--��ʽ���ֹ�˾��4M���ҵ����롢�����C����Ʒ����ȡ�ײ���Чʱ�������һ����
--����ȡ��ά����
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select 'AREA' area, a.com_channel_name, b._4M, a.total, b._4M*1.0/a.total rate from 
(
select b.com_channel_name, count(*) total from ds_chn_prd_serv_AREA_FEEMONTH a
left join DIM_ZONE_COMM b on a.com_grid_id=b.com_grid_id
where a.PRODUCT_ID in (
--102010002 --ADSLר��
102030001 --ADSLע���鲦����
,102030002 --LANע���鲦����
)
--where product_id=102030001
and a.state='00A' and a.serv_state='2HA' and a.serv_num=1
and b.com_area_id='AREA'
group by b.com_channel_name


) a
left join 
(select 
--down_velocity, 
b.com_channel_name, count(*) _4M from ds_chn_prd_serv_AREA_FEEMONTH a
left join dim_zone_comm b on a.com_grid_id=b.com_grid_id
where a.PRODUCT_ID in (
--102010002 --ADSLר��
102030001 --ADSLע���鲦����
,102030002 --LANע���鲦����
)
--where product_id=102030001
and state='00A' and serv_state='2HA' and serv_num=1
and down_velocity not in ('512K', '640K', '1M', '1.5M', '2M', '2.5M', '3M')
and b.com_area_id='AREA'
group by 1
) b on a.com_channel_name=b.com_channel_name

order by rate;

select '33';
--* from tmp_g2_33_201110;

