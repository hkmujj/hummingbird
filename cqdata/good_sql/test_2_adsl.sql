--���ݼ�����ȿ����
--��ֹ�˾4M���ռ��
--���ű���ִ��ʱ����10������
--1���ܱ�
--�ֹ�˾���Լ��ֹ�˾4M�û�����ռ�Լ��ֹ�˾���п���û���ռ��
--2��	�嵥��
--��ʽ���ֹ�˾��4M���ҵ����롢�����C����Ʒ����ȡ�ײ���Чʱ�������һ����
--
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select 'AREA' area, b.*, a.*, b._4M*1.0/a.total rate from 
(
select count(*) total from ds_chn_prd_serv_mkt_AREA_{yyyymm} a
where a.PRODUCT_ID in (
--102010002 --ADSLר��
102030001 --ADSLע���鲦����
--,102030002 --LANע���鲦����
)
--product_id=102030001
--and state='00A' and serv_state='2HA' 
and serv_num=1) a
left join 
(select 
--down_velocity, 
count(*) _4M from ds_chn_prd_serv_mkt_AREA_{yyyymm} a
where a.PRODUCT_ID in (
--02010002 --ADSLר��
102030001 --ADSLע���鲦����
-- ,102030002 --LANע���鲦����
)
--where product_id=102030001
--and state='00A' and serv_state='2HA' 
and serv_num=1
and down_velocity not in ('512K', '640K', '1M', '1.5M', '2M', '2.5M', '3M')
--group by 1
) b on 1=1
;

select '33';
--* from tmp_g2_33_201110;

