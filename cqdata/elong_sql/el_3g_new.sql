--天翼3G手机节(20120922-20121031)
--新增手机清单(只取竣工)
--两种口径: 1.用户表的竣工日期处于20120922-20121031
--2.从李鸣大师的竣工工单表中竣工日期处于上述时间段
/* 希望能够提取的字段:
日期	手机号码	姓名	新老	手机节	资费	机型	串号	受理人	揽收人	备注
*/
-- 丰都手机节劳动竞赛竣工时间从9月20日开始, 出错统计要排除20-21之间的.

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as
select distinct to_char(a.completed_date,'yyyy-mm-dd') 竣工日期, a.acc_nbr,a.user_name 用户姓名, a.serv_num 到达标志, resource_instance_code 串码, a.serv_id, a.remove_date, a.mkt_cust_code, cust.cust_created_date 合同号建立时间
, cust.user_ad_arrive_num+cust.user_postn_arrive_num AD加固话数量
, billing_mode_id 付费模式
, serv_state
--a.serv_id, a.product_id, a.mkt_cust_code, a.completed_date,b.offer_comp_id, b.offer_comp_instance_id,
--b.prod_offer_inst_id, b.prod_offer_id, prod_offer_inst_created_date
--, a.down_velocity, a.com_grid_id
, mkt.mkt_channel_name, mkt.mkt_grid_name --, a.mkt_cust_code
--, com.com_channel_name, com.com_grid_name --, a.mkt_cust_code
 from ds_chn_prd_serv_AREA_LAST_DAY a 
--left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='00A'
--left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
left join DIM_ZONE_area mkt on a.mkt_grid_id=mkt.mkt_grid_id 
left join DS_CHN_PRD_CUST_AREA_LAST_DAY cust on a.mkt_cust_code=cust.mkt_cust_code
where a.product_id in (
	--'102030001',
	'208511296')
and completed_date between '2012-09-20 00:00:00' and '2012-10-31 23:59:59'
--and completed_date >= '2012-09-20 00:00:00'	-- and '2012-10-31 23:59:59'
--and serv_num = 1
--distributed by (a.acc_nbr)
;

-- 建立优惠相关的临时表
drop table if exists tgm_tmp_offer;
create temp table tgm_tmp_offer as
select distinct a.acc_nbr,a.serv_id, b.offer_comp_id, t3.offer_id, t3.offer_name,b.offer_comp_instance_id, b.prod_offer_class_id
,b.prod_offer_id, t4.offer_name t4offer_name
,t5.offer_comp_type_desc3 d3
,t5.offer_comp_type_desc4 d4
,t5.offer_comp_type_desc5 d5
,t5.offer_comp_type_desc6 d6

from tmp_PACKGE_NAME_AREA_FEEMONTH a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='001' and prod_offer_inst_detail_state='001'
left join dim_crm_product_offer t3 on b.prod_offer_id=t3.offer_id 
left join dim_crm_product_offer t4 on b.offer_comp_id=t4.offer_id
left join DIM_WD_OFFER_NEW_DIR_SECOND t5 on b.offer_comp_id=t5.offer_comp_type_id6 
where b.offer_comp_id not in ('330855','334696')
--and t5.offer_comp_type_desc5 not in ('公交翼机通优惠套餐','翼龙套餐宽带提速3M') --再排除长寿的
--and t5.offer_comp_type_desc6 not like '%%翼龙语音包%%' 
--and t5.offer_comp_type_desc6 not like  '%%功能使用费%%'; --翼校通功能费
--此处不能使用有关t5表的字段, 否则会默认条件该字段不能为空.
;
delete from tgm_tmp_offer where d5 in ('公交翼机通优惠套餐','翼龙套餐宽带提速3M') --再排除长寿的
or d6 like  '%%功能使用费%%'; --翼校通功能费

drop table if exists tmp_offer2 ;
create temp table tmp_offer2 as 
select distinct a.*, b.offer_name 基础包, b.d3 套餐分类三, b.d4 套餐分类四 , c.offer_name 送话费
,d.offer_name 提速包, e.offer_name 送流量
,f.offer_name 龙卡或翼龙档次
,g.d6 手机节
from tmp_PACKGE_NAME_AREA_FEEMONTH a
-- 基础包
left join tgm_tmp_offer b on a.acc_nbr=b.acc_nbr and 
(b.d3 in ('政企非品牌套餐销售品', '我的e家品牌套餐销售品', '天翼品牌套餐销售品','Xta+C') 
       	or b.d4 in ('乡情网-2','无线宽带')
) 
and (b.d6 not like '%%翼龙语音包%%' or b.d6 not in ('翼校通功能费4元/月','翼校通月功能使用费4折') )
--送话费
left join tgm_tmp_offer c on a.acc_nbr=c.acc_nbr and c.offer_name like '%%送话费%%'
--提速包
left join tgm_tmp_offer d on a.acc_nbr=d.acc_nbr and d.offer_name like '%%宽带加C提速%%'
--送流量
left join tgm_tmp_offer e on a.acc_nbr=e.acc_nbr and (
       	e.offer_name like '%%流量包赠送%%' or e.offer_name in (
'330365' --	手机上网150M免费（三个月）_基础包
))
--龙卡话费包
left join tgm_tmp_offer f on a.acc_nbr=f.acc_nbr and (f.offer_name like '%%龙卡话费包%%' or f.offer_name like '%%翼龙语音包%%')
--3G手机节
left join tgm_tmp_offer g on a.acc_nbr=g.acc_nbr and g.d6 like '%%手机节终端优惠标识%%';


--还有加上新装的受理员工工号,以便区分代理商

-- 取系统探测机型,先建临时表取得最大值
drop table if exists tmp_ry1;
create temp table tmp_ry1 as 
select distinct acc_nbr, max(register_time) register_time from ds_evt_terminal_info_all_ry where acc_nbr in (select distinct acc_nbr from tmp_offer2) group by acc_nbr;
drop table if exists tmp_ry;
create temp table tmp_ry as select distinct b.* from tmp_ry1 a left join ds_evt_terminal_info_all_ry b on a.acc_nbr=b.acc_nbr and a.register_time=b.register_time;

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH AS select distinct aa.*
,d.ORG_NAME 受理部门,b.STAFF_DESC 受理员工,b.staff_code 受理工号,a.ACCEPT_MODE 受理方式
--,c.service_offer_name 受理类型
,a.HANDLE_TIME 受理时间
,a.staff_id
--,a.FINISH_TIME 竣工时间,a.PRE_HANDLE_FLAG 是否预受理,a.CUST_ORDER_ID 客户订单标识,
--a.ORDER_ITEM_ID 订单项标识,a.UNDO_FLAG 撤单标识,
--a.ORDER_ITEM_OBJ_ID 订单项业务对象标识,a.OFFER_KIND 销售品类型,a.ASK_SOURCE 受理来源
, ry.esn, ry.type
from tmp_offer2 aa
left join tmp_ry ry on aa.acc_nbr=ry.acc_nbr --探测机型
left join DS_PRD_OFFER_COMP_DETAIL comp on aa.serv_id=comp.serv_id and prod_offer_inst_detail_state='001' and prod_offer_class_id='10'
--left join DM_EVT_l_ORDER_ITEM a on aa.acc_nbr=a.acc_nbr and a.HANDLE_TIME>='2012-06-22 00:00:00'   and service_offer_id=1  
left join DM_EVT_l_ORDER_ITEM a on a.ORDER_ITEM_OBJ_ID=comp.PROD_OFFER_INST_ID and a.HANDLE_TIME>='2012-06-22 00:00:00'   and a.service_offer_id=1  
and a.order_item_obj_type_id in ('318775','313812')
--受理时间, 订购
--left join dim_crm_staff b on a.staff_id=b.party_role_id
left join  dwd_s_crm_staff b on a.staff_id=b.staff_id  --应该用2.0的配置表
left join dwd_s_crm_service_offer c on a.service_offer_id=c.service_offer_id
-- and c.service_offer_name='订购'
left join dim_crm_organization d on a.channel_id=d.party_id

and a.HANDLE_TIME>='2012-06-01 00:00:00'  --受理时间
distributed by (acc_nbr)
;
-- 删除无线宽带号码,只保留语音CDMA
delete from tmp_PACKGE_NAME_AREA_FEEMONTH where 基础包 like '%%无线宽带%%';

-- 部分工号没有配置姓名
update tmp_PACKGE_NAME_AREA_FEEMONTH set 受理部门='龙河烽火',受理员工='龙河烽火', 受理工号='FDFHLH1' where staff_id= 300001026;
update tmp_PACKGE_NAME_AREA_FEEMONTH set 受理部门='丰都中心营业厅',受理员工='杨秀梅', 受理工号='FDCQYYTYXM' where staff_id= 300000267 ; 

--select * from ST_MKT_MBL_FESTIVAL_DETAIL_DM  where area_name like '沙坪坝'  and handle_time <'2012-09-25 00:00:00' and handle_time>='2012-09-24 00:00:00' ;
select '33';
