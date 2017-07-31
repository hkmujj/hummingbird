-- 苹果手机 裸机销售清单
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
-- 
select * from ODS_CHNA_ST_IPHONE5_SALE_DETAIL_LAST_DAY
where area_id=AREA
limit 100;

select '33';

