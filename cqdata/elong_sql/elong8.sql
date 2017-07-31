-- 沉默用户(语音)清单

-- 提取方法: 用户表中,到达标志为1, 而活跃标志为0的手机清单, 然后加提网格信息,竣工日期, 优惠信息等, 视营维部具体要求

--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
--create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
drop table if exists tgm_ls;
create temp table tgm_ls as 
select acc_nbr,a.serv_id, user_name
--, a.com_grid_id, jjx_code, user_grp_type
--, down_velocity
,  completed_date
--, remove_date, serv_id 
, com.com_channel_name, com.com_grid_name, a.mkt_cust_code
from ds_chn_prd_serv_com_33_201205 a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  serv_num=1
and product_id=208511296 
and active_serv_flag=0
;

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select a.*, pg_concat( distinct c.offer_name||',') comp_name
--,pg_concat(c.offer_name||',') c_name
,pg_concat(distinct d.offer_comp_type_desc4||',') 四级套餐
from tgm_ls a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='00A' 
left join dim_crm_product_offer c on b.offer_comp_id=c.offer_id
--and chh.base_flag=1
-- and t3.offer_kind='C'
--and t3.offer_kind not in ('0')
left join DIM_WD_OFFER_NEW_DIR_SECOND d on b.offer_comp_id=d.offer_comp_type_id6
and (d.offer_comp_type_desc4 not in ('移动优惠套餐','手机上网（国内）','无线宽带套餐（T2)','体验套餐','宽带套餐','天翼对讲（调度）','测试及体验套餐','小灵通优惠套餐1','总机服务','小灵通优惠套餐2','家庭组合套餐','来电提醒','政企移动套餐','综合办公-定制型')
	or (d.offer_comp_type_desc4='家庭组合套餐' and c.offer_name like '全家翼起来%%%%' and c.offer_name not like '全家翼起来承诺消费%%%%')
	or (d.offer_comp_type_desc4='政企移动套餐' and c.offer_name not in ('[IVPN]网内成员互打免费','天翼领航翼龙手机套餐39档次','天翼领航翼龙套餐宽带提速包','[IVPN]网内成员互打免费（OCS）','政企团购月承诺消费100元赠酷派D280'))
	)
and c.offer_name not in ('天翼领航宽带X折','天翼领航宽带X折优惠')
where d.base_flag=1
--关联套餐目录维表
group by acc_nbr,a.serv_id, user_name
,  completed_date
, com_channel_name, com_grid_name, mkt_cust_code

;

drop table if exists tgm_ls;

select '33';
--* from tmp_g2_33_201110;

