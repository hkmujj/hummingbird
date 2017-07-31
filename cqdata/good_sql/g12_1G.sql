--
--3G辅导员1G流量赠送清单
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select b.acc_nbr,b.user_name, prod_offer_inst_created_date
from ds_prd_offer_comp_detail a
left join ds_chn_prd_serv_{area}_{yyyymm} b on a.serv_id=b.serv_id
--left join dim_crm_product_offer t3 on a.offer_comp_id=t3.offer_id
--where a.offer_comp_id=333857 --新员工500M
where a.offer_comp_id in ('10004657','10004662') --后付,预付,老联通, 
--预付的丰都没有找到实例,所以没有商品包代码
--and a.prod_offer_inst_state='00A'
--and a.prod_offer_inst_state='001'  --使用这个状态,表示当前处于有效,即使当月已经拆机
and a.prod_offer_inst_detail_state='001' --使用这个状态,更有可能表示CRM当前的状态
and b.serv_id is not null
;
select 'AREA';
--* from tmp_g2_AREA_201110;

