--提所有网吧清单
--字段至少有以下,以便方便营维部快速认领
--号码 安装地址 营销网格 维护网格 营销客户编码 代表号码维护网格 代表号码维护营维部 产权客户姓名 产权客户地址

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select a.*
,c1.com_channel_name 维护营维部, c1.com_grid_name 维护网格
,c2.com_channel_name 代表号码维护营维部, c2.com_grid_name 代表号码维护网格
,area.mkt_channel_name 营销营维部, area.mkt_grid_name 营销网格
,cust.cust_name 产权客户姓名, cust.cust_address 产权客户地址
, mkt_cust.cust_address 营销客户地址
, mkt_cust.deputy_acc_nbr 营销客户代表号码, mkt_cust.USER_POSTN_ARRIVE_NUM 营销客户普通电话到达数
 from 
(
select acc_nbr, user_name, prod_addr, mkt_grid_id, com_grid_id, deputy_com_grid_id 
, down_velocity 下行速率, mkt_cust_code, mkt_cust_name 营销客户姓名,  cust_id, 
pro.product_name 产品名称
 from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_crm_product pro on a.product_id=pro.product_id
where 
user_name like '%%网吧%%'
--product_id=102030002  --产品为lan虚拨
--and serv_num=1	--到达标记为1
) a
left join DIM_ZONE_COMM c1 on a.com_grid_id=c1.com_grid_id
left join DIM_ZONE_COMM c2 on a.deputy_com_grid_id=c2.com_grid_id
left join DIM_ZONE_area area on a.mkt_grid_id=area.mkt_grid_id
left join DS_PTY_CUST_FEEMONTH cust on a.cust_id=cust.cust_id
left join DS_CHN_PRD_CUST_AREA_LAST_DAY mkt_cust on a.mkt_cust_code=mkt_cust.mkt_cust_code

limit 10000
;

;
select '33';
--* from tmp_g2_33_201110;

