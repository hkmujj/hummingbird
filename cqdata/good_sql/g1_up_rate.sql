--月受理工单--提速工单,不含撤单
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct 
      to_char(ATIME,'yyyy-mm-dd') 受理时间
,to_char(ATIME,'yyyy-mm') 受理月份
       ,ORDER_ID 订单编号
	,accept_id 受理单编号
       ,product_name 产品类型
       ,SERVICE_offer_name 服务提供
       ,product_no 产品号码
       ,cust_name  用户名称
	,cust_code
       --,prod_addr  安装地址
       ,to_char(COMPLETED_DATE,'yyyy-mm-dd') 竣工时间
,case when accept_state=0 then '已经受理未算费' when accept_state=1 then '已经算费未确认' when accept_state=2 then '已经确认' when accept_state=2.1 then '已确认(预受理)' when accept_state=3 then '已经质检(进入生产)' when accept_state=4 then '等待竣工(生产完成)' when accept_state=5 then '已经竣工' else accept_state end 受理单状态
	--ACCEPT_STATE 受理单状态
	-- 0 已经受理未算费;1 已经算费未确认;2 已经确认;2.1 已确认(预受理);3 已经质检(进入生产);4 等待竣工(生产完成);5 已经竣工
	--,org_name   组织名称
       ,staff_desc 受理人
       ,staff_code 受理工号
       --,region_name 局站名称
       --,region_code 局站编码
       ,COM_CHANNEL_NAME 维护营维部
       ,COM_GRID_NAME  维护网格
       ,date(now())-date(ATIME) 客户等待天数 
       --,'未竣工' 竣工标志 
 from 

(
select t11.*,t12.SERVICE_OFFER_NAME from 
(
select t10.product_name,t9.* from 
(
select t8.staff_desc,t8.staff_code,t7.* from 
(
select t6.COM_CHANNEL_NAME,t6.COM_GRID_NAME,t5.* from
(
select t3.*,t4.mkt_comm_id from 
(
select t2.region_name,t2.region_code,t1.* from 
(
select * from DM_EVT_SR_ACCEPT  where DEAL_EXCH_ID ='AREA_ID'  --处理局代码    
                         --and SERVICE_ID in('10000') --新装工单
                         --and product_id in('102030001','102010002','208511177') --adsl宽带，adsl专线，ITV
                         --and COMPLETED_DATE>now() --竣工时间大于当前时间, 即时没竣工
			--and ACCEPT_STATE<>5 --工单状态不等于已竣工, 原李鸣使用上面一行的竣工时间来判断竣工与否
			-- 0 已经受理未算费;1 已经算费未确认;2 已经确认;2.1 已确认(预受理);3 已经质检(进入生产);4 等待竣工(生产完成);5 已经竣工
			
			and atime like '{yyyy-mm}%%'
			and service_id='11101'
                         --and UNDO_FLAG=1 --没撤单
) t1 inner join DIM_CRM_REGION t2 on t1.SUB_EXCH_ID=t2.region_id --关联到局站名称
) t3 left join (select * from DIM_CHN_RULE where rule_state=1 and rule_type='008') t4 on 
t3.region_code=t4.rule_code  --CRM局站规则关联到维护网格ID
) t5 left join DIM_ZONE_COMM t6 on t5.mkt_comm_id=t6.COM_GRID_ID --关联到维护网格名称
) t7 left join DIM_CRM_STAFF t8 on t7.OPER_ID=t8.PARTY_ROLE_ID  --关联到受理人名称
) t9 left join DIM_PRODUCT t10 on t9.product_id=t10.PRODUCT_ID  --关联到产品名称
) t11 left join DIM_CRM_SERVICE_OFFER t12 on t11.service_id=t12.SERVICE_OFFER_ID  --关联到服务提供名称
) t13 left join (select * from DIM_CRM_ORGANIZATION where state='00A') t14 on 
t13.DEPART_ID=t14.party_id order by to_char(ATIME,'yyyy-mm-dd'); --关联到受理人的组织名称

--应客服中心要求,增加联系电话字段.
create temp table temp_ttt1 as 
select a.*, b.telephone 联系电话 from tmp_PACKGE_NAME_AREA_FEEMONTH a
left join DS_PTY_CUST_LAST_DAY b on a.cust_code=b.cust_code
;
drop table tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select * from temp_ttt1;
select '33';
