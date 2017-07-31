--C网号码消费分档统计
--C网话务量, 提每个C网号码的消费金额,按档次划分
--取的列收收入

drop table if exists temp_c;
create temp table temp_c as 
select acc_nbr, a.serv_id
,bb.mkt_channel_name
,sum(charge) charge
 from ds_chn_prd_serv_{area}_{yyyymm} a
left join DIM_ZONE_area bb on a.mkt_grid_id=bb.mkt_grid_id 
left join DS_CHN_ACT_SERV_INCOME_{yyyymm} b on a.serv_id=b.serv_id

where a.product_id=208511296 --语音CDMA
and a.serv_num=1 --到达标志
and b.income_flag=1 --列收标志
and a.mkt_area_id={area}

group by 1,2, 3
--limit 
;

drop table if exists tmp_PACKGE_NAME_{area}_{yyyymm};
create table tmp_PACKGE_NAME_{area}_{yyyymm} as 
select mkt_channel_name, count(*) count
, sum(case when charge between 0 and 0 then 1 else 0 end) dc_0
, sum(case when charge between 0.01 and 6 then 1 else 0 end )  dc_0_6
, sum(case when charge between 6.01 and 10 then 1 else 0 end ) dc_6_10
, sum(case when charge between 10.01 and 20 then 1 else 0 end ) dc_10_20
, sum(case when charge between 20.01 and 30 then 1 else 0 end ) dc_20_30
, sum(case when charge between 30.01 and 40 then 1 else 0 end ) dc_30_40
, sum(case when charge between 40.01 and 50 then 1 else 0 end ) dc_40_50
, sum(case when charge between 50.01 and 80 then 1 else 0 end ) dc_50_80
, sum(case when charge between 80.01 and 119 then 1 else 0 end ) dc_80_119
, sum(case when charge between 119.01 and 99999 then 1 else 0 end ) dc_119_up
from temp_c
group by 1
order by 1
;

select '33';
--* from tmp_g2_33_201110;
