--数据集市年度考题二
--提分公司各营维部4M宽带占比
--本脚本的执行时间在10秒左右
--1、总表
--分公司、自己分公司4M用户数、占自己分公司所有宽带用户的占比
--2、	清单表
--格式：分公司、4M宽带业务号码、办理的C类商品包（取套餐生效时间最晚的一个）
--本处取的维护线
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
drop table if exists tab_4m_all;
select a.serv_id, a.acc_nbr,a.prod_addr, a.user_name, b.mkt_channel_name, b.mkt_grid_name, down_velocity, a.jjx_code 交接箱编码
,a.product_id, pro.product_name

  into temp tab_4m_all
  from DS_CHN_PRD_SERV_mkt_AREA_{yyyymm} a
  left join DIM_ZONE_area b
    on (a.mkt_GRID_ID = b.mkt_GRID_ID)
left join dim_product pro on a.product_id=pro.product_id

where a.PRODUCT_ID in (
--102010002 --ADSL专线
102030001 --ADSL注册虚拨上网
,102030002 --LAN注册虚拨上网
)   and a.SERV_NUM = 1
   and a.DOWN_VELOCITY not in ('512K','640K','1M','1.5M','2M', '2.5M','3M');
--select count(*) from tab_4m_all;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select a.*, b.offer_name comp_name,c.offer_name from tab_4m_all a left join 
(select serv_id, pg_concat(t3.offer_name||'\n') offer_name from ds_prd_offer_comp_detail a
left join dim_crm_product_offer t3 on a.offer_comp_id=t3.offer_id
-- and t3.offer_kind='C'
where serv_id in (select serv_id from tab_4m_all) 
--and t3.state='00A'
and t3.offer_kind not in ('0') group by 1)
b on a.serv_id=b.serv_id and b.offer_name not in (
	'全家翼起来宽带提速1M'
,'全翼起来宽带提速2M'
,'iTV标清基础包298元包年（E家）'
,'iTV标清基础包28元包月（非E家-新用户）'
,'商家联盟宽带20元提速'
,'iTV标清包员工版包年'
,'iTV标清基础包28元包月（E家-新用户）'
,'iTV标清基础包298元包年（非E家）'
,'【后】新装T3畅聊129套餐（新CDMA下月生效）'
,'T3畅聊89套餐'
,'iTV标清28元包月（租赁）（体验）'
,'e6移动回家46套餐（老固话＋新手机）'
,'iTV标清首年300元次年298元包年B版（体验）'
,'非E家用户itv增强包年套餐'
,'iTV标清基础包28元包月（E家）'
,'iTV标清298元包年（租赁）（体验）'
,'iTV标清基础包28元包月（E家）'
,'承诺消费119元提速1M'
,'承诺消费119元提速2M'
,'承诺消费119元提速3M'
,'09PC＋宽带月供180元（24个月）'
,'iTV标清298元包年（租赁）'
,'iTV标清20元包月（员工版）'
,'【AC-76】无线宽带76元包月套餐(立即生效)(仅133/153)'
,'我的E家用户itv增强包年套餐'
,'天翼领航翼龙套餐宽带提速包'
,'非E家用户itv增强包月套餐(新装机用户)'
,'ADSL虚拨协议价单元[ADSL宽带上网]'
,'iTV标清28元包月（租赁）'
,'我的E家用户itv增强包月套餐(新装机用户)'
,'iTV标清基础包28元包月（非E家-老用户）'
,'新装宽带承诺12月送1月'
,'我的E家用户itv增强包月套餐(新装机用户)'
,'iTV标清首年300元次年298元包年B版'
,'[AC-76]无线宽带76元包月套餐(新用户下月生效)(仅'
,'[AC-76]无线宽带76元包月套餐(新用户下月生效)(仅133/'
,'卖场ITV298元包年套餐'
,'[122]丰都保底优惠含长话'
)
left join (select serv_id, pg_concat(t3.offer_name||'\n') offer_name from ds_prd_offer_comp_detail a
left join dim_crm_product_offer t3 on a.prod_offer_id=t3.offer_id
-- and t3.offer_kind='C'
where serv_id in (select serv_id from tab_4m_all) 
--and t3.state='00A'
and t3.offer_kind not in ('0') group by 1)
c on a.serv_id=c.serv_id

;

select '33';
--* from tmp_g2_33_201110;

