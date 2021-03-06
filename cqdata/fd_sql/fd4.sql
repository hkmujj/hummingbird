-- 丰都宽带2012年发生调速到4M清单

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select a.*
,cdma_new.acc_nbr cdma_new
--,b.offer_comp_id, prod_offer_id 
,c.offer_name, c_prod.offer_name prod_name
,0.0 score
from 
(
select a.*, b.offer_comp_id, b.prod_offer_id
,prod_offer_inst_created_date
,offer_comp_instance_id
from      (
select acc_nbr, user_name, a.com_grid_id, jjx_code, user_grp_type
, down_velocity,  completed_date, remove_date, serv_id
, com.com_channel_name, com.com_grid_name
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  serv_num=1
and product_id=102030001
and down_velocity in ('4M','5M','6M','7M')
and serv_id not in (select serv_id from ds_chn_prd_serv_com_AREA_201112 
	where down_velocity in ('4M','5M','6M','7M') ) -- 是2012提速的
and completed_date between '2012-01-01' and '2012-03-10'
-- or remove_date between '2012-01-01' and '2013-01-01'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state='00A' 
and b.prod_offer_inst_created_date>='2012-01-01'
and b.offer_comp_id in (
 326578 --	328963	全翼起来宽带提速2M
,325038 --	324958	全家翼起来宽带提速1M
,331507	--331508	新e9-4M不限时119套餐（全话费版）
,330398	--330399	承诺消费119元提速2M
,329628	--329629	新e9-4M不限时119套餐
,329639	--329640	新e9-4M不限时189套餐（含iTV）
,330675 --承诺消费119元提速1M
,330677 --承诺消费119元提速3M
,330689 --新e9-4M不限时119套餐（全话费版试点版）
,331488 --新e9-4M不限时149套餐（全话费版）
,331507 --新e9-4M不限时119套餐（全话费版）
,331516 --新e9-4M不限时119套餐
)

    ) a

left join dim_crm_product_offer c on a.offer_comp_id=c.offer_id 
left join dim_crm_product_offer c_prod on a.prod_offer_id=c_prod.offer_id 
left join tmp_fd3_AREA_FEEMONTH cdma_new on a.offer_comp_instance_id=cdma_new.offer_comp_instance_id
order by a.acc_nbr

;
--因速率为2M以下，或套餐为426单宽带，不能参与积分的清单和统计
--可以在积分算完后提积分为0的观察状况。
--select * from tmp_PACKGE_NAME_AREA_FEEMONTH where down_velocity in ('1M','512K','640K', '1.5M') or offer_comp_id in (121244);

update tmp_PACKGE_NAME_AREA_FEEMONTH set score=20;

--同套餐手机已享受119积分的,宽带不再享受提速积分
update tmp_PACKGE_NAME_AREA_FEEMONTH SET score=0 where cdma_new is not null  and offer_name not in (
'承诺消费119元提速1M',
'承诺消费119元提速2M',
'承诺消费119元提速3M');

select '33';
--* from tmp_g2_33_201110;
