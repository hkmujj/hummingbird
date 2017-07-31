
--融合套餐通话时长通话费类按套餐4级，前10名
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
CREATE TABLE tmp_PACKGE_NAME_AREA_FEEMONTH AS 
select distinct OFFER_COMP_TYPE_DESC6 套餐四级名称,BALANCE 使用总值,peak_value 额定总值,BALANCE/peak_value 套餐使用率 from
(
select distinct OFFER_COMP_TYPE_DESC6,sum(BALANCE) BALANCE,sum(peak_value) peak_value from 
(
select distinct d.OFFER_COMP_TYPE_DESC4,d.OFFER_COMP_TYPE_DESC6,c.OFFER_COMP_INSTANCE_ID,b.BALANCE,b.peak_value   --如需要号码对应套餐、套餐使用值清单，则在此行增加a.acc_nbr等信息,但要注意是融合套餐，多个设备对应一个OFFER_COMP_INSTANCE_ID
from 
DS_CHN_PRD_SERV_AREA_201107 a,--用户月表请替换为对应分公司
DM_PRD_OFFER_ACCUMULATOR b,--套餐余额表，目前只有上月月数据，以后会增加日表和月表，同时对应分公司
DS_PRD_OFFER_COMP_DETAIL c,
DIM_WD_OFFER_NEW_DIR_SECOND d,
DIM_CRM_PRODUCT_OFFER e,
DIM_CRM_PRICING_PLAN f   --定价参数表，目前套餐余额表不支持账目名称查询，为区分流量与话费时长以及各种不该统计的账目，临时用该表
where 
a.state='00A' 
and 
c.PROD_OFFER_INST_ID=b.OWNER_ID
and 
b.PRODUCT_OFFER_INSTANCE_ID=c.PROD_OFFER_INST_ID
and 
c.offer_comp_id=d.OFFER_COMP_TYPE_ID6
and 
c.PROD_OFFER_INST_EXP_DATE> (values ((select date_trunc('month', timestamp 'FEEMONTH01')) + interval '1 month'))
--'2011-08-01 00:00:00'     --此处时间是销售品实例表的方案失效时间，大于统计账期的次月零点
and
b.eff_date>= (values ((select date_trunc('month', timestamp 'FEEMONTH01')) + interval '0 month'))
--'2011-07-01 00:00:00'   --此处时间是套餐余额表的生效时间，生效时间为大于等于统计账期的月初零点
and 
b.exp_date< (values ((select date_trunc('month', timestamp 'FEEMONTH01')) + interval '1 month'))
--'2011-08-01 00:00:00'    --此处时间是套餐余额表的失效时间，生效时间为小于统计账期次月的月初零点
and 
c.PROD_OFFER_ID=e.offer_id
and 
b.REPOSITORY_ID=f.PRICING_PLAN_ID
and 
a.serv_id=c.serv_id
and f.PRICING_PLAN_NAME not like '%%条%%' 
and f.PRICING_PLAN_NAME not like '%%流量%%' 
and f.PRICING_PLAN_NAME not like '%%彩信%%' 
and f.PRICING_PLAN_NAME not like '%%短信%%' 
and f.PRICING_PLAN_NAME not like '%%上网%%' 
and f.PRICING_PLAN_NAME not like '%%1X%%' 
and f.PRICING_PLAN_NAME not like '%%T2%%' 
and f.PRICING_PLAN_NAME not like '%%小时%%' 
and f.PRICING_PLAN_NAME not like '%%免费%%' 
) a group by 1
) a where BALANCE<peak_value and peak_value>0
order by 额定总值 desc;--执行完的结果，套餐使用率字段导出后，excel表格式应改为百分制
select * from tmp_PACKGE_NAME_AREA_FEEMONTH LIMIT 20;

--融合套餐通话时长通话费类按套餐4级，后10名
select distinct OFFER_COMP_TYPE_DESC6 套餐四级名称,BALANCE 使用总值,peak_value 额定总值,BALANCE/peak_value 套餐使用率 from
(
select distinct OFFER_COMP_TYPE_DESC6,sum(BALANCE) BALANCE,sum(peak_value) peak_value from 
(
select distinct d.OFFER_COMP_TYPE_DESC4,d.OFFER_COMP_TYPE_DESC6,c.OFFER_COMP_INSTANCE_ID,b.BALANCE,b.peak_value          --如需要号码对应套餐、套餐使用值清单，则在此行增加a.acc_nbr等信息,但要注意是融合套餐，多个设备对应一个OFFER_COMP_INSTANCE_ID
from 
DS_CHN_PRD_SERV_AREA_201107 a,--用户月表请替换为对应分公司
DM_PRD_OFFER_ACCUMULATOR b,--套餐余额表，目前只有上月月数据，以后会增加日表和月表，同时对应分公司
DS_PRD_OFFER_COMP_DETAIL c,
DIM_WD_OFFER_NEW_DIR_SECOND d,
DIM_CRM_PRODUCT_OFFER e,
DIM_CRM_PRICING_PLAN f   --定价参数表，目前套餐余额表不支持账目名称查询，为区分流量与话费时长以及各种不该统计的账目，临时用该表
where 
a.state='00A' 
and 
c.PROD_OFFER_INST_ID=b.OWNER_ID
and 
b.PRODUCT_OFFER_INSTANCE_ID=c.PROD_OFFER_INST_ID
and 
c.offer_comp_id=d.OFFER_COMP_TYPE_ID6
and 
c.PROD_OFFER_INST_EXP_DATE> (values ((select date_trunc('month', timestamp 'FEEMONTH01')) + interval '1 month'))
--'2011-08-01 00:00:00'     --此处时间是销售品实例表的方案失效时间，大于统计账期的次月零点
and
b.eff_date>= (values ((select date_trunc('month', timestamp 'FEEMONTH01')) + interval '0 month'))
--'2011-07-01 00:00:00'   --此处时间是套餐余额表的生效时间，生效时间为大于等于统计账期的月初零点
and 
b.exp_date< (values ((select date_trunc('month', timestamp 'FEEMONTH01')) + interval '1 month'))
--'2011-08-01 00:00:00'    --此处时间是套餐余额表的失效时间，生效时间为小于统计账期次月的月初零点
and 
c.PROD_OFFER_ID=e.offer_id
and 
b.REPOSITORY_ID=f.PRICING_PLAN_ID
and 
a.serv_id=c.serv_id
and f.PRICING_PLAN_NAME not like '%%条%%' 
and f.PRICING_PLAN_NAME not like '%%流量%%' 
and f.PRICING_PLAN_NAME not like '%%彩信%%' 
and f.PRICING_PLAN_NAME not like '%%短信%%' 
and f.PRICING_PLAN_NAME not like '%%上网%%' 
and f.PRICING_PLAN_NAME not like '%%1X%%' 
and f.PRICING_PLAN_NAME not like '%%T2%%' 
and f.PRICING_PLAN_NAME not like '%%小时%%' 
and f.PRICING_PLAN_NAME not like '%%免费%%' 
) a group by 1
) a where BALANCE<peak_value and peak_value>0
order by 套餐使用率;
--执行完的结果，套餐使用率字段导出后，excel表格式应改为百分制

--融合套餐通话时长通话费类按套餐3级
select distinct OFFER_COMP_TYPE_DESC3 套餐三级名称,BALANCE/peak_value 套餐使用率 from
(
select distinct OFFER_COMP_TYPE_DESC3,sum(BALANCE) BALANCE,sum(peak_value) peak_value from 
(
select distinct d.OFFER_COMP_TYPE_DESC3,d.OFFER_COMP_TYPE_DESC6,c.OFFER_COMP_INSTANCE_ID,b.BALANCE,b.peak_value      --如需要号码对应套餐、套餐使用值清单，则在此行增加a.acc_nbr等信息,但要注意是融合套餐，多个设备对应一个OFFER_COMP_INSTANCE_ID
from 
DS_CHN_PRD_SERV_AREA_FEEMONTH a,  --用户月表请替换为对应分公司
DM_PRD_OFFER_ACCUMULATOR b,  --套餐余额表，目前只有上月月数据，以后会增加日表和月表，同时对应分公司
DS_PRD_OFFER_COMP_DETAIL c,
DIM_WD_OFFER_NEW_DIR_SECOND d,
DIM_CRM_PRODUCT_OFFER e,
DIM_CRM_PRICING_PLAN f     --定价参数表，目前套餐余额表不支持账目名称查询，为区分流量与话费时长以及各种不该统计的账目，临时用该表
where 
a.state='00A' 
and 
c.PROD_OFFER_INST_ID=b.OWNER_ID
and 
b.PRODUCT_OFFER_INSTANCE_ID=c.PROD_OFFER_INST_ID
and 
c.offer_comp_id=d.OFFER_COMP_TYPE_ID6
and 
c.PROD_OFFER_INST_EXP_DATE>(values ((select date_trunc('month', timestamp 'FEEMONTH01')) + interval '1 month'))
--'2011-07-01 00:00:00'     --此处时间是销售品实例表的方案失效时间，大于统计账期的次月零点
and
b.eff_date>=(values ((select date_trunc('month', timestamp 'FEEMONTH01')) + interval '0 month'))
--'2011-06-01 00:00:00' --此处时间是套餐余额表的生效时间，生效时间为大于等于统计账期的月初零点
and 
b.exp_date<(values ((select date_trunc('month', timestamp 'FEEMONTH01')) + interval '1 month'))
--'2011-07-01 00:00:00'   --此处时间是套餐余额表的失效时间，生效时间为小于统计账期次月的月初零点
and 
c.PROD_OFFER_ID=e.offer_id
and 
b.REPOSITORY_ID=f.PRICING_PLAN_ID
and 
a.serv_id=c.serv_id
and f.PRICING_PLAN_NAME not like '%%条%%' 
and f.PRICING_PLAN_NAME not like '%%流量%%' 
and f.PRICING_PLAN_NAME not like '%%彩信%%' 
and f.PRICING_PLAN_NAME not like '%%短信%%' 
and f.PRICING_PLAN_NAME not like '%%上网%%' 
and f.PRICING_PLAN_NAME not like '%%1X%%' 
and f.PRICING_PLAN_NAME not like '%%T2%%' 
and f.PRICING_PLAN_NAME not like '%%小时%%' 
and f.PRICING_PLAN_NAME not like '%%免费%%' 
) a group by 1
) a where BALANCE<peak_value and peak_value>0;--执行完的结果，套餐使用率字段导出后，excel表格式应改为百分制
