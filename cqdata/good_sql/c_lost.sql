--
--C����ʧ�嵥
--���ű���ִ��ʱ����10������
--1���ܱ�
--�ֹ�˾���Լ��ֹ�˾4M�û�����ռ�Լ��ֹ�˾���п���û���ռ��
--2��	�嵥��
--��ʽ���ֹ�˾��4M���ҵ����롢�����C����Ʒ����ȡ�ײ���Чʱ�������һ����
--����ȡ��ά����
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;

drop table if exists tgm_AREA_c_LAST_MONTH;
create temp table tgm_AREA_c_LAST_MONTH as 
select * from ds_chn_prd_serv_com_AREA_LAST_MONTH where product_id=208511296 and serv_num=1 and com_area_id=AREA;

drop table if exists tgm_AREA_c_FEEMONTH;
create temp table tgm_AREA_c_FEEMONTH as 
select * from ds_chn_prd_serv_com_AREA_FEEMONTH where product_id=208511296 and serv_num=1 and com_area_id=AREA;

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select serv_id, acc_nbr, user_name, billing_mode_id, completed_date, remove_date,cdma_card_flag, offln_flg, owe_offln_flag, due_offln_flag, owe_monshts, zero_flag, remove_flag, use_state from ds_chn_prd_serv_com_AREA_FEEMONTH where serv_id in  
(select serv_id from tgm_AREA_c_LAST_MONTH
 where serv_id not in (select serv_id from tgm_AREA_c_FEEMONTH) );	

select 'AREA';
--* from tmp_g2_AREA_201110;

