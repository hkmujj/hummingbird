--分公司4M ADSL清单,限定一些套餐
--虽然按商品包进行了滤重,但极少部分号码还是有两条记录,因为内部数据错误
--此处提到的数量略大于实际ADSL4M数量,因为以上重复原因.
--目前有12个重复的号码,需要各营维部仔细清理CRM, 有可能当时进行了比较奇异的受理
--023-02370650789
--023-02370709890
--023-02370711111
--023-02370726330
--023-15320801127
--023-18908251333
--023-18983336356
--023-18996753748
--023-adsl301024828
--023-adsl302941052
--023-adsl303018435

drop table if exists adsl_4m;
create temp table adsl_4m as 
select serv_id, acc_nbr,mkt_cust_code, completed_date, down_velocity
,a.com_grid_id
from ds_chn_prd_serv_com_{area}_{yyyymm} a 
where 
a.SERV_NUM = 1
and a.DOWN_VELOCITY not in ('512K','640K','1M','1.5M','2M', '2.5M','3M')
and a.product_id='102030001' --限定产品类型
order by acc_nbr
;

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
--select count(*) from adsl_4m; --610
select a.acc_nbr, a.mkt_cust_code, a.completed_date, a.down_velocity
,a.com_grid_id
,b.*
,c.pagname_rate 提速优惠
from adsl_4m a
left join (
select 
distinct 
a.serv_id,c6.offer_comp_type_desc4 四级套餐
,b.OFFER_COMP_INSTANCE_ID 套餐包实例标识
--,b.PROD_OFFER_CLASS_ID 商品类别标识
--0 基础商品;1 产品级优惠商品;2 捆绑级优惠商品;3 帐户级优惠商品;
--4 客户级优惠商品;5 业务群级优惠商品;6 业务群成员优惠商品;7 用户群级优惠商品;
--8 用户群成员优惠商品;9 ISMP优惠商品
--,d.IF_HAVE_COST 成本投入
--,d.PROMISE_MONTH 承诺期
--,d.BACK_BONUS 积分
,d.offer_name pagname
--,c.offer_name pname
--,a.completed_date
--,a.product_id
--,b.prod_offer_id
,b.offer_comp_id
--,a.mkt_cust_code
--,b.PROD_OFFER_INST_STATE, b.PROD_OFFER_INST_DETAIL_STATE
--,to_char(b.PROD_OFFER_INST_eff_DATE,'yyyy-mm-dd')
--,to_char(b.PROD_OFFER_INST_EXP_DATE,'yyyy-mm-dd')
,to_char(b.PROD_OFFER_INST_CREATED_DATE,'yyyy-mm-dd') 创建时间
--,b.PROD_OFFER_INST_STATE
--,b.PROD_OFFER_INST_STATE_DATE
--,b.PROD_OFFER_INST_D_EFF_DATE
--,b.PROD_OFFER_INST_D_EXP_DATE
--,b.PROD_OFFER_INST_DETAIL_STATE

--,a.com_grid_id com_grid_id
from 
adsl_4m a
left join DS_PRD_OFFER_COMP_DETAIL b on a.serv_id=b.serv_id and b.prod_offer_id<>'-99' 
and b.offer_comp_id not in ('0','-99') and b.PROD_OFFER_INST_DETAIL_STATE='00A'
and prod_offer_inst_d_exp_date<>'2030-01-01 00:00:00'

--left join DIM_CRM_PRODUCT_OFFER c on b.prod_offer_id=c.offer_id and c.offer_name not like '%%过渡%%'-- and c.base_flag=1
left join dim_crm_product_offer d on b.offer_comp_id=d.offer_id -- and d.base_flag=1
and d.offer_name not like 'iTV%%' and d.offer_name not like '%%提速%%'
left join DIM_WD_OFFER_NEW_DIR_SECOND c6 on b.offer_comp_id=c6.offer_comp_type_id6 
where c6.offer_comp_type_desc4 not in 
('ITV优惠套餐','iTV','','固话套餐','家庭组合套餐')
and d.offer_name is not null
--order by a.acc_nbr
) b
on a.serv_id=b.serv_id
left join (
select 
--distinct 
a.serv_id
--,c6.offer_comp_type_desc4 四级套餐
--,b.OFFER_COMP_INSTANCE_ID 套餐包实例标识
--,b.PROD_OFFER_CLASS_ID 商品类别标识
--0 基础商品;1 产品级优惠商品;2 捆绑级优惠商品;3 帐户级优惠商品;
--4 客户级优惠商品;5 业务群级优惠商品;6 业务群成员优惠商品;7 用户群级优惠商品;
--8 用户群成员优惠商品;9 ISMP优惠商品
--,d.IF_HAVE_COST 成本投入
--,d.PROMISE_MONTH 承诺期
--,d.BACK_BONUS 积分
,pg_concat(d.offer_name||',') pagname_rate
--,c.offer_name pname
--,a.completed_date
--,a.product_id
--,b.prod_offer_id
--,b.offer_comp_id,a.mkt_cust_code
--,b.PROD_OFFER_INST_STATE, b.PROD_OFFER_INST_DETAIL_STATE
--,to_char(b.PROD_OFFER_INST_eff_DATE,'yyyy-mm-dd')
--,to_char(b.PROD_OFFER_INST_EXP_DATE,'yyyy-mm-dd')
--,to_char(b.PROD_OFFER_INST_CREATED_DATE,'yyyy-mm-dd') 创建时间
--,b.PROD_OFFER_INST_STATE
--,b.PROD_OFFER_INST_STATE_DATE
--,b.PROD_OFFER_INST_D_EFF_DATE
--,b.PROD_OFFER_INST_D_EXP_DATE
--,b.PROD_OFFER_INST_DETAIL_STATE

--,a.com_grid_id com_grid_id
from 
adsl_4m a
left join DS_PRD_OFFER_COMP_DETAIL b on a.serv_id=b.serv_id and b.prod_offer_id<>'-99' 
and b.offer_comp_id not in ('0','-99') and b.PROD_OFFER_INST_DETAIL_STATE='00A'


--left join DIM_CRM_PRODUCT_OFFER c on b.prod_offer_id=c.offer_id and c.offer_name not like '%%过渡%%'-- and c.base_flag=1
left join dim_crm_product_offer d on b.offer_comp_id=d.offer_id -- and d.base_flag=1
--and d.offer_name not like 'iTV%%' and d.offer_name not like '%%提速%%'
left join DIM_WD_OFFER_NEW_DIR_SECOND c6 on b.offer_comp_id=c6.offer_comp_type_id6 
where c6.offer_comp_type_desc4 ='家庭组合套餐' or d.offer_name like '%%提速%%'
group by 1
--order by a.acc_nbr
) c on a.serv_id=c.serv_id
order by a.acc_nbr;

select '33';
--* from tmp_g2_33_201110;

