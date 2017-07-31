此脚本操作步骤

3、执行竣工报表，并且将下面内容中的‘csjg’替换为‘xx_jg’（表名为竣工报表）
4、全部替换DS_CHN_PRD_SERV_44_ 为DS_CHN_PRD_SERV_xx_
10、修改执行第一段中，提示需要修改的地方。
11、执行注释提示的第一段。
12、执行注释提示的第二段。
13、执行注释提示的第三段。

另外此表执行时间较长，大约在10多分钟左右，请错开高峰期执行。

--从这里开始执行第一段
----营维部白表
--drop table csbaibiao;
create temporary table csbaibiao
(
d1  varchar(20),
bq  varchar(3),
c  decimal(16,0)
);
select distinct mkt_channel_name into temp mcn
from DIM_ZONE_AREA where MKT_AREA_NAME like '%长寿%' and mkt_channel_name not like '%其他%' and mkt_channel_name not like '%未认领%' and mkt_channel_name not like '%虚拟%' and mkt_channel_name not like '%其它%';
insert into csbaibiao select mkt_channel_name,'a' bq,0 c from mcn;
insert into csbaibiao select mkt_channel_name,'b' bq,0 c from mcn;
insert into csbaibiao select mkt_channel_name,'c' bq,0 c from mcn;
insert into csbaibiao select mkt_channel_name,'d' bq,0 c from mcn;
insert into csbaibiao select mkt_channel_name,'e' bq,0 c from mcn;
insert into csbaibiao select mkt_channel_name,'f' bq,0 c from mcn;
insert into csbaibiao select mkt_channel_name,'g' bq,0 c from mcn;
insert into csbaibiao select mkt_channel_name,'h' bq,0 c from mcn;
insert into csbaibiao select mkt_channel_name,'i' bq,0 c from mcn;
--a：当月发展(含更改的)
--b：当月拆机
--c：套餐到达数
--d：连续欠费3个月
--e：连续2月0次
--f：消费不足的
--g：消费超过套餐50%以上的
--h：ARPU
--i：MOU

----总号码
--drop table cscdma;
create temporary table cscdma as
select distinct a.acc_nbr nbr,b.mkt_channel_name d1,a.serv_id,a.mkt_cust_id,a.mkt_cust_code,a.state,a.REMOVE_DATE
from 
DS_CHN_PRD_SERV_44_201109 a, --用户月表，修改分公司和帐期
DIM_ZONE_AREA b
where 
a.product_id='208511296' 
and 
a.mkt_grid_id=b.mkt_grid_id
and 
a.serv_num='1'
DISTRIBUTED BY (serv_id);
----通话时长
--上月
--drop table cscdmalc1;
create temporary table cscdmalc1 as
select distinct a.serv_id,sum(BILLING_DURATION) b 
from 
cscdma a,DS_EVT_CALL_AREA_44_201108 b  ----语音话单表修改分公司和帐期，注意，这里是分析帐期当月的前一个帐期
where a.serv_id=b.serv_id
and a.state='00A'
and b.call_type_id=10
group by 1;
--本月
--drop table cscdmalc2;
create temporary table cscdmalc2 as
select distinct a.serv_id,sum(BILLING_DURATION) b 
from 
cscdma a,DS_EVT_CALL_AREA_44_201109 b  ----语音话单表修改分公司和帐期，注意，这里是分析帐期当月帐期
where a.serv_id=b.serv_id
and a.state='00A'
and b.call_type_id=10
group by 1;
--drop table cscdmalc3;
create temporary table cscdmalc3 as
select distinct* from cscdmalc1;
insert into cscdmalc3 select distinct * from cscdmalc2;
--drop table cscdmalc4;
create temporary table cscdmalc4 as
select distinct serv_id,sum(b) b  from cscdmalc3 group by 1;
-----设备号产生的费用
create temporary table cscdmaa as
select distinct a.serv_id,sum(b.amount) b
from 
cscdma a,DS_ACT_ACCT_ITEM_201109 b   --BSN应收费用表，修改帐期，帐期为分析当月帐期
where a.serv_id=b.serv_id 
group by 1;
-----套餐使用情况
--drop table cscdmaa1;
create temporary table cscdmaa1 as
select distinct a.serv_id,sum(b.BALANCE) b,sum(b.PEAK_VALUE) p
from 
cscdma a,
DM_PRD_OFFER_ACCUMULATOR b,
DS_PRD_OFFER_COMP_DETAIL c  
where a.serv_id=c.serv_id 
and b.owner_id=c.PROD_OFFER_INST_ID
and b.PEAK_VALUE<1000
and b.eff_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'))      
and b.exp_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))       
group by 1;



--从这里结束执行第一段



--从这里开始执行第二段，一直拉黑到提示第二段结束。

--天翼乡情网18套餐
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'天翼乡情网18套餐' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))))) 
and a.service_offer_name='售卖' 
and a.offer_comp_name='天翼乡情网18套餐'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'天翼乡情网18套餐' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name='天翼乡情网18套餐'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name like '%天翼乡情网18套餐%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'天翼乡情网18套餐' tc,'qf' bq
from 
(select distinct * from cst3) a
where 
a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,'天翼乡情网18套餐' tc,'bz' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b<1;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,'天翼乡情网18套餐' tc,'cg' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b>=1.5;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cs_ty18;
create temporary table cs_ty18 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into cs_ty18 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into cs_ty18 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into cs_ty18 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into cs_ty18 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into cs_ty18 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into cs_ty18 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into cs_ty18 select distinct d1,'h' bq,a c from cst8;
insert into cs_ty18 select distinct d1,'i' bq,a c from cst9;
insert into cs_ty18 select distinct * from csbaibiao;


drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;


--农村26
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'农村26' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and (a.offer_comp_name like '%e6-11%' or a.offer_comp_name like '%乡情网%' or a.offer_comp_name like '%E6-11%') and a.offer_comp_name like '%26%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'农村26' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and (a.offer_comp_name like '%e6-11%' or a.offer_comp_name like '%乡情网%' or a.offer_comp_name like '%E6-11%') and a.offer_comp_name like '%26%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and (C.offer_name like '%e6-11%' or C.offer_name like '%乡情网%' or C.offer_name like '%E6-11%') and C.offer_name like '%26%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'农村26' tc,'qf' bq
from 
(select distinct * from cst3) a
where 
a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,'农村26' tc,'bz' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b<1;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,'农村26' tc,'cg' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b>=1.5;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table CS_NC26;
create temporary table CS_NC26 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into CS_NC26 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into CS_NC26 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into CS_NC26 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into CS_NC26 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into CS_NC26 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into CS_NC26 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into CS_NC26 select distinct d1,'h' bq,a c from cst8;
insert into CS_NC26 select distinct d1,'i' bq,a c from cst9;
insert into CS_NC26 select distinct * from csbaibiao;


drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;

--城市26
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'城市26' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name not like '%e6-11%' 
and a.offer_comp_name not like '%乡情网%' 
and a.offer_comp_name not like '%E6-11%' 
and (a.offer_comp_name like '%e6%' or a.offer_comp_name like '%E6%' or a.offer_comp_name like '%移动回家%' or a.offer_comp_name like '%天翼回家%') 
and a.offer_comp_name like '%26%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'城市26' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name not like '%e6-11%' 
and a.offer_comp_name not like '%乡情网%' 
and a.offer_comp_name not like '%E6-11%' 
and (a.offer_comp_name like '%e6%' or a.offer_comp_name like '%E6%' or a.offer_comp_name like '%移动回家%' or a.offer_comp_name like '%天翼回家%') 
and a.offer_comp_name like '%26%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name not like '%e6-11%' and c.offer_name not like '%乡情网%' and c.offer_name not like '%E6-11%' and (c.offer_name like '%e6%' or c.offer_name like '%E6%' or c.offer_name like '%移动回家%' or c.offer_name like '%天翼回家%') and c.offer_name like '%26%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'城市26' tc,'qf' bq
from 
(select distinct * from cst3) a
where 
a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,'城市26' tc,'bz' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b<1;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,'城市26' tc,'cg' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b>=1.5;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table CS_cs26;
create temporary table CS_cs26 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into CS_cs26 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into CS_cs26 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into CS_cs26 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into CS_cs26 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into CS_cs26 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into CS_cs26 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into CS_cs26 select distinct d1,'h' bq,a c from cst8;
insert into CS_cs26 select distinct d1,'i' bq,a c from cst9;
insert into CS_cs26 select distinct * from csbaibiao;
select distinct d1,bq,sum(c) c from CS_cs26 group by 1,2;
select distinct bq,sum(c) c from CS_cs26 group by 1;

drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;


--城市36
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'城市36' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name not like '%e6-11%' 
and a.offer_comp_name not like '%乡情网%' 
and a.offer_comp_name not like '%E6-11%' 
and (a.offer_comp_name like '%e6%' or a.offer_comp_name like '%E6%' or a.offer_comp_name like '%移动回家%' or a.offer_comp_name like '%天翼回家%') 
and a.offer_comp_name like '%36%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'城市36' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name not like '%e6-11%' 
and a.offer_comp_name not like '%乡情网%' 
and a.offer_comp_name not like '%E6-11%' 
and (a.offer_comp_name like '%e6%' or a.offer_comp_name like '%E6%' or a.offer_comp_name like '%移动回家%' or a.offer_comp_name like '%天翼回家%') 
and a.offer_comp_name like '%36%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name not like '%e6-11%' and c.offer_name not like '%乡情网%' and c.offer_name not like '%E6-11%' and (c.offer_name like '%e6%' or c.offer_name like '%E6%'  or c.offer_name like '%移动回家%' or c.offer_name like '%天翼回家%') and c.offer_name like '%36%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'城市36' tc,'qf' bq
from 
(select distinct * from cst3) a
where 
a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,'城市36' tc,'bz' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b<1;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,'城市36' tc,'cg' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b>=1.5;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table CS_cs36;
create temporary table CS_cs36 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into CS_cs36 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into CS_cs36 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into CS_cs36 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into CS_cs36 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into CS_cs36 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into CS_cs36 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into CS_cs36 select distinct d1,'h' bq,a c from cst8;
insert into CS_cs36 select distinct d1,'i' bq,a c from cst9;
insert into CS_cs36 select distinct * from csbaibiao;


drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;

--城市46
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'城市46' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name not like '%e6-11%' 
and a.offer_comp_name not like '%乡情网%' 
and a.offer_comp_name not like '%E6-11%' 
and (a.offer_comp_name like '%e6%' or a.offer_comp_name like '%E6%' or a.offer_comp_name like '%移动回家%' or a.offer_comp_name like '%天翼回家%') 
and a.offer_comp_name like '%46%'
and C.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'城市46' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name not like '%e6-11%' 
and a.offer_comp_name not like '%乡情网%' 
and a.offer_comp_name not like '%E6-11%' 
and (a.offer_comp_name like '%e6%' or a.offer_comp_name like '%E6%' or a.offer_comp_name like '%移动回家%' or a.offer_comp_name like '%天翼回家%') 
and a.offer_comp_name like '%46%'
and C.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name not like '%e6-11%' and c.offer_name not like '%乡情网%' and c.offer_name not like '%E6-11%' and (c.offer_name like '%e6%' or c.offer_name like '%E6%'  or c.offer_name like '%移动回家%' or c.offer_name like '%天翼回家%') and c.offer_name like '%46%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'城市46' tc,'qf' bq
from 
(select distinct * from cst3) a
where 
a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,'城市46' tc,'bz' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b<1;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,'城市46' tc,'cg' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b>=1.5;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table CS_cs46;
create temporary table CS_cs46 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into CS_cs46 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into CS_cs46 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into CS_cs46 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into CS_cs46 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into CS_cs46 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into CS_cs46 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into CS_cs46 select distinct d1,'h' bq,a c from cst8;
insert into CS_cs46 select distinct d1,'i' bq,a c from cst9;
insert into CS_cs46 select distinct * from csbaibiao;


drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;


--城市66
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'城市66' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name not like '%e6-11%' 
and a.offer_comp_name not like '%乡情网%' 
and a.offer_comp_name not like '%E6-11%' 
and (a.offer_comp_name like '%e6%' or a.offer_comp_name like '%E6%' or a.offer_comp_name like '%移动回家%' or a.offer_comp_name like '%天翼回家%') 
and a.offer_comp_name like '%66%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'城市66' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name not like '%e6-11%' 
and a.offer_comp_name not like '%乡情网%' 
and a.offer_comp_name not like '%E6-11%' 
and (a.offer_comp_name like '%e6%' or a.offer_comp_name like '%E6%' or a.offer_comp_name like '%移动回家%' or a.offer_comp_name like '%天翼回家%') 
and a.offer_comp_name like '%66%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name not like '%e6-11%' and c.offer_name not like '%乡情网%' and c.offer_name not like '%E6-11%' and (c.offer_name like '%e6%' or c.offer_name like '%E6%'  or c.offer_name like '%移动回家%' or c.offer_name like '%天翼回家%') and c.offer_name like '%66%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'城市66' tc,'qf' bq
from 
(select distinct * from cst3) a
where 
a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,'城市66' tc,'bz' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b<1;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,'城市66' tc,'cg' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b>=1.5;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table CS_cs66;
create temporary table CS_cs66 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into CS_cs66 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into CS_cs66 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into CS_cs66 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into CS_cs66 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into CS_cs66 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into CS_cs66 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into CS_cs66 select distinct d1,'h' bq,a c from cst8;
insert into CS_cs66 select distinct d1,'i' bq,a c from cst9;
insert into CS_cs66 select distinct * from csbaibiao;


drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;

--E979
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'E979' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name not like '%179%' 
and (a.offer_comp_name like '%e9%' or a.offer_comp_name like '%E9%') 
and a.offer_comp_name like '%79%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'E979' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name not like '%179%' 
and (a.offer_comp_name like '%e9%' or a.offer_comp_name like '%E9%') 
and a.offer_comp_name like '%79%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name not like '%179%' and (c.offer_name like '%e9%' or c.offer_name like '%E9%') and c.offer_name like '%79%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E979' tc,'qf' bq
from 
(select distinct * from cst3) a
where 
a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E979' tc,'bz' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b<1;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E979' tc,'cg' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b>=1.5;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cs_e979;
create temporary table cs_e979 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into cs_e979 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into cs_e979 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into cs_e979 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into cs_e979 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into cs_e979 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into cs_e979 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into cs_e979 select distinct d1,'h' bq,a c from cst8;
insert into cs_e979 select distinct d1,'i' bq,a c from cst9;
insert into cs_e979 select distinct * from csbaibiao;
select distinct d1,bq,sum(c) c from cs_e979 group by 1,2;
select distinct bq,sum(c) c from cs_e979 group by 1;

drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;

--E989
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'E989' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name not like '%189%' and (a.offer_comp_name like '%e9%' or a.offer_comp_name like '%E9%') and a.offer_comp_name like '%89%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'E989' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name not like '%189%' and (a.offer_comp_name like '%e9%' or a.offer_comp_name like '%E9%') and a.offer_comp_name like '%89%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name not like '%189%' and (c.offer_name like '%e9%' or c.offer_name like '%E9%') and c.offer_name like '%89%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E989' tc,'qf' bq
from 
(select distinct * from cst3) a
where 
a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E989' tc,'bz' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b<1;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E989' tc,'cg' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b>=1.5;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cs_e989;
create temporary table cs_e989 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into cs_e989 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into cs_e989 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into cs_e989 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into cs_e989 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into cs_e989 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into cs_e989 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into cs_e989 select distinct d1,'h' bq,a c from cst8;
insert into cs_e989 select distinct d1,'i' bq,a c from cst9;
insert into cs_e989 select distinct * from csbaibiao;

drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;

--E999
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'E999' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name not like '%189%' and (a.offer_comp_name like '%e9%' or a.offer_comp_name like '%E9%') and a.offer_comp_name like '%99%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'E999' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name not like '%189%' and (a.offer_comp_name like '%e9%' or a.offer_comp_name like '%E9%') and a.offer_comp_name like '%99%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name not like '%189%' and (c.offer_name like '%e9%' or c.offer_name like '%E9%') and c.offer_name like '%99%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E999' tc,'qf' bq
from 
(select distinct * from cst3) a
where 
a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E999' tc,'bz' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b<1;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E999' tc,'cg' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b>=1.5;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cs_e999;
create temporary table cs_e999 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into cs_e999 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into cs_e999 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into cs_e999 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into cs_e999 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into cs_e999 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into cs_e999 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into cs_e999 select distinct d1,'h' bq,a c from cst8;
insert into cs_e999 select distinct d1,'i' bq,a c from cst9;
insert into cs_e999 select distinct * from csbaibiao;
select distinct d1,bq,sum(c) c from cs_e999 group by 1,2;
select distinct bq,sum(c) c from cs_e999 group by 1;

drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;


--E9119
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'E9119' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and (a.offer_comp_name like '%e9%' or a.offer_comp_name like '%E9%') and a.offer_comp_name like '%119%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'E9119' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and (a.offer_comp_name like '%e9%' or a.offer_comp_name like '%E9%') and a.offer_comp_name like '%119%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and (c.offer_name like '%e9%' or c.offer_name like '%E9%') and c.offer_name like '%119%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E9119' tc,'qf' bq
from 
(select distinct * from cst3) a
where 
a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E9189' tc,'bz' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b<1;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E9189' tc,'cg' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b>=1.5;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cs_E9119;
create temporary table cs_E9119 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into cs_E9119 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into cs_E9119 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into cs_E9119 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into cs_E9119 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into cs_E9119 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into cs_E9119 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into cs_E9119 select distinct d1,'h' bq,a c from cst8;
insert into cs_E9119 select distinct d1,'i' bq,a c from cst9;
insert into cs_E9119 select distinct * from csbaibiao;

drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;

--E9149
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'E9149' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name not like '%189%' and (a.offer_comp_name like '%e9%' or a.offer_comp_name like '%E9%') and a.offer_comp_name like '%149%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'E9149' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name not like '%189%' and (a.offer_comp_name like '%e9%' or a.offer_comp_name like '%E9%') and a.offer_comp_name like '%149%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name not like '%189%' and (c.offer_name like '%e9%' or c.offer_name like '%E9%') and c.offer_name like '%149%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E9149' tc,'qf' bq
from 
(select distinct * from cst3) a
where 
a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E9149' tc,'bz' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b<1;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,'E9149' tc,'cg' bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,a.b/a.p b from 
(
select distinct a.*,b.b,b.p from 
cst3 a left join cscdmaa1 b
on a.serv_id=b.serv_id
) a
) a where a.b>=1.5;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cs_e9149;
create temporary table cs_e9149 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into cs_e9149 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into cs_e9149 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into cs_e9149 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into cs_e9149 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into cs_e9149 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into cs_e9149 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into cs_e9149 select distinct d1,'h' bq,a c from cst8;
insert into cs_e9149 select distinct d1,'i' bq,a c from cst9;
insert into cs_e9149 select distinct * from csbaibiao;


drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;



--智领59
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'智领59' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name like '%智领3G%' 
and a.offer_comp_name like '%59%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'智领59' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name like '%智领3G%' 
and a.offer_comp_name like '%59%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name like '%智领3G%' 
and c.offer_name like '%59%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'智领59' tc,'qf' bq
from 
(select distinct * from cst3) a
where a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b<59;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b>=99;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cs_zl59;
create temporary table cs_zl59 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into cs_zl59 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into cs_zl59 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into cs_zl59 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into cs_zl59 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into cs_zl59 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into cs_zl59 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into cs_zl59 select distinct d1,'h' bq,a c from cst8;
insert into cs_zl59 select distinct d1,'i' bq,a c from cst9;
insert into cs_zl59 select distinct * from csbaibiao;

drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;

--智领79
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'智领79' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name like '%智领3G%' 
and a.offer_comp_name like '%79%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'智领79' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name like '%智领3G%' 
and a.offer_comp_name like '%79%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name like '%智领3G%' and c.offer_name like '%79%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'智领79' tc,'qf' bq
from 
(select distinct * from cst3) a
where a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b<79;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b>=120;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cs_zl79;
create temporary table cs_zl79 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into cs_zl79 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into cs_zl79 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into cs_zl79 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into cs_zl79 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into cs_zl79 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into cs_zl79 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into cs_zl79 select distinct d1,'h' bq,a c from cst8;
insert into cs_zl79 select distinct d1,'i' bq,a c from cst9;
insert into cs_zl79 select distinct * from csbaibiao;


drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;

--智领109
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'智领109' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>='2011-07-01 00:00:00' and a.completed_date<'2011-08-01 00:00:00' and atime>='2011-07-01 00:00:00'
and a.service_offer_name='售卖' 
and a.offer_comp_name like '%智领3G%' 
and a.offer_comp_name like '%109%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'智领109' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>='2011-07-01 00:00:00' and a.completed_date<'2011-08-01 00:00:00' and atime>='2011-07-01 00:00:00'
and a.service_offer_name='注销' 
and a.offer_comp_name like '%智领3G%' 
and a.offer_comp_name like '%109%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name like '%智领3G%' 
and c.offer_name like '%109%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'智领109' tc,'qf' bq
from 
(select distinct * from cst3) a
where a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b<99;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b>=150;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cs_zl109;
create temporary table cs_zl109 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into cs_zl109 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into cs_zl109 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into cs_zl109 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into cs_zl109 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into cs_zl109 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into cs_zl109 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into cs_zl109 select distinct d1,'h' bq,a c from cst8;
insert into cs_zl109 select distinct d1,'i' bq,a c from cst9;
insert into cs_zl109 select distinct * from csbaibiao;

drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;

--智领139
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'智领139' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name like '%智领3G%' 
and a.offer_comp_name like '%139%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'智领139' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name like '%智领3G%' 
and a.offer_comp_name like '%139%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name like '%智领3G%' 
and c.offer_name like '%139%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'智领139' tc,'qf' bq
from 
(select distinct * from cst3) a
where a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b<99;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b>=150;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cs_zl139;
create temporary table cs_zl139 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into cs_zl139 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into cs_zl139 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into cs_zl139 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into cs_zl139 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into cs_zl139 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into cs_zl139 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into cs_zl139 select distinct d1,'h' bq,a c from cst8;
insert into cs_zl139 select distinct d1,'i' bq,a c from cst9;
insert into cs_zl139 select distinct * from csbaibiao;


drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;

--智领189
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'智领189' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name like '%智领3G%' 
and a.offer_comp_name like '%189%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'智领189' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name like '%智领3G%' 
and a.offer_comp_name like '%189%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name like '%智领3G%' 
and c.offer_name like '%189%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'智领189' tc,'qf' bq
from 
(select distinct * from cst3) a
where a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b<99;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b>=150;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cs_zl189;
create temporary table cs_zl189 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into cs_zl189 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into cs_zl189 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into cs_zl189 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into cs_zl189 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into cs_zl189 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into cs_zl189 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into cs_zl189 select distinct d1,'h' bq,a c from cst8;
insert into cs_zl189 select distinct d1,'i' bq,a c from cst9;
insert into cs_zl189 select distinct * from csbaibiao;


drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;


--天翼畅聊19
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'天翼畅聊19套餐' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name like '%天翼畅聊19套餐%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'天翼畅聊19套餐' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name like '%天翼畅聊19套餐%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name like '%天翼畅聊19套餐%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'天翼畅聊19套餐' tc,'qf' bq
from 
(select distinct * from cst3) a
where a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b<19;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b>=24;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cs_ty19;
create temporary table cs_ty19 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into cs_ty19 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into cs_ty19 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into cs_ty19 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into cs_ty19 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into cs_ty19 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into cs_ty19 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into cs_ty19 select distinct d1,'h' bq,a c from cst8;
insert into cs_ty19 select distinct d1,'i' bq,a c from cst9;
insert into cs_ty19 select distinct * from csbaibiao;


drop table cst1;
drop table cst2;
drop table cst3;
drop table cst4;
drop table cst5;
drop table cst6;
drop table cst7;
drop table cst8;
drop table cst9;


--天翼畅聊39
--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'天翼畅聊39套餐' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖' 
and a.offer_comp_name like '%天翼畅聊39套餐%'
and c.product_id='208511296';
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'天翼畅聊39套餐' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.offer_comp_name like '%天翼畅聊39套餐%'
and c.product_id='208511296';
--drop table cst3;
create temporary table cst3 as
select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_CHN_PRD_OFFER_COMP_201109 b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.COMP_OFFER_ID=c.offer_id 
and c.offer_name like '%天翼畅聊39套餐%'
and b.OFFER_exp_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'));
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'天翼畅聊39套餐' tc,'qf' bq
from 
(select distinct * from cst3) a
where a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201109 where OWE_OFFLN_FLAG>3
);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst6;
create temporary table cst6 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b<19;
--drop table cst7;
create temporary table cst7 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq,b.b from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id
) a where a.b>=24;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cs_ty39;
create temporary table cs_ty39 as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into cs_ty39 select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into cs_ty39 select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into cs_ty39 select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into cs_ty39 select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into cs_ty39 select distinct d1,'f' bq,count(distinct serv_id) c from cst6 group by 1,2;
insert into cs_ty39 select distinct d1,'g' bq,count(distinct serv_id) c from cst7 group by 1,2;
insert into cs_ty39 select distinct d1,'h' bq,a c from cst8;
insert into cs_ty39 select distinct d1,'i' bq,a c from cst9;
insert into cs_ty39 select distinct * from csbaibiao;

--从这里结束执行第二段。

--从这里开始执行第三段。
--drop table cs_tt1;
create temporary table cs_tt1 as
select distinct c.d1,c.bq,c.c c,d.c d,e.c e,f.c f,g.c g,h.c h,i.c i,j.c j,k.c k,l.c l,m.c m from 
(select distinct d1,bq,sum(c) c from cs_ty18 group by 1,2) c,
(select distinct d1,bq,sum(c) c from CS_NC26 group by 1,2) d,
(select distinct d1,bq,sum(c) c from CS_cs26 group by 1,2) e,
(select distinct d1,bq,sum(c) c from CS_cs36 group by 1,2) f,
(select distinct d1,bq,sum(c) c from CS_cs46 group by 1,2) g,
(select distinct d1,bq,sum(c) c from CS_cs66 group by 1,2) h,
(select distinct d1,bq,sum(c) c from cs_e979 group by 1,2) i,
(select distinct d1,bq,sum(c) c from cs_e989 group by 1,2) j,
(select distinct d1,bq,sum(c) c from cs_e999 group by 1,2) k,
(select distinct d1,bq,sum(c) c from cs_e9119 group by 1,2) l,
(select distinct d1,bq,sum(c) c from cs_E9149 group by 1,2) m
where 
c.d1=d.d1 
and c.bq=d.bq
and c.d1=e.d1 
and c.bq=e.bq
and c.d1=f.d1 
and c.bq=f.bq
and c.d1=g.d1 
and c.bq=g.bq
and c.d1=h.d1 
and c.bq=h.bq
and c.d1=i.d1 
and c.bq=i.bq
and c.d1=j.d1 
and c.bq=j.bq
and c.d1=k.d1 
and c.bq=k.bq
and c.d1=l.d1 
and c.bq=l.bq
and c.d1=m.d1 
and c.bq=m.bq;
select distinct a.*,o.c o,p.c p,q.c q,r.c r,s.c s,t.c t,u.c u from 
cs_tt1 a,
(select distinct d1,bq,sum(c) c from cs_zl59 group by 1,2) o,
(select distinct d1,bq,sum(c) c from cs_zl79 group by 1,2) p,
(select distinct d1,bq,sum(c) c from cs_zl109 group by 1,2) q,
(select distinct d1,bq,sum(c) c from cs_zl139 group by 1,2) r,
(select distinct d1,bq,sum(c) c from cs_zl189 group by 1,2) s,
(select distinct d1,bq,sum(c) c from cs_ty19 group by 1,2) t,
(select distinct d1,bq,sum(c) c from cs_ty39 group by 1,2) u
where 
a.d1=o.d1 
and a.bq=o.bq
and a.d1=u.d1 
and a.bq=u.bq
and a.d1=p.d1 
and a.bq=p.bq
and a.d1=q.d1 
and a.bq=q.bq
and a.d1=r.d1 
and a.bq=r.bq
and a.d1=s.d1 
and a.bq=s.bq
and a.d1=t.d1 
and a.bq=t.bq
and a.d1=u.d1 
and a.bq=u.bq
order by 1,2;

--从这里结束执行第三段。直接将结果粘贴到EXCEL表中，注意营维部的对应位置。

drop table cs_ty18;
drop table CS_NC26;
drop table CS_cs26;
drop table CS_cs36;
drop table CS_cs46;
drop table CS_cs66;
drop table cs_e979;
drop table cs_e989;
drop table cs_e999;
drop table cs_E9119;
drop table cs_e9149;
drop table cs_zl59;
drop table cs_zl79;
drop table cs_zl109;
drop table cs_zl139;
drop table cs_zl189;
drop table cs_ty19;
drop table cs_ty39;


----其他类别，测试用，可以不管。

--其他手机
--drop table cst0;
create temporary table cst0 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from 
(
select distinct a.d1,a.serv_id,a.nbr acc_nbr,b.tc,'dd' bq,b.serv_id sd from 
cscdma a left join 
(select distinct a.d1,a.serv_id,a.nbr acc_nbr,c.offer_name tc,'dd' bq
from 
cscdma a,DS_PRD_OFFER_COMP_DETAIL b,DIM_CRM_PRODUCT_OFFER c
where 
a.serv_id=b.serv_id 
and b.offer_comp_id=c.offer_id 
and (c.offer_name like '%天翼%' 
or c.offer_name like '%e6%' 
or c.offer_name like '%e9%'
or c.offer_name like '%E6%' 
or c.offer_name like '%E9%'
or c.offer_name like '%全家%'
or c.offer_name like '%乡情%'
or c.offer_name like '%移动回家%'
or c.offer_name like '%移动回家%'
or c.offer_name like '%智领%'
)
and b.PROD_OFFER_INST_EXP_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.REMOVE_DATE>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'))) b on a.serv_id=b.serv_id where a.remove_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '3 month'))) a where a.sd is null;



--drop table cst1;
create temporary table cst1 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'其他手机' tc,'xz' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='售卖'
and a.serv_id in (select distinct serv_id from cst0);
--drop table cst2;
create temporary table cst2 as
select distinct b.mkt_channel_name d1,a.serv_id,a.acc_nbr,'天翼畅聊39套餐' tc,'cj' bq 
from 
csjg a,DIM_ZONE_AREA b,DS_CHN_PRD_SERV_44_201109 c
where 
a.serv_id=c.serv_id
and b.mkt_grid_id=c.mkt_grid_id
and a.completed_date>=(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month')) and a.completed_date<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and a.service_offer_name='注销' 
and a.serv_id in (select distinct serv_id from cst0);
--drop table cst3;
create temporary table cst3 as
select distinct * from cst0;
--drop table cst4;
create temporary table cst4 as
select distinct a.d1,a.serv_id,a.acc_nbr,'天翼畅聊39套餐' tc,'qf' bq
from 
(select distinct * from cst3) a
where a.serv_id in 
(
select distinct serv_id from DS_CHN_PRD_SERV_44_201108 where OWE_OFFLN_FLAG>3
)
and a.serv_id in (select distinct serv_id from cst0);
--drop table cst5;
create temporary table cst5 as
select distinct a.d1,a.serv_id,a.acc_nbr,a.tc,a.bq from
(
select distinct a.*,b.b from 
(select distinct * from cst3) a left join cscdmalc4 b on a.serv_id=b.serv_id
) a where a.b is null;
--drop table cst8;
create temporary table cst8 as
select distinct a.d1,'arpu' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b) a from 
(select distinct * from cst3) a left join cscdmaa b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table cst9;
create temporary table cst9 as
select distinct a.d1,'mou' bq,a.a/b.b a from 
(
select distinct a.d1,sum(b.b)/60 a from 
(select distinct * from cst3) a left join cscdmalc2 b on a.serv_id=b.serv_id group by 1
) a,(select d1,count(distinct serv_id) b from cst3 group by 1) b
where a.d1=b.d1;
--drop table csqt;
create table csqt as
select distinct d1,'a' bq,count(distinct serv_id) c from cst1 group by 1,2;
insert into csqt select distinct d1,'b' bq,count(distinct serv_id) c from cst2 group by 1,2;
insert into csqt select distinct d1,'c' bq,count(distinct serv_id) c from cst3 group by 1,2;
insert into csqt select distinct d1,'d' bq,count(distinct serv_id) c from cst4 group by 1,2;
insert into csqt select distinct d1,'e' bq,count(distinct serv_id) c from cst5 group by 1,2;
insert into csqt select distinct d1,'h' bq,a c from cst8;
insert into csqt select distinct d1,'i' bq,a c from cst9;
insert into csqt select distinct * from csbaibiao;
select distinct d1,bq,sum(c) c from csqt group by 1,2;
select distinct bq,sum(c) c from csqt group by 1;

