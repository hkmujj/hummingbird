--提分公司FTTH设备清单
--本脚本的执行时间在10秒左右
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select acc_nbr 用户电话号码, user_name 用户名称, prod_addr 用户地址, a.state 用户状态, serv_state 设备状态, down_velocity 下行带宽, serv_num 到达标记, mkt_cust_code 合同号, mdf_code 配线架编码, jjx_code 交接箱编码, fxh_code 分线盒编码, com.com_channel_name 维护营维部, com.com_grid_name 维护网格, pro.product_name 四级产品名称

,case when rule_type='000' then '非链路规则'  when rule_type='001' then '交接箱'  when rule_type='002' then '配线架'  when rule_type='003' then '分线盒'  when rule_type='004' then 'CRM母局'  when rule_type='005' then 'GIS局站'  when rule_type='006' then '小区编码'  when rule_type='007' then '链路用户号段规则'  when rule_type='008' then 'CRM局站'  when rule_type='009' then '受理工号'  when rule_type='010' then '综合配线箱' end  维护线链路认领规则

from 
ds_chn_prd_serv_com_AREA_FEEMONTH a
left join 
 DM_EVT_ALL_SERV_ACCESS_MODE_FEEMONTH b on a.serv_id=b.prodinscode
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
left join dim_crm_product pro on a.product_id=pro.product_id
--where a.acc_nbr in ('023-70708080','023-70701899')
where b.accessmode=2
--limit 10
;

select '33';
--* from tmp_g2_33_201110;

