-- 苹果合约计划清单
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
-- 
select * from ODS_CRM_IPHONE5_TERMINAL_CRMXD_LAST_DAY
where ods_area_code=AREA
limit 1000;

select '33';

