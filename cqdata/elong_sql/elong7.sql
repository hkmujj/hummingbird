-- 智能手机而未赠送100M流量的清单
-- 字段: 号码 竣工日期 营维部 网格 新装工单营业员 上月流量 上月套餐内流量

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
--create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
create temp table tgm_ls as 
select a.*
,inst.acc_nbr adsl_new
--,b.offer_comp_id, prod_offer_id 
,c.offer_name
--, c_prod.offer_name prod_name
--,0.0 score
,phone.enable_flag, phone.intell_flag
, user_postn_arrive_num
from 
(
select distinct a.*, b.offer_comp_id
, offer_comp_instance_id
--, b.prod_offer_id
from      (
select acc_nbr, user_name, a.com_grid_id, jjx_code, user_grp_type
, down_velocity,  completed_date, remove_date, serv_id 
, com.com_channel_name, com.com_grid_name, a.mkt_cust_code
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  serv_num=1
and product_id=208511296
and completed_date >='2012-01-01'
-- or remove_date between '2012-01-01' and '2013-01-01'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state='00A'
 and  b.offer_comp_id not in ( -99, 0 
, 317758  --【组】无线宽带EVDO（标识）
,327766 -- 2011年享WLAN上网10小时（CDMA）
,331444 -- 3G下乡购3G送200M
--,331494  --e家手机共享包（全话费版） 将优惠包提在后面,因有些手机可能只有纯加装包
,331598 --OCS承诺优惠购机25元包
,331594 --承诺优惠购机25元包
--,317056 --全业务长话包10元/月（立即生效） 应算10积分
,329522 --手机上网30M免费
--,327917 --手机上网包10元包60M  应算10积分
--,327914 --手机上网包5元包30M 应算5积分
--,331963 --天翼领航90元翼龙语音包
,331949 --天翼领航翼龙手机套餐39档次, 基础档次反面不能表明套餐包档次
,331558 --智能机流量包赠送
 )
    ) a
left join dim_crm_product_offer c on a.offer_comp_id=c.offer_id 
--left join dim_crm_product_offer c_prod on a.prod_offer_id=c_prod.offer_id 
--order by a.acc_nbr
--distribute by acc_nbr
--关联3G智能机表以取得3G和智能机标识
left join DS_PRD_SERV_3G_LAST_DAY phone on a.serv_id=phone.serv_id
left join DS_CHN_PRD_CUST_33_LAST_DAY mkt on a.mkt_cust_code=mkt.mkt_cust_code
left join tmp_fd2_AREA_FEEMONTH inst on a.offer_comp_instance_id=inst.offer_comp_instance_id  --关联新装宽带的套餐实例id
;
--因速率为2M以下，或套餐为426单宽带，不能参与积分的清单和统计
--可以在积分算完后提积分为0的观察状况。
--select * from tmp_PACKGE_NAME_AREA_FEEMONTH where down_velocity in ('1M','512K','640K', '1.5M') or offer_comp_id in (121244);


create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select *, 0 score from  tgm_ls ;
drop table tgm_ls;
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	6	 where offer_name in ('天翼大众6元套餐', '优惠购机6元承诺');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	6	 where offer_name='OCS天翼易通卡6元套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	6	 where offer_name='OCS天翼易通卡6元套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	10	 where offer_name='全家翼起来固C加装10元套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	16	 where offer_name='乡情网800M16套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	18	 where offer_name='天翼乡情网18套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	19	 where offer_name='OCS天翼畅聊19套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	19	 where offer_name='预付费T9套餐19元/月';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	19	 where offer_name='天翼畅聊19套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	19	 where offer_name='T9套餐19元/月';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	26	 where offer_name='E6-11长话版26元套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	26	 where offer_name='天翼乡情网26套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	35	 where offer_name='小灵通老用户35元套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	39	 where offer_name='天翼畅聊39套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	39	 where offer_name='OCS天翼畅聊39套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	39	 where offer_name='T9套餐39元/月';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	45	 where offer_name='天翼领航50元翼龙语音包';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	46	 where offer_name='我的e家e6-46套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	49	 where offer_name='201108上网版49元';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=49		 where offer_name='OCS201108上网版49元';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	59	 where offer_name='OCS201108聊天版59元';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	59	 where offer_name='201108聊天版59元';

update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	50	 where offer_name='无线宽带单产品套餐50元/月（OCS）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	50	 where offer_name='无线宽带单产品套餐50元/月';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	55	 where offer_name='小灵通老用户55元套餐(无补贴)';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	65	 where offer_name='天翼领航90元翼龙语音包';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	69	 where offer_name='201108上网版69元';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	89	 where offer_name='201108聊天版89元';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	89	 where offer_name='全家翼起来e9-ADSL2M不限时89套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	89	 where offer_name='OCS201108聊天版89元';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=95	 where offer_name='天翼领航150元翼龙语音包';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	96	 where offer_name='我的e家e6-96 套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	99	 where offer_name='全家翼起来e9-ADSL2M不限时99套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='T2无线宽带100套餐（预存6个月）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='无线宽带单产品套餐100元/月（OCS）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	100	 where offer_name='无线宽带单产品套餐100元/月（2GB）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	119	 where offer_name='新e9-4M不限时119套餐（全话费版）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=119		 where offer_name='新e9-4M不限时119套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score= 119		 where offer_name in ('承诺消费119元提速1M','承诺消费119元提速2M','承诺消费119元提速3M');
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	129	 where offer_name='201108聊天版129元';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=145	 where offer_name='天翼领航250元翼龙语音包';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	149	 where offer_name='新e9-4M不限时149套餐（全话费版）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	189	 where offer_name='201108聊天版189元';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=195	 where offer_name='天翼领航350元翼龙语音包';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	200	 where offer_name='无线宽带单产品套餐200元/月（OCS）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	200	 where offer_name='T2无线宽带200套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=245	 where offer_name='天翼领航450元翼龙语音包';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	300	 where offer_name='无线宽带单产品套餐300元/月（OCS）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	300	 where offer_name='T2无线宽带300套餐';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	300	 where offer_name='T2无线宽带300套餐';

-- 对新增手机,若其宽带也是新增,则宽带那边已经计算了119积分,手机不再计119积分.
--update tmp_PACKGE_NAME_AREA_FEEMONTH set score=-99 where offer_comp_instance_id in (select offer_comp_instance_id from tmp_fd2_AREA_FEEMONTH);
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=0 where adsl_new is not null;

--以及,对于E9套餐, 若其中的宽带也是新增的,则套餐积分不应再算
--取得套餐标识,取同套餐下的手机号码,再判断其是否在本年新增

--,phone.enable_flag, phone.intell_flag
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=score+20 where enable_flag=1 and (score<>0  or adsl_new is not null) and offer_name not like '%%无线宽带%%' and offer_name not like '%%T2%%';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=score+10 where intell_flag=1 and (score<>0 or adsl_new is not null) and offer_name not like '%%无线宽带%%' and offer_name not like '%%T2%%';

-- 可选包等应该移到核算智能机和3G手机奖励之后,以免一个手机重复算奖励.

update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	20	 where offer_name='手机上网包20元包150M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=5		 where offer_name='全业务可选短信包5元包100条';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=10		 where offer_name='全业务长话包10元/月（立即生效）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	10	 where offer_name='手机上网包10元包60M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	5	 where offer_name='手机上网包5元包30M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	5	 where offer_name='全业务5元短信可选包（立即生效）';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	5	 where offer_name='全业务可选短信包5元';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	30	 where offer_name='手机上网包30元包300M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	5	 where offer_name='OCS手机上网包5元包30M';
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=	10	 where offer_name='天翼办公（移动版）套餐包';

--还需要考虑: 固C融合加分
--李瑛: 建议为凡与固话合户的,都奖励此20分
update tmp_PACKGE_NAME_AREA_FEEMONTH set score=score+20 where user_postn_arrive_num>0;
select '33';
--* from tmp_g2_33_201110;
