--
--C网流失清单
--本脚本的执行时间在10秒左右
--1、总表
--分公司、自己分公司4M用户数、占自己分公司所有宽带用户的占比
--2、	清单表
--格式：分公司、4M宽带业务号码、办理的C类商品包（取套餐生效时间最晚的一个）
--本处取的维护线
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

