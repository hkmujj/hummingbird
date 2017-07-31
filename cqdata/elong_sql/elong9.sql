-- 丰都宽带发生调速清单

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

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

from DS_CHN_PRD_SERV_AREA_LAST_DAY as s
inner join DS_CHN_PRD_OFFER_COMP_LAST_DAY  as a
on s.serv_id =a.serv_id
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


select '33';
--* from tmp_g2_33_201110;
