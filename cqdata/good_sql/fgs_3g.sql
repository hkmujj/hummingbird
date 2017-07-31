--分公司3g数据
--分公司	C网出账用户	全量用户	活跃用户	流量（MB）	活跃率	户均流量	3G渗透率	智能机全量用户	智能机活跃用户	智能机流量（MB）	智能机活跃率	智能机户均流量	新增全量用户	新增活跃用户	新增用户流量（MB）	新增用户活跃率	新增用户户均流量

-----------------FEEMONTH------2012-04-01----2012-04-30----------

--用户行为分析-3G活跃用户 
select e.* ,a.serv_id ,c.net_throughput  into temp ryt_3g_active 
from ds_prd_group_tgserv_FEEMONTH a  
left join (select serv_id from ds_evt_group_call_FEEMONTH where CALL_DURATION > 0 group by serv_id) b 
on a.serv_id = b.serv_id  
left join (select serv_id,sum(net_throughput) net_throughput from ds_evt_group_call_FEEMONTH  
where  group_event_type_id = 7003 group by serv_id) c on a.serv_id = c.serv_id  
left join DS_CHN_PRD_SERV_MKT_AREA_FEEMONTH d on a.serv_id = d.serv_id 
left join dim_zone_area e on d.mkt_grid_id=e.mkt_grid_id and e.active_flag = 1 
where g3_flag = 0  and a.product_id = 10  
and b.SERV_ID is not null and net_throughput < 5*1024*1024;

select count(*) from ryt_3g_active;

--修正数据集市上的3G终端表，数据集市上的3G终端表存在结尾有空格的情况，例如：BW-BenWee S106  
select trim(evdo_type) evdo_type into temp dim_evdo_terminal_type_ry_asia from dim_evdo_terminal_type_ry; 

--取自注册3G用户 
select acc_nbr ,type ,register_time ,rank() over(partition by acc_nbr order by register_time desc)  into temp ryt_terminal 
from ds_evt_terminal_info_all_ry where date(register_time) <='LAST_DAY'
--'2012-04-30'
; 

select acc_nbr,type into temp ryt_terminal_3g from ryt_terminal where rank = 1 and type in (select evdo_type from dim_evdo_terminal_type_ry_asia); 

select count(*) from ryt_terminal_3g;

--3G沉默用户 
select e.*,a.serv_id  into temp ryt_3g_not_active 
from ds_prd_group_tgserv_FEEMONTH a --号码级数据用户资料表 
left join (select serv_id from ds_evt_group_call_FEEMONTH --号码级数据用户业务量表 
where CALL_DURATION > 0 /*通话时长大于0*/ group by serv_id) b on a.serv_id = b.serv_id  
left join (select serv_id,sum(net_throughput) net_throughput from ds_evt_group_call_FEEMONTH where  group_event_type_id = 7003 /*有EVDO流量*/group by serv_id) c on a.serv_id =c.serv_id  
left join DS_CHN_PRD_SERV_MKT_AREA_FEEMONTH d on a.serv_id = d.serv_id 
left join dim_zone_area e on d.mkt_grid_id = e.mkt_grid_id and e.active_flag = 1 
where g3_flag = 0 /*上网卡套餐标签*/ and a.product_id = 10 and c.net_throughput is null 
and b.SERV_ID is not null 
and a.acc_nbr in(select acc_nbr from ryt_terminal_3g); 

--汇总全量用户 
select serv_id,mkt_grid_id,net_throughput/1024 flow,1 active_flag into temp ryt_3g_all from ryt_3g_active; 
insert into ryt_3g_all select serv_id,mkt_grid_id,0 flow,0 active_flag from ryt_3g_not_active; 

-------------------------------------------以上圈定目标客户--------------------------------------------------

select a.*,b.acc_nbr into temp ryt1
from ryt_3g_all a,DS_CHN_PRD_SERV_MKT_AREA_FEEMONTH b
where a.serv_id = b.serv_id;

--终端型号
select distinct a.*,b.type into temp ryt2
from ryt1 a left outer join ryt_terminal b
on a.acc_nbr = b.acc_nbr and b.rank = 1;

--智能机标识
select distinct a.*,b.phone_type into temp ryt3
from ryt2 a left outer join dim_smart_phone_type_ry b
on a.type = b.phone_type;

--局向
select b.mkt_area_name,b.mkt_channel_name,b.mkt_grid_name,a.serv_id,a.acc_nbr,a.type,a.phone_type smart_flag,a.active_flag,a.flow
into temp ryt4 from ryt3 a left outer join dim_zone_area b
on a.mkt_grid_id = b.mkt_grid_id;

update ryt4 set smart_flag = '1' where smart_flag is not null;
update ryt4 set smart_flag = '0' where smart_flag is null;

--新增标识
select a.*,b.onln_flg new_flag into temp ryt5
from ryt4 a left outer join DS_CHN_PRD_SERV_MKT_AREA_FEEMONTH b
on a.serv_id = b.serv_id and 
--b.created_date >= '2012-04-01 00:00:00' and b.created_date <= '2012-04-30 23:59:59' 
b.created_date like '{yyyy-mm}%%' and onln_flg = '1';

---套餐情况
select distinct a.owner_id,
         case when a.INIT_VALUE = '0' then a.PEAK_VALUE
              when a.PEAK_VALUE = '0' then a.INIT_VALUE
            end "初始值",
         a.BALANCE 使用量,
         case when a.INIT_VALUE = '0' then a.PEAK_VALUE-a.BALANCE
              when a.PEAK_VALUE = '0' then a.INIT_VALUE-a.BALANCE
         end "剩余量",
         case when c.acc_unit = 'MB'  then  c.acc_unit 
         end "流量",
         case when c.acc_unit = '分钟'  then  c.acc_unit 
         end "时长"
into temp ryt_tc_all
from DM_PRD_OFFER_ACCUMULATOR  a left join DM_EVT_QUERY_ACCUMULATOR_CONFIG_FEEMONTH b 
on a.RATABLE_RESOURCE_ID = b.RATABLE_RESOURCE_ID 
left join DM_EVT_QUERY_ACCUMULATOR_FEEMONTH c on b.query_accumulator_id = c.query_accumulator_id 
where a.eff_date like '{yyyy-mm}%%'
--a.eff_date = '2012-04-01 00:00:00'
;

select distinct b.serv_id,b.acc_nbr,b.mkt_grid_id,a.* into temp ryt_flow_taoc_FEEMONTH 
from ryt_tc_all a ,DS_CHN_PRD_SERV_MKT_AREA_FEEMONTH b 
where a.owner_id = b.serv_id and a.流量 like 'MB' and b.product_id = '208511296' and b.state = '00A' and b.serv_state = '2HA';


select distinct a.*,sum(b.初始值)/1024 start_values,sum(b.使用量)/1024 used_values,sum(b.剩余量)/1024 unused_values into temp ryt6
from ryt5 a left outer join ryt_flow_taoc_FEEMONTH b
on a.serv_id = b.serv_id group by 1,2,3,4,5,6,7,8,9,10;


--3G用户清单

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select mkt_area_name,mkt_channel_name,mkt_grid_name,serv_id,acc_nbr,type,smart_flag,active_flag,flow,new_flag,start_values,used_values,unused_values 
--into temp ryt_3g_AREA_FEEMONTH
from ryt6;

/* 统计放在电子表格里自己手工操作更方便
--C网出账用户
select a.serv_id,b.mkt_area_name,b.MKT_CHANNEL_NAME into temp ryt_acct_c
from DS_CHN_PRD_SERV_MKT_AREA_FEEMONTH a,dim_zone_area b
where a.mkt_grid_id = b.mkt_grid_id and a.ACCT_SERV_FLAG = 1 and a.product_id = 208511296;
-- update ryt_acct_c set mkt_area_name = '大足' where mkt_area_name like '%%丰都%%'; update ryt_acct_c set mkt_area_name = '丰都' where mkt_area_name like '%%万盛%%';


--------------统计FEEMONTH--------------
select mkt_area_name 分公司,mkt_channel_name 营维部,mkt_grid_name 网格名称,serv_id,acc_nbr 用户电话号码,type 终端型号,smart_flag 智能机标识,active_flag 活跃标识,new_flag 当月新增标识,flow 当月EVDO流量,start_values 套餐流量初始值,used_values 套餐流量使用量,unused_values 套餐流量剩余量
from ryt_3g_AREA_FEEMONTH where mkt_area_name like '%%丰都%%' order by 1,2; --3G用户清单


--全量用户
select count(distinct serv_id),sum(flow) from ryt_3g_AREA_FEEMONTH; --3G全量用户,evdo流量
select count(active_flag) from ryt_3g_AREA_FEEMONTH where active_flag = 1; --活跃用户数
select count(active_flag) from ryt_3g_AREA_FEEMONTH where active_flag = 0; --沉默用户数

--智能机用户
select count(distinct serv_id),sum(flow) from ryt_3g_AREA_FEEMONTH where smart_flag = 1; --3G全量用户,evdo流量
select count(active_flag) from ryt_3g_AREA_FEEMONTH where active_flag = 1 and smart_flag = 1; --活跃用户数
select count(active_flag) from ryt_3g_AREA_FEEMONTH where active_flag = 0 and smart_flag = 1; --沉默用户数

--新增用户
select count(distinct serv_id),sum(flow) from ryt_3g_AREA_FEEMONTH where new_flag is not null; --3G全量用户,evdo流量
select count(active_flag) from ryt_3g_AREA_FEEMONTH where active_flag = 1 and new_flag is not null; --活跃用户数
select count(active_flag) from ryt_3g_AREA_FEEMONTH where active_flag = 0 and new_flag is not null; --沉默用户数


--流量分段
select count(*),0 from ryt_3g_AREA_FEEMONTH where flow = 0 group by 2 union
select count(*),1 from ryt_3g_AREA_FEEMONTH where flow > 0 and flow <1 group by 2 union
select count(*),2 from ryt_3g_AREA_FEEMONTH where flow >= 1 and flow <5 group by 2 union
select count(*),3 from ryt_3g_AREA_FEEMONTH where flow >= 5 and flow <30 group by 2 union
select count(*),4 from ryt_3g_AREA_FEEMONTH where flow >= 30 and flow <100 group by 2 union
select count(*),5 from ryt_3g_AREA_FEEMONTH where flow >= 100 and flow <500 group by 2 union
select count(*),6 from ryt_3g_AREA_FEEMONTH where flow >= 500
 order by 2;

--智能机流量分段
select count(*),0 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow = 0 group by 2 union
select count(*),1 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow > 0 and flow <1 group by 2 union
select count(*),2 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow >= 1 and flow <5 group by 2 union
select count(*),3 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow >= 5 and flow <30 group by 2 union
select count(*),4 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow >= 30 and flow <100 group by 2 union
select count(*),5 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow >= 100 and flow <500 group by 2 union
select count(*),6 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow >= 500
 order by 2;
 

-----------------------分公司统计---------------------
drop table if exists qij_1;
drop table if exists qij_2;
drop table if exists qij_3;
drop table if exists qij_4;
drop table if exists qij_5;
drop table if exists qij_6;
drop table if exists qij_7;
drop table if exists qij_8;
drop table if exists qij_9;
drop table if exists qij_10;
drop table if exists qij_11;
drop table if exists qij_12;

select mkt_area_name 分公司,MKT_CHANNEL_NAME 营维部,count(distinct serv_id) 手机到达数 into temp qij_1 from ryt_acct_c where mkt_area_name like '%%丰都%%' group by 1,2 order by 1,2; --C网出账用户

select mkt_area_name 分公司,MKT_CHANNEL_NAME 营维部,count(distinct serv_id) ЗG用户到达数,sum(flow) ЗG用户evdo流量合计 into temp qij_2 from ryt_3g_AREA_FEEMONTH where mkt_area_name like '%%丰都%%' group by 1,2 order by 1,2; --3G全量用户,流量

select mkt_area_name 分公司,MKT_CHANNEL_NAME 营维部,count(active_flag) ЗG活跃用户数 into temp qij_3 from ryt_3g_AREA_FEEMONTH where active_flag = 1 and mkt_area_name like '%%丰都%%' group by 1,2 order by 1,2; --3G活跃用户

select mkt_area_name 分公司,MKT_CHANNEL_NAME 营维部,count(active_flag) ЗG沉默用户数 into temp qij_4 from ryt_3g_AREA_FEEMONTH where active_flag = 0 and mkt_area_name like '%%丰都%%' group by 1,2 order by 1,2; --3G沉默用户

select mkt_area_name 分公司,MKT_CHANNEL_NAME 营维部,count(distinct serv_id) 智能机到达数,sum(flow) 智能机用户evdo流量合计 into temp qij_5 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and mkt_area_name like '%%丰都%%' group by 1,2 order by 1,2; --智能机全量用户,evdo流量

select mkt_area_name 分公司,MKT_CHANNEL_NAME 营维部,count(active_flag) 智能机活跃用户数 into temp qij_6 from ryt_3g_AREA_FEEMONTH where active_flag = 1 and smart_flag = 1 and mkt_area_name like '%%丰都%%' group by 1,2 order by 1,2; --智能机活跃用户

select mkt_area_name 分公司,MKT_CHANNEL_NAME 营维部,count(active_flag) 智能机沉默用户数 into temp qij_7 from ryt_3g_AREA_FEEMONTH where active_flag = 0 and smart_flag = 1 and mkt_area_name like '%%丰都%%' group by 1,2 order by 1,2; --智能机沉默用户

select a.分公司,a.营维部,a.ЗG用户到达数-b.智能机到达数 非智能机到达数,a.ЗG用户evdo流量合计-b.智能机用户evdo流量合计 非智能机用户evdo流量合计 into temp qij_8 from qij_2 a,qij_5 b where a.营维部=b.营维部 order by 1,2; --非智能机全量用户,evdo流量

select a.分公司,a.营维部,a.ЗG活跃用户数-b.智能机活跃用户数 非智能机活跃用户,c.ЗG沉默用户数-d.智能机沉默用户数 非智能机沉默用户 into temp qij_9 from qij_3 a,qij_6 b,qij_4 c,qij_7 d where a.营维部=b.营维部 and a.营维部=c.营维部 and a.营维部=d.营维部 order by 1,2; --非智能机活跃用户,非智能机沉默用户

select mkt_area_name 分公司,MKT_CHANNEL_NAME 营维部,count(distinct serv_id) 当月新增ЗG用户数,sum(flow) 当月新增ЗG用户evdo流量合计 into temp qij_10 from ryt_3g_AREA_FEEMONTH where new_flag is not null and mkt_area_name like '%%丰都%%' group by 1,2 order by 1,2; --当月新增3G用户,流量

select mkt_area_name 分公司,MKT_CHANNEL_NAME 营维部,count(active_flag) 当月新增ЗG活跃用户数 into temp qij_11 from ryt_3g_AREA_FEEMONTH where active_flag = 1 and new_flag is not null and mkt_area_name like '%%丰都%%' group by 1,2 order by 1,2; --当月新增3G活跃用户

select mkt_area_name 分公司,MKT_CHANNEL_NAME 营维部,count(active_flag) 当月新增ЗG沉默用户数 into temp qij_12 from ryt_3g_AREA_FEEMONTH where active_flag = 0 and new_flag is not null and mkt_area_name like '%%丰都%%' group by 1,2 order by 1,2; --当月新增3G沉默用户

select mkt_area_name 分公司,MKT_CHANNEL_NAME 营维部,count(distinct serv_id) 当月新增智能机用户数,sum(flow) 当月新增智能机用户evdo流量合计 from ryt_3g_AREA_FEEMONTH where new_flag is not null and smart_flag = 1 and mkt_area_name like '%%丰都%%' group by 1,2 order by 1,2; --当月新增智能机(用于考核数据)

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

------合并-----------
        select a.分公司,
               a.营维部,
               a.手机到达数,
               b.ЗG用户到达数,
               c.ЗG活跃用户数,
               d.ЗG沉默用户数,
               b.ЗG用户evdo流量合计,
               e.智能机到达数,
               f.智能机活跃用户数,
               g.智能机沉默用户数,
               e.智能机用户evdo流量合计,
               h.非智能机到达数,
               i.非智能机活跃用户,
               i.非智能机沉默用户,
               h.非智能机用户evdo流量合计,
               j.当月新增ЗG用户数,
               k.当月新增ЗG活跃用户数,
               l.当月新增ЗG沉默用户数,
               j.当月新增ЗG用户evdo流量合计
               from qij_1 a 
               left join qij_2 b on a.营维部=b.营维部
               left join qij_3 c on a.营维部=c.营维部
               left join qij_4 d on a.营维部=d.营维部
               left join qij_5 e on a.营维部=e.营维部
               left join qij_6 f on a.营维部=f.营维部
               left join qij_7 g on a.营维部=g.营维部
               left join qij_8 h on a.营维部=h.营维部
               left join qij_9 i on a.营维部=i.营维部
               left join qij_10 j on a.营维部=j.营维部
               left join qij_11 k on a.营维部=k.营维部
               left join qij_12 l on a.营维部=l.营维部
               and a.分公司 like '%%丰都%%';

*/
select '33';
--* from tmp_g2_AREA_201110;
