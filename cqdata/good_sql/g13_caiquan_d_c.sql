-- 同产权客户下有AD,而未与C合户的
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
-- 
--提同产权客户下有手机而未合帐的宽带清单
select a.acc_nbr 宽带号码,
a.down_velocity 带宽, mkt_channel_name 营销_营维部, mkt_grid_name 营销网格,
com_channel_name 维护_营维部, com_grid_name 维护网格, c.acc_nbr 手机号码, c.billing_mode_id 付费方式, a.cust_id 产权客户ID, a.mkt_cust_code 宽带合同号, c.mkt_cust_code 手机合同号 from ds_chn_prd_serv_33_201211 a 
left join DS_CHN_PRD_CUST_33_201211 b on a.mkt_cust_code=b.mkt_cust_code
left join ds_chn_prd_serv_33_201211 c on a.cust_id=c.cust_id and c.product_id=208511296 and c.serv_num=1
left join DIM_ZONE_area area on a.mkt_grid_id=area.mkt_grid_id 
left join dim_zone_comm comm on a.com_grid_id=comm.com_grid_id 

where a.product_id='102030001' and a.serv_num=1
 and b.user_mobile_arrive_num=0  --合同号上C网设备到达数为0
 and c.billing_mode_id=1  --手机付费方式为后付
order by 1
limit 5000
;

select '33';

