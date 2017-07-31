--乡情网手机版手机清单
drop table if exists tmp_PACKGE_NAME_AREA_all;

create temp table tgm_26_{area} as 
select a.*, b.product_id, c.product_name, pag.offer_name, com.com_channel_name, com_grid_name
  from DS_CHN_PRD_OFFER_COMP_{yyyymm} a 
left join ds_chn_prd_serv_com_{area}_{yyyymm} b on a.serv_id=b.serv_id
left join dim_crm_product_offer pag on a.comp_offer_id=pag.offer_id
left join dim_product c on b.product_id=c.product_id
left join DIM_ZONE_COMM com on b.com_grid_id=com.com_grid_id
where 
a.com_area_id={area} and  a.comp_offer_id in (
276858, --	移动回家26元套餐享150分钟（手机固话版）
315968, --	[e6-11]26元享150分钟（新固话+新手机）[限153]
315997, --	[e6-11]26元享150分钟（新固话+老手机）[限133/153]
315998, --	[e6-11]26元享150分钟（老固话+新手机）[限153]
315999, --	[e6-11]26元享150分钟（老固话+老手机）[限133/153]
316003, --	[e6-11]26元享100分钟（老固话+新手机）[限153]
316004, --	[e6-11]26元享100分钟（老固话+老手机）[限133/153]
316005, --	[e6-11]36元享280分钟（新固话+新手机）[限153]
316007, --	[e6-11]36元享280分钟（老固话+新手机）[限153]
316008, --	[e6-11]36元享280分钟（老固话+老手机）[限133/153]
316065, --	[e6-11承诺12个月]26元享150分钟（老固话+新手机）[限
316067, --	[e6-11承诺12个月]26元享150分钟（老固话+老手机）[限
316868, --	移动回家26元套餐享150分钟（手机固话小灵通版）
318303, --	乡情网手机版－26套餐共享150分钟
318305, --	乡情网手机版－36套餐共享280分钟
318306, --	乡情网手机版－36套餐共享220分钟
321596, --	E6-11长话版26元套餐
321717, --	天翼回家E6-26元套餐（手机+固话）（老）
327818, --	天翼乡情网26套餐
327822, --	天翼乡情网18套餐
327844 --	天翼回家26套餐
);

create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select  a.acc_nbr "26套餐手机号码", b.acc_nbr "26套餐座机号码", a.comp_offer_id, a.offer_name, 
a.com_area_id 分公司, a.com_channel_name 营维部, a.com_grid_name 网格, a.offer_eff_date 生效时间,
to_char((a.offer_eff_date+interval '2 year -1 day'),'yyyy-mm-dd') 到期时间
  from tgm_26_{area} a 
left join tgm_26_{area} b on a.offer_comp_instance_id=b.offer_comp_instance_id and 
 b.product_name in ('普通电话','450M接入电话')
where a.product_name='语音CDMA' and a.offer_exp_date>'2020-01-01'
--进一步, 可以通过准确对比失效时间, 提取截止某一月的有效用户
limit 10000
;

select '33';


