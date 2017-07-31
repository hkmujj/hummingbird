--拆机用户收入流失表:
--取本月拆机竣工用户,其上个月收入
--部门 X月拆机收入  占收入比  拉动收入增长 其中C网增量 宽带增量 iTV增量
--XX营维部
--XX营维部
--其他
--合计
--
--确认1:是指当年拆机,还是当月拆机?

--第1步: 取得当月拆机设备, 关联好营维部, 产品名称, 给每个设备打上是否当月拆机的标志,根据竣工时间
--第2步: 取得每设备的当月优惠后费用合计
--统计得出每个营维部的当月拆机收入,当月总收入, 当月每样产品的拆机收入

drop table if exists tmp_tgm_t1;
create temp table tmp_tgm_t1 as 
select serv_id, mkt_cust_id, mkt_channel_id, mkt_grid_id, com_channel_id, com_grid_id
--,acct_item_type_id5
, sum(charge) charge
--, income_flag
--select * 
 from DS_CHN_ACT_SERV_INCOME_LAST_MONTH where mkt_area_id={area}
 and income_flag=1
 group by 1,2,3,4,5,6 
 --limit 10
 ;

select  count(*), sum(charge) from tmp_tgm_t1;

drop table if exists tmp_tgm_t2;
create temp table tmp_tgm_t2 as 
select a.*, case when b.remove_date like '{yyyy-mm}%%' then 1 else 0 end new_flag
--, b.product_id 
, product_name
,mkt.mkt_channel_name
from tmp_tgm_t1 a left join ds_chn_prd_serv_{area}_{yyyymm} b on a.serv_id=b.serv_id
left join dim_crm_product product on b.product_id=product.product_id 
left join DIM_ZONE_area mkt on a.mkt_grid_id=mkt.mkt_grid_id
--limit 10
;

drop table if exists tmp_t3;
create temp table tmp_t3
(item varchar(40), channel varchar(40), charge decimal(16,2)); 

insert into tmp_t3
select '总费用',mkt_channel_name, sum(charge) from tmp_tgm_t2 
group by 1,2  
union
select '拆机费用',mkt_channel_name, sum(charge) from tmp_tgm_t2 
where new_flag=1 group by 1,2  
union
select '拆机iTV',mkt_channel_name, sum(charge) from tmp_tgm_t2 
where new_flag=1  and product_name='iTV' group by 1,2 
union
select '拆机手机',mkt_channel_name, sum(charge) from tmp_tgm_t2 
where new_flag=1  and product_name='手机' group by 1,2 
union
select '拆机宽带',mkt_channel_name, sum(charge) from tmp_tgm_t2 
where new_flag=1  and product_name='ADSL宽带上网' group by 1,2   
union
select '拆机固话',mkt_channel_name, sum(charge) from tmp_tgm_t2 
where new_flag=1  and product_name='固定电话' group by 1,2   
;
drop table tmp_tgm_t1;
drop table tmp_tgm_t2;
--select   人员   as   [人员\品种],sum(case   when   品种= 'a '   then   数量   else   0   end)   as   a,sum(case   when   品种= 'b '   then   数量   else   0   end)as   b   from   @a   group   by   人员 
drop table if exists tmp_PACKGE_NAME_{area}_{yyyymm};
create table tmp_PACKGE_NAME_{area}_{yyyymm} as 
select channel, sum(case when item='拆机费用' then charge else 0 end) 拆机费用
, sum(case when item='总费用' then charge else 0 end) 总费用
, 0.0 占收入比
, 0.0 拉动收入增长
, sum(case when item='拆机iTV' then charge else 0 end) 拆机iTV
, sum(case when item='拆机手机' then charge else 0 end) 拆机手机
, sum(case when item='拆机宽带' then charge else 0 end) 拆机宽带
, sum(case when item='拆机固话' then charge else 0 end) 拆机固话
from tmp_t3
group by 1;

select '33';
--* from tmp_g2_33_201110;
