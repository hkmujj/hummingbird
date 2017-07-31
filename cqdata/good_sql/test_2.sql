--数据集市年度考题二
--提分公司4M宽带占比
--本脚本的执行时间在10秒左右
--1、总表
--分公司、自己分公司4M用户数、占自己分公司所有宽带用户的占比
--2、	清单表
--格式：分公司、4M宽带业务号码、办理的C类商品包（取套餐生效时间最晚的一个）
--数据门户的口径: 营销线, 到达标志.
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select 'AREA' area, b.*, a.*, b._4M*1.0/a.total rate from 
(
select count(*) total from ds_chn_prd_serv_mkt_AREA_{yyyymm} a
where a.PRODUCT_ID in (
--102010002 --ADSL专线
102030001 --ADSL注册虚拨上网
,102030002 --LAN注册虚拨上网
)
--product_id=102030001
--and state='00A' and serv_state='2HA' 
and serv_num=1



) a
left join 
(select 
--down_velocity, 
count(*) _4M from ds_chn_prd_serv_mkt_AREA_{yyyymm} a
where a.PRODUCT_ID in (
--02010002 --ADSL专线
102030001 --ADSL注册虚拨上网
,102030002 --LAN注册虚拨上网
)
--where product_id=102030001
--and state='00A' and serv_state='2HA' 
and serv_num=1
and down_velocity not in ('512K', '640K', '1M', '1.5M', '2M', '2.5M', '3M')
--group by 1
) b on 1=1
;

select '33';
--* from tmp_g2_33_201110;

