-- 丰都新增宽带清单
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select a.*
--,b.offer_comp_id, prod_offer_id 
,c.offer_name, c_prod.offer_name prod_name
,0.0 score
from 
(
select a.*, b.offer_comp_id, b.prod_offer_id, offer_comp_instance_id
from      (
select acc_nbr, user_name, a.com_grid_id, jjx_code, user_grp_type
, down_velocity,  completed_date, remove_date, serv_id
, com.com_channel_name, com.com_grid_name
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  serv_num=1
and product_id=102030001
and completed_date between '2012-01-01' and '2012-03-10'
-- or remove_date between '2012-01-01' and '2013-01-01'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state='00A'
--and case when a.completed_date>'2012-01-01' then b.prod_offer_inst_state='00A' else b.prod_offer_inst_state<>'00A' end
 and b.offer_comp_id not in (-99, 0
-- ,325038  --全家翼起来宽带提速1M， 提速的另外计算, 因一个宽带有可能又有提速又有2M的基础优惠商品
 )
    ) a
left join dim_crm_product_offer c on a.offer_comp_id=c.offer_id 
left join dim_crm_product_offer c_prod on a.prod_offer_id=c_prod.offer_id 
order by a.acc_nbr

;
--因速率为2M以下，或套餐为426单宽带，不能参与积分的清单和统计
--可以在积分算完后提积分为0的观察状况。
--select * from tmp_PACKGE_NAME_AREA_FEEMONTH where down_velocity in ('1M','512K','640K', '1.5M') or offer_comp_id in (121244);

update tmp_PACKGE_NAME_AREA_FEEMONTH set score=888/12 where offer_name='（08版新e8）2MAD新装888元年套餐（区县)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=288/48 where offer_name='2M*学子在家B288元(绿网+时间控制)';
-- 学子在家总是会出4条记录,要删比较麻烦,干脆每条算1/4钱.
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='（08版新e8）2MAD新装78元月套餐（区县)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='无固话ADSL 2M不限时78套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='（08版新e8）2M老AD转78元月套餐（区县)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where offer_name='视听宽带e8-2M（租机）78元/月';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=88 where offer_name='视听宽带e8-2M（租机）88元/月';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=988/12 where offer_name='视听宽带e8-2M（租机）988元/年';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=88 where offer_name='2M视听宽带88元/月套餐承诺24个月（长期）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=88 where offer_name='2M视听宽带88元/月';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=89 where offer_name='全家翼起来e9-ADSL2M不限时89套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=99 where offer_name='全家翼起来e9-ADSL2M不限时99套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=99 where offer_name='全家乐（e9）套餐2M不限时99元套餐（区县）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=118 where offer_name='我的e家e8-4M118套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=119 where offer_name='新e9-4M不限时119套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=119 where offer_name in ( '承诺消费119元提速1M' ,'承诺消费119元提速2M' ,'承诺消费119元提速3M');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=119 where offer_name='新e9-4M不限时119套餐（全话费版）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=149 where offer_name='新e9-4M不限时149套餐（全话费版）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=688/12 where offer_name='e家1M688元年套餐（优化）' and down_velocity not in ('1M','1.5M');

--县委组织部 应为党政专线,每条65元
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=65 where offer_name='ADSL虚拨协议价单元[ADSL宽带上网]' and user_name='中国共产党丰都县委员会组织部';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=198 where offer_name='ADSL虚拨协议价单元[ADSL宽带上网]' and user_name='重庆市旺晟房地产开发有限公司';


--城西 部分宽带ADSL协议价,系统未能自动取得分值
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=78 where acc_nbr in (
--丰都县住房公积金单宽带5条。78/月，请加分，谢谢 
'023-02370702650',
'023-02370705531',
'023-02370702652',
'023-02370723886',
'023-02370722190',
--丰都国土执法大队单宽带1条，78/月，请加分，谢谢 
'023-02370702583',
--丰都县公房管理所单宽带6条，78/月，请加分 
'023-02370702702',
'023-02370702646',
'023-02370702658',
'023-02370702798',
'023-02370702332',
'023-02370710780'
)
; 
--将新装同时又办理了承诺119提速4M的serv_id提出来.
create temp table tmp_ls1 as select serv_id from tmp_PACKGE_NAME_AREA_FEEMONTH where offer_name in ('承诺消费119元提速1M' ,'承诺消费119元提速2M' ,'承诺消费119元提速3M');

create temp table tmp_ls2 as 
select a.*, b.serv_id tishu from tmp_PACKGE_NAME_AREA_FEEMONTH a 
left join tmp_ls1 b on a.serv_id=b.serv_id;
--处理新装基础套餐同时又办理承诺119的情况,此种应按119积分计算
update tmp_ls2 set score=0 where tishu is not null and offer_name not in ('承诺消费119元提速1M' ,'承诺消费119元提速2M' ,'承诺消费119元提速3M') ;

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select * from tmp_ls2;
select '33';
--* from tmp_g2_33_201110;
