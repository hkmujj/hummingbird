--丰都76套餐清单
--76套餐为自主组合: 固话宽带58套餐, 翼龙30套餐,实交18,共交76, 并因翼龙提速2M,合户

--1.提58套餐清单, 7月1日以后竣工的
--2.提其同合同号下的手机,看是否有翼龙30套餐
--3.或提该宽带上的提速优惠, 该优惠应同时绑定一个手机号码,验证该手机是合户,并是翼龙.

--提取E8-58清单(固话,宽带,合同号)
--提取龙卡30及以上清单(手机,档次,合同号)
--关联相同合同号.
drop table if exists tgm_t1;
create temp table tgm_t1 as 
select a.acc_nbr,a.serv_id, a.product_id, a.mkt_cust_code, a.completed_date,b.offer_comp_id, b.offer_comp_instance_id,
b.prod_offer_inst_id, b.prod_offer_id, prod_offer_inst_created_date
, a.down_velocity, a.com_grid_id
 from ds_chn_prd_serv_mkt_AREA_LAST_DAY a 
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='00A'

where 
a.product_id in ('102030001','208511296')
--and a.acc_nbr='023-02370722812'
--and b.offer_comp_id in ('334603' --334603	334604	e8-2M-58不限时套餐（12版）_基础包
--,'333006' --333006	333007	宽带加C提速2M（承诺30元）_基础包
--319557	332229	天翼龙卡话费包24元包30元
--319557	334891	乡情龙卡话费包24元包30元
and b.prod_offer_id in ('334604', '333007', '332229', '334891'
)
--distributed by a.acc_nbr
;

--select * from tgm_t1 order by offer_comp_instance_id;
--58清单
--光58, 无龙卡30档次合户提速的
--有58, 仅提速, 但手机并不是龙卡30元的
--有58, 无提速, 但有龙卡30元手机合户的
--有58, 无提速, 有手机合户,但不是龙卡30元的

--select 
--count(distinct acc_nbr)
--from tgm_t1 where 
--product_id='102030001'
-- and 
--offer_comp_id='334603'
--;

--437
--410  共有410个宽带号码

-- 无宽带加C提速方案的58套餐
--select a.acc_nbr,b.acc_nbr from tgm_t1 a 
--left join tgm_t1 b on a.serv_id=b.serv_id and b.offer_comp_id='333006'
--left join tgm_t1 b on a.offer_comp_instance_id=b.offer_comp_instance_id and b.product_id='102030001' and b.
--where a.product_id='102030001' and a.offer_comp_id='334603' and b.acc_nbr is null
--order by a.acc_nbr;

-- 有提速, 但C网号码不是龙卡30的
create temp table tgm_t2 as 
select a.acc_nbr "E8-58宽带号码", a.completed_date 宽带竣工时间, a.prod_offer_inst_created_date E8竣工时间, 
case when b.acc_nbr is null then '' else '有' end  宽带加C提速, b.prod_offer_inst_created_date 加C提速竣工时间, 
c.acc_nbr 提速绑定手机号码, c.completed_date 手机竣工时间, 
case when d.acc_nbr is null then '' else '符合' end 手机套餐符合龙卡30, d.prod_offer_inst_created_date 龙卡竣工时间
 from tgm_t1 a 
left join tgm_t1 b on a.serv_id=b.serv_id and b.offer_comp_id='333006'
left join tgm_t1 c on b.offer_comp_instance_id=c.offer_comp_instance_id and c.product_id='208511296' --and c.offer_comp_id='332229'
left join tgm_t1 d on c.serv_id=d.serv_id and d.offer_comp_id='319557'
where a.product_id='102030001' and a.offer_comp_id='334603' 
order by a.acc_nbr;
----------------------------
---------------------------


drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select * from tgm_t2;
/*
select
	e.MKT_CHANNEL_name 营销线营维部,
	e.MKT_REGION_NAME 营销线区域网格,
	e.MKT_GRID_NAME  营销线网格,
	k.COM_CHANNEL_NAME 维护线营维部,
	k.COM_GRID_NAME 维护线网格,
	s.serv_id,
	s.acc_nbr 用户号码,
	s.user_name 用户名,
	s.mkt_cust_code 合同号,
	s.prod_addr 用户地址,
	s.DOWN_VELOCITY 下行带宽,
	d.PRODUCT_NAME 产品四级名称,
	to_char(a.OFFER_COMPLETED_DATE,'YYYY-MM-DD') 套餐竣工时间,
	to_char(a.offer_eff_date,'YYYY-MM-DD') 套餐生效时间,
	a.comp_offer_id 商品包id,
	b.offer_comp_type_desc6 提速优惠名称,
	'' 提速类型,
	c.staff_code 受理工号,
	c.staff_desc 受理人

from tgm_t2 a 
left join DIM_WD_OFFER_NEW_DIR_SECOND as b
on a.COMP_OFFER_ID = b.offer_comp_type_id6
left join DIM_CRM_STAFF as c
on a.OPER_ID=c.party_role_id		--关联操作员工
left join DIM_PRODUCT as d
on s.PRODUCT_ID = d.PRODUCT_ID		--关联产品四级名称
left join DIM_ZONE_area as e
on s.MKT_GRID_ID  = e.MKT_GRID_ID 	--关联营销线
left join DIM_ZONE_COMM as k
on s.COM_GRID_ID  = k.COM_GRID_ID 	--关联维护线

where b.OFFER_COMP_TYPE_ID6 in(

'330424',--翼起来第二部手机提速1M
'330516',--翼起来第三部手机提速1M
'330518',--翼起来第四部手机提速1M
'330525',--翼起来第五部手机提速1M
'330529',--翼起来加装第二部智能手机提速2M
'330531',--翼起来加装第三部智能手机提速2M

'330675',--承诺消费119元提速1M
'330398',--承诺消费119元提速2M
'330677',--承诺消费119元提速3M
'332319',--承诺消费119元提速到4M
'330669',--承诺消费149元提速1M
'330395',--承诺消费149元提速2M
'330671',--承诺消费149元提速3M
'332317',--承诺消费149元提速到4M

'334275',--购智能机宽带提速2M(1年)
'334719',--购智能机宽带提速2M(1年)(第二部手机)
'334325',--OCS购智能机宽带提速2M(1年)
'334721',--OCS购智能机宽带提速2M(1年) (第二部手机)

'331867',--宽带存量用户承诺提速包

'333001',--宽带加C提速1M（承诺20元）龙卡提速
'333006',--宽带加C提速2M（承诺30元）龙卡提速
'333008',--宽带加C提速3M（承诺50元）龙卡提速
'334282',--OCS宽带加C提速1M（承诺20元）龙卡提速
'334291',--OCS宽带加C提速2M（承诺30元）龙卡提速
'334293',--OCS宽带加C提速3M（承诺50元）龙卡提速

'333212',--宽带提速512K功能费1元合约提速
'332995',--宽带提速1M功能费5元合约提速
'333353',--宽带提速1M功能费10元合约提速
'332992',--宽带提速2M功能费5元合约提速
'333351',--宽带提速2M功能费10元合约提速
'333357',--宽带提速2M功能费20元合约提速
'333120',--宽带提速3M功能费10元合约提速
'333344',--宽带提速3M功能费20元合约提速

'331069',--加装iTV宽带提速1M
'333040',--加装iTV提速2M优惠应用提速
'333817',--加装iTV宽带提速4M应用提速

'330766',--预存96元提速1M(巫山)预存提速
'330769',--预存192元提速2M(巫山)预存提速
'332900',--宽带存费提速包（96-1M）预存提速
'332903',--宽带存费提速包（192-2M）预存提速
'333373',--预存500元宽带提速1M预存提速
'333368',--预存500元宽带提速1M(OCS)预存提速
'333375',--预存1000元宽带提速2M预存提速
'333371',--预存1000元宽带提速2M(OCS)预存提速

'334208', --	平移FTTH套餐速率翻番（1.5M）
'334121', --	平移FTTH套餐速率翻番（1M）
'334126', --	平移FTTH套餐速率翻番（4M）
'334212', --	平移FTTH套餐速率翻番（3M）
'334123', --	平移FTTH套餐速率翻番（2M）
'334118', --	平移FTTH套餐速率翻番（512K）
'334210', --	平移FTTH套餐速率翻番（2.5M）

'332046',--天翼领航翼龙套餐宽带提速包翼龙提速
'334695'--翼龙套餐宽带提速3M翼龙提速
)
and d.PRODUCT_NAME in ( 'ADSL注册虚拨上网')
order by 套餐竣工时间 desc
;
update tmp_PACKGE_NAME_AREA_FEEMONTH set 提速类型='翼起来提速' where 商品包id in (
'330424',--翼起来第二部手机提速1M
'330516',--翼起来第三部手机提速1M
'330518',--翼起来第四部手机提速1M
'330525',--翼起来第五部手机提速1M
'330529',--翼起来加装第二部智能手机提速2M
'330531');--翼起来加装第三部智能手机提速2M

update tmp_PACKGE_NAME_AREA_FEEMONTH set 提速类型='承诺119提速' where 商品包id in (
'330675',--承诺消费119元提速1M
'330398',--承诺消费119元提速2M
'330677',--承诺消费119元提速3M
'332319',--承诺消费119元提速到4M
'330669',--承诺消费149元提速1M
'330395',--承诺消费149元提速2M
'330671',--承诺消费149元提速3M
'332317');--承诺消费149元提速到4M

update tmp_PACKGE_NAME_AREA_FEEMONTH set 提速类型='购智能机提速' where 商品包id in (
'334275',--购智能机宽带提速2M(1年)
'334719',--购智能机宽带提速2M(1年)(第二部手机)
'334325',--OCS购智能机宽带提速2M(1年)
'334721');--OCS购智能机宽带提速2M(1年) (第二部手机)

update tmp_PACKGE_NAME_AREA_FEEMONTH set 提速类型='存量用户提速' where 商品包id in (
'331867');--宽带存量用户承诺提速包

update tmp_PACKGE_NAME_AREA_FEEMONTH set 提速类型='宽带加C提速' where 商品包id in (
'333001',--宽带加C提速1M（承诺20元）龙卡提速
'333006',--宽带加C提速2M（承诺30元）龙卡提速
'333008',--宽带加C提速3M（承诺50元）龙卡提速
'334282',--OCS宽带加C提速1M（承诺20元）龙卡提速
'334291',--OCS宽带加C提速2M（承诺30元）龙卡提速
'334293');--OCS宽带加C提速3M（承诺50元）龙卡提速

update tmp_PACKGE_NAME_AREA_FEEMONTH set 提速类型='合约提速' where 商品包id in (
'333212',--宽带提速512K功能费1元合约提速
'332995',--宽带提速1M功能费5元合约提速
'333353',--宽带提速1M功能费10元合约提速
'332992',--宽带提速2M功能费5元合约提速
'333351',--宽带提速2M功能费10元合约提速
'333357',--宽带提速2M功能费20元合约提速
'333120',--宽带提速3M功能费10元合约提速
'333344');--宽带提速3M功能费20元合约提速

update tmp_PACKGE_NAME_AREA_FEEMONTH set 提速类型='加装iTV提速' where 商品包id in (
'331069',--加装iTV宽带提速1M
'333040',--加装iTV提速2M优惠应用提速
'333817');--加装iTV宽带提速4M应用提速

update tmp_PACKGE_NAME_AREA_FEEMONTH set 提速类型='预存提速' where 商品包id in (
'330766',--预存96元提速1M(巫山)预存提速
'330769',--预存192元提速2M(巫山)预存提速
'332900',--宽带存费提速包（96-1M）预存提速
'332903',--宽带存费提速包（192-2M）预存提速
'333373',--预存500元宽带提速1M预存提速
'333368',--预存500元宽带提速1M(OCS)预存提速
'333375',--预存1000元宽带提速2M预存提速
'333371');--预存1000元宽带提速2M(OCS)预存提速

update tmp_PACKGE_NAME_AREA_FEEMONTH set 提速类型='翼龙提速' where 商品包id in (
'332046',--天翼领航翼龙套餐宽带提速包翼龙提速
'334695');--翼龙套餐宽带提速3M翼龙提速

update tmp_PACKGE_NAME_AREA_FEEMONTH set 提速类型='FTTH迁转提速' where 商品包id in (
'334208', --	平移FTTH套餐速率翻番（1.5M）
'334121', --	平移FTTH套餐速率翻番（1M）
'334126', --	平移FTTH套餐速率翻番（4M）
'334212', --	平移FTTH套餐速率翻番（3M）
'334123', --	平移FTTH套餐速率翻番（2M）
'334118', --	平移FTTH套餐速率翻番（512K）
'334210'); --	平移FTTH套餐速率翻番（2.5M）

*/
select '33';
--* from tmp_g2_33_201110;
