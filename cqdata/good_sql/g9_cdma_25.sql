--分公司智能机承诺消费25元清单

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select 
to_char(a.PROD_OFFER_INST_CREATED_DATE,'yyyy-mm-dd') 创建时间
,b.acc_nbr, a.serv_id,b.com_grid_id,b.user_name
,com.com_channel_name, com.com_grid_name
 from ds_prd_offer_comp_detail a
left join ds_chn_prd_serv_AREA_LAST_DAY b on a.serv_id=b.serv_id 
left join DIM_ZONE_COMM com on b.com_grid_id=com.com_grid_id
where a.offer_comp_id=331594  --承诺优惠购机25元包, 用户承诺每月最低手机消费25元（不含国际长途、国际漫游、SP代收费），承诺时限12个月。
and b.serv_id is not null
order by 1 desc;

select '33';
--* from tmp_g2_33_201110;

