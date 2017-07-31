--提重点业务产品到达数,每月交市场部和综合部

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select b.com_channel_name,sum(adsl) adsl, sum(cdma) cdma, sum(itv) itv, sum(pstn) pstn
from 
(
select com_grid_id
, sum(case when product_id=102030001 then 1 else 0 end) adsl
, sum(case when product_id=208511296 then 1 else 0 end) cdma
, sum(case when product_id=208511177 then 1 else 0 end) itv
, sum(case when product_id in (
101070001,
101050001,
208511245,
101030001,
101020002,
101010001,
150000025,
150000049,
101040001,
101020001,
101010002
) then 1 else 0 end) pstn
from ds_chn_prd_serv_com_{area}_{yyyymm} where serv_num=1 group by 1
) a
left join DIM_ZONE_COMM b on a.com_grid_id=b.com_grid_id
group by 1 order by 1
;

select '33';
--* from tmp_g2_33_201110;

