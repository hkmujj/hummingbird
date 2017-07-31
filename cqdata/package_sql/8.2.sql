
--单套餐流量类商品包按套餐4级
select distinct OFFER_COMP_TYPE_DESC4 套餐四级名称,BALANCE 使用总额,peak_value 额定总额,BALANCE/peak_value 套餐使用率 
from 
(
select distinct d.OFFER_COMP_TYPE_DESC4,sum(b.BALANCE) BALANCE,sum(b.peak_value)       --如需要号码对应套餐、套餐使用值清单，则在此行增加a.acc_nbr,e.offer_name,f.PRICING_PLAN_NAME等信息
peak_value
from 
DS_CHN_PRD_SERV_44_201109 a,  --用户月表请替换为对应分公司
DM_PRD_OFFER_ACCUMULATOR b,  --套餐余额表，目前只有上月月数据，以后会增加日表和月表，同时对应分公司
DS_PRD_OFFER_COMP_DETAIL c,
DIM_WD_OFFER_NEW_DIR_SECOND d,
DIM_CRM_PRODUCT_OFFER e,
DIM_CRM_PRICING_PLAN f       --定价参数表，目前套餐余额表不支持账目名称查询，为区分流量与话费时长以及各种不该统计的账目，临时用该表
where 
a.state='00A' 
and 
a.serv_id=b.OWNER_ID
and 
b.PRODUCT_OFFER_INSTANCE_ID=c.PROD_OFFER_INST_ID
and 
c.offer_comp_id=d.OFFER_COMP_TYPE_ID6
and 
c.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))    --此处时间是销售品实例表的方案失效时间，大于统计账期的次月零点
and 
b.eff_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'))   --此处时间是套餐余额表的生效时间，生效时间为大于等于统计账期的月初零点
and 
b.exp_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))     --此处时间是套餐余额表的失效时间，生效时间为小于统计账期次月的月初零点
and 
c.PROD_OFFER_ID=e.offer_id
and b.REPOSITORY_ID=f.PRICING_PLAN_ID
and 
(
f.PRICING_PLAN_NAME like '%流量%' 
or f.PRICING_PLAN_NAME like '%上网%' 
or f.PRICING_PLAN_NAME like '%1X%' 
or f.PRICING_PLAN_NAME like '%T2%' 
or f.PRICING_PLAN_NAME like '%小时%' 
or f.PRICING_PLAN_NAME like '%免费%' 
)
and f.PRICING_PLAN_NAME not like '%条%' 
and f.PRICING_PLAN_NAME not like '%彩信%' 
and f.PRICING_PLAN_NAME not like '%短信%' 
and f.PRICING_PLAN_NAME not like '%超出%' 
group by 1
) a where BALANCE<peak_value and peak_value>0
order by 额定总额 desc;--执行完的结果，套餐使用率字段导出后，excel表格式应改为百分制



--单套餐通话流量按套餐3级
select distinct OFFER_COMP_TYPE_DESC3 套餐三级名称,BALANCE/peak_value 套餐使用率 from 
(
select distinct d.OFFER_COMP_TYPE_DESC3,sum(b.BALANCE) BALANCE,sum(b.peak_value)      --如需要号码对应套餐、套餐使用值清单，则在此行增加a.acc_nbr,e.offer_name,f.PRICING_PLAN_NAME等信息
peak_value
from 
DS_CHN_PRD_SERV_44_201106 a,  --用户月表请替换为对应分公司
DM_PRD_OFFER_ACCUMULATOR b,    --套餐余额表，目前只有上月月数据，以后会增加日表和月表，同时对应分公司
DS_PRD_OFFER_COMP_DETAIL c,
DIM_WD_OFFER_NEW_DIR_SECOND d,
DIM_CRM_PRODUCT_OFFER e,
DIM_CRM_PRICING_PLAN f     --定价参数表，目前套餐余额表不支持账目名称查询，为区分流量与话费时长以及各种不该统计的账目，临时用该表
where 
a.state='00A' 
and 
a.serv_id=b.OWNER_ID
and 
b.PRODUCT_OFFER_INSTANCE_ID=c.PROD_OFFER_INST_ID
and 
c.offer_comp_id=d.OFFER_COMP_TYPE_ID6
and 
c.PROD_OFFER_INST_EXP_DATE>'2011-07-01 00:00:00'    --此处时间是销售品实例表的方案失效时间，大于统计账期的次月零点
and 
b.eff_date>='2011-06-01 00:00:00'  --此处时间是套餐余额表的生效时间，生效时间为大于等于统计账期的月初零点
and 
b.exp_date<'2011-07-01 00:00:00'    --此处时间是套餐余额表的失效时间，生效时间为小于统计账期次月的月初零点
and 
c.PROD_OFFER_ID=e.offer_id
and b.REPOSITORY_ID=f.PRICING_PLAN_ID
and 
(
f.PRICING_PLAN_NAME like '%流量%' 
or f.PRICING_PLAN_NAME like '%上网%' 
or f.PRICING_PLAN_NAME like '%1X%' 
or f.PRICING_PLAN_NAME like '%T2%' 
or f.PRICING_PLAN_NAME like '%小时%' 
or f.PRICING_PLAN_NAME like '%免费%' 
)
and f.PRICING_PLAN_NAME not like '%条%' 
and f.PRICING_PLAN_NAME not like '%彩信%' 
and f.PRICING_PLAN_NAME not like '%短信%' 
and f.PRICING_PLAN_NAME not like '%超出%' 
group by 1
) a where BALANCE<peak_value and peak_value>0
order by 套餐使用率;