--提乡情卡12元返档清单

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct t15.*,t16.OFFER_COMP_TYPE_DESC6 套餐名称 from 
(
select t13.*,t14.COMP_OFFER_ID 商品编码 from 
(
select distinct to_char(ATIME,'yyyy-mm') 受理月份
       ,ORDER_ID 订单编号
       ,accept_id 受理编号
       ,product_name 产品类型
       ,SERVICE_offer_name 服务提供
       ,product_no 产品号码
       ,serv_id 用户标识
       ,RESOURCE_INSTANCE_CODE 手机串号
       ,user_name  用户名称
       ,CUST_ADDRESS  客户地址
       ,to_char(ATIME,'yyyy-mm-dd') 返档时间
       ,org_name   组织名称
       ,staff_desc 受理人
       ,staff_code 受理工号
 from (
select t9.*,t10.SERVICE_OFFER_NAME from 
(
select t8.product_name,t7.* from 
(
select t6.staff_desc,t6.staff_code,t5.* from 
(
select t3.*,t4.CUST_ADDRESS from 
(
select t2.user_name,t2.RESOURCE_INSTANCE_CODE,t2.cust_id,t1.* from 
(
select ATIME,ORDER_ID,accept_id,product_id,product_no,serv_id,COMPLETED_DATE,DEPART_ID,OPER_ID,service_id from DM_EVT_SR_ACCEPT  
where DEAL_EXCH_ID ='{area_id}'  --处理局代码    
                         and SERVICE_ID in('100535', '100001') --资料反档
                         and product_id='208511296' --语音CDMA
                         and UNDO_FLAG=1 --没撤单
                         and to_char(ATIME,'yyyy')='2012') t1 
                         inner join DS_CHN_PRD_SERV_{area}_{yyyymmdd} t2 on t1.serv_id=t2.serv_id 
) t3 inner join DS_PTY_CUST_{yyyymmdd} t4 on t3.cust_id=t4.cust_id
) t5 left join DIM_CRM_STAFF t6 on t5.OPER_ID=t6.PARTY_ROLE_ID  --关联到受理人名称
) t7 left join DIM_PRODUCT t8 on t7.product_id=t8.PRODUCT_ID  --关联到产品名称
) t9 left join DIM_CRM_SERVICE_OFFER t10 on t9.service_id=t10.SERVICE_OFFER_ID  --关联到服务提供名称
) t11 left join (select * from DIM_CRM_ORGANIZATION where state='00A') t12 on t11.DEPART_ID=t12.party_id --关联到受理人的组织名称
) t13 inner join DS_CHN_PRD_OFFER_COMP_{yyyymmdd} t14 on t13.用户标识=t14.serv_id where t14.COMP_OFFER_ID='324768'
) t15 inner join DIM_WD_OFFER_NEW_DIR_SECOND t16 on t15.商品编码=t16.OFFER_COMP_TYPE_ID6
order by 订单编号
;	
select '33';
--* from tmp_g2_33_201110;
