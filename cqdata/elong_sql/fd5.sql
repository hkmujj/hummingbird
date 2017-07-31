-- 丰都流失宽带清单
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select a.*
--,b.offer_comp_id, prod_offer_id 
,c.offer_name
--, c_prod.offer_name prod_name
,0.0 score
from 
(
select  distinct a.*, b.offer_comp_id
--, b.prod_offer_id
--, b.prod_offer_inst_exp_date, b.prod_offer_inst_d_exp_date
,b.offer_comp_instance_id
--,b.prod_offer_inst_state_date
from      (
select acc_nbr, user_name, a.com_grid_id, jjx_code, user_grp_type
, down_velocity,  completed_date, remove_date, serv_id
, com.com_channel_name, com.com_grid_name
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  serv_num<>1
and product_id=102030001
and remove_date between '2012-01-01' and '2022-01-01'
-- or remove_date between '2012-01-01' and '2013-01-01'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state<>'00A'
and b.prod_offer_inst_state_date>='2012-01-01'  --是在2012年后修改为失效的
--and case when a.completed_date>'2012-01-01' then b.prod_offer_inst_state='00A' else b.prod_offer_inst_state<>'00A' end
 and b.offer_comp_id not in (-99, 0
 ,325038  --全家翼起来宽带提速1M， 提速的另外计算, 因一个宽带有可能又有提速又有2M的基础优惠商品
 )
    ) a
left join dim_crm_product_offer c on a.offer_comp_id=c.offer_id 
--left join dim_crm_product_offer c_prod on a.prod_offer_id=c_prod.offer_id 
order by a.acc_nbr

;
--因速率为2M以下，或套餐为426单宽带，不能参与积分的清单和统计
--可以在积分算完后提积分为0的观察状况。
--select * from tmp_PACKGE_NAME_AREA_FEEMONTH where down_velocity in ('1M','512K','640K', '1.5M') or offer_comp_id in (121244);

update tmp_PACKGE_NAME_AREA_FEEMONTH set score=688/12 where offer_name='（08版新e8）1MAD新装688元年套餐承诺12个月（包月不';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=588/12 where offer_name='（08版新e8）1M不限时AD新装588元年套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=58 where offer_name='（08版新e8）1M不限时AD新装58元月套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=58 where offer_name='（08版新e8）1M不限时老AD转58元月套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='（08版新e8）2MAD新装78元月套餐（区县)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=888/12 where offer_name='（08版新e8）2MAD新装888元年套餐（区县)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=688/12 where offer_name='e家1M688元年套餐（优化）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=50 where offer_name='None' or offer_name is null;
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=118 where offer_name='我的e家e8-4M118套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=119 where offer_name='新e9-4M不限时119套餐（全话费版）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=99 where offer_name='新e9套餐2M不限时99元套餐（区县）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=568/12 where offer_name='预付1000元用12个月（前台收费）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=99 where offer_name='全家乐（e9）套餐2M不限时99元套餐（区县）（老）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='视听宽带e8-1M（租机）78元/月';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=788/12 where offer_name in ('（08版新e8）1MAD新装788元年套餐承诺12个月（长期）','e8信息田园1M不限时老AD转788元年套餐');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=99 where offer_name='全家乐（e9）套餐2M不限时99元套餐（区县）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='（08版新e8）2M老AD转78元月套餐（区县)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=99 where offer_name='全家翼起来e9-ADSL2M不限时99套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=48 where offer_name='（08版新e8）1MAD新装48元月套餐承诺12个月（长期）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=688/12 where offer_name='（08版新e8）1M老AD转688元年套餐承诺12个月（包月不';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='（08版新e8）1M老AD转78元月套餐';

update tmp_PACKGE_NAME_AREA_FEEMONTH set score=-score ;
select '33';
--* from tmp_g2_33_201110;

