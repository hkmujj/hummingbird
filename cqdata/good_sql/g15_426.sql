 -- 426宽带清单, 只取失效日期大于当时的
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select day_id 提取日期, acc_nbr 号码, cust_name 客户姓名, cust_code 客户编码, offer_eff_date 生效日期, offer_exp_date 失效日期, offer_completed_date 竣工日期
, comp_enable_flag 套餐到达标记, comp_serv_enable_flag 套餐用户到达标记
 from latn_33_offer where comp_offer_id=121244 and offer_exp_date>now()
 order by offer_exp_date desc; 
 --select * from  tmp_PACKGE_NAME_AREA_FEEMONTH;
select '33';

