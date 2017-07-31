-- 1.截止某月的手机清单
-- 2.机型清单(及是否智能机)
-- 3.某月的流量

--最后注册时间表
drop table if exists tmp_{area}_cdma_FEEMONTH;
create temp table tmp_{area}_cdma_FEEMONTH as 
select a.acc_nbr,serv_id, user_name, a.mkt_grid_id --, a.completed_date
,mkt.mkt_channel_name, mkt.mkt_grid_name
, max(register_time) register_time from ds_chn_prd_serv_mkt_{area}_{yyyymm} a 
left join ds_evt_terminal_info_all_ry b on a.acc_nbr=b.acc_nbr and b.register_time<'NEXT_MONTH_TIME'
left join DIM_ZONE_area mkt on a.mkt_grid_id=mkt.mkt_grid_id
where product_id=208511296  --手机
and serv_num=1
group by 1,2 ,3, 4, 5, 6
;
--机型,操作系统表
drop table if exists tmp_{area}_cdma_FEEMONTH_2 ;
create temp table tmp_{area}_cdma_FEEMONTH_2 as 
select a.*, b.esn, b.factory, b.type, system
, g3.serv_id serv_id_3G, g3.intell_flag 
from tmp_{area}_cdma_FEEMONTH a
left join ds_evt_terminal_info_all_ry b on a.acc_nbr=b.acc_nbr and a.register_time=b.register_time
left join (
	select phone_type, system from dim_smart_phone_type_ry 
	union select 'HW-HUAWEI C8600', 'Android 2.2'  --C8600系统配置里名称不正确
	union select 'ACM-iPhone OS', 'ios' --苹果
	union select 'YL-Coolpad D5800', 'Android 2.3'
	union select 'MOT-XT681', 'Android 2.3'
	union select 'ZTE-C N700', 'Android 2.2'
	union select 'HTC-A510c', 'Android 2.3'
	union select 'SW-Q68', 'Android 2.2'
	union select 'LNV-Lenovo A790e', 'Android 2.3'
	union select 'HW-HUAWEI C8860E', 'Android 2.3'
	union select 'BD-Bird N760', 'Android 2.2'
) ry
on b.type=ry.phone_type
left join DS_PRD_SERV_3G_FEEMONTH g3 on a.serv_id=g3.serv_id
;

--流量表
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select a.*
,g3.g3_flow_flag, x1_flow_flag, g3_byte_in
from 
(select a.acc_nbr,a.serv_id, a.user_name ,a.register_time
	, a.esn, a.factory, a.type, a.system
	,a.mkt_channel_name, a.mkt_grid_name , a.serv_id_3g
	, a.intell_flag ,sum((byte_in+byte_out)/Cdr_Piece)/1024/1024 Mbyte
,sum((byte_in+byte_out)/Cdr_Piece) byte
from tmp_{area}_cdma_FEEMONTH_2 a 
left join ds_evt_ps_area_{area}_{yyyymm} b on a.acc_nbr=b.billing_nbr and 
event_type_id in ('60645', '60646', '60640', '60641', '60642', '60643', '60644', '60647', '60648', '60650', '60651', '60649', '60652', '60653', '60654', '60655', '60656', '60657', '90175', '90176', '90170', '90171', '90172', '90173', '90174', '90177', '90178', '90180', '90181', '90179', '90182', '90183', '90184', '90185', '90186', '90187')  
group by 1,2,3,4,5, 6, 7, 8, 9, 10, 11, 12
) a 
left join DS_PRD_FLOW_SERV_3G_ALL_FEEMONTH g3 on a.acc_nbr=g3.acc_nbr
and g3.c_bill_flag=1  --移动出帐用户标志
;
select '33';
--提智能机
--select count(*) from tmp_{area}_cdma_{yyyymm}_3  a where a.system is not null;
--select * from tmp_{area}_cdma_{yyyymm}_3 where system is not null ;
--提有流量的非智能机
--select * from tmp_{area}_cdma_{yyyymm}_3 where system is null and mbyte>0;

