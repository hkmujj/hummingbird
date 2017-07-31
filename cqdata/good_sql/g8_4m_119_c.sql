--分公司4M全话费版119 cdma清单,限定一些套餐
--此处只提取重点关注的两个商品:承诺119和全话费E9(119,149)
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select 
distinct 
to_char(a.PROD_OFFER_INST_CREATED_DATE,'yyyy-mm-dd') 创建时间
--一个e9商品包里对每个基础商品都有一个商品记录,如果创建日期不同,则不能滤重.所以不能提取创建时间到日期,只到月份即可.
--关联了产品product_id后,此重复又不存在了.
,to_char(a.PROD_OFFER_INST_CREATED_DATE,'yyyy-mm') 创建月份
,a.prod_offer_id
,b.acc_nbr, a.serv_id,b.com_grid_id,b.user_name
,com.com_channel_name, com.com_grid_name
,a.offer_comp_id, pag.offer_name
--,b.product_id
 from ds_prd_offer_comp_detail a
left join ds_chn_prd_serv_AREA_LAST_DAY b on a.serv_id=b.serv_id 
left join DIM_ZONE_COMM com on b.com_grid_id=com.com_grid_id
left join dim_crm_product_offer pag on a.offer_comp_id=pag.offer_id
where a.offer_comp_id in (
	331507  --新e9-4M不限时119套餐（全话费版）
	--,330675 --承诺消费119元提速1M
	--,330398 --承诺消费119元提速2M
	--,330677 --承诺消费119元提速3M
	,331488 --新e9-4M不限时149套餐（全话费版）
	--,329628 --新e9-4M不限时119套餐
	--,331516 --描述与329628一样...
)
and a.prod_offer_inst_state='00A'
--and b.product_id =102030001 --仅提宽带清单
and b.product_id =208511296  --仅提宽带清单
and b.serv_id is not null
order by 1 desc;


select '33';
--* from tmp_g2_33_201110;

