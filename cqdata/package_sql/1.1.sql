
/*
一、全部替换DS_CHN_PRD_SERV_44_201108为DS_CHN_PRD_SERV_44_201109
二、全部替换DS_CHN_PRD_OFFER_COMP_201108为DS_CHN_PRD_OFFER_COMP_201109
三、从提示执行开始拉黑至提示执行结束，点击执行查询，结果粘贴到EXCEL操作表，生成图表。
*/
-- 本页的执行时间约在50秒左右
--执行开始
--PPT1.1
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH_l;
create temporary table tmp_PACKGE_NAME_AREA_FEEMONTH_l as
select distinct a.acc_nbr,b.type_name,substring(e.OFFER_COMP_TYPE_DESC1 from 1 for 5) offerd
from 
DS_CHN_PRD_SERV_AREA_FEEMONTH a,--此处改用户表的分公司和帐期
DIM_PRODUCT b,DS_CHN_PRD_OFFER_COMP_FEEMONTH c,--此处改套餐分析表的帐期
DIM_CRM_PRODUCT_OFFER d,DIM_WD_OFFER_NEW_DIR_SECOND e 
where 
a.product_id=b.product_id 
and 
b.type_name in ('注册拨号类','普通电话','移动业务','视讯应用产品') 
and 
a.state='00A' 
and
a.SERV_NUM='1'
and 
a.serv_id=c.serv_id
and 
c.COMP_OFFER_ID=d.offer_id
and 
d.offer_name=OFFER_COMP_TYPE_DESC6
and 
c.OFFER_EXP_DATE>=(Values ((SELECT date_trunc('month', timestamp 'FEEMONTH01'))));
insert into tmp_PACKGE_NAME_AREA_FEEMONTH_l 
select distinct a.acc_nbr,a.type_name,'未知' offerd from 
(
select distinct a.acc_nbr,a.type_name from 
(
select distinct a.acc_nbr,a.type_name,b.acc_nbr acc_nbr1 from 
(
select distinct a.acc_nbr,b.type_name
from 
DS_CHN_PRD_SERV_AREA_FEEMONTH a,--此处改用户表帐期
DIM_PRODUCT b
where
a.product_id=b.product_id 
and 
b.type_name in ('注册拨号类','普通电话','移动业务','视讯应用产品') 
and 
a.state='00A'
and
a.SERV_NUM='1'
) a left join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.acc_nbr=b.acc_nbr
) a where acc_nbr1 is null
) a;
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH_2;--这里用了一个优先级来确认套餐类型归属，有E家套餐就先算E家套餐，没得就看有无政企非品牌，有的话就算商务政企，以此类推.目前这个分级较粗糙，没对4级以下套餐分级。后续版本会按4级套餐分级。
create temporary table tmp_PACKGE_NAME_AREA_FEEMONTH_2 as
select distinct acc_nbr,type_name,'我的e家' offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_l where offerd='我的e家品';
insert into tmp_PACKGE_NAME_AREA_FEEMONTH_2
select distinct acc_nbr,type_name,'商务政企' offerd from
(
select acc_nbr,type_name,offerd from 
(select distinct a.acc_nbr nbr,b.acc_nbr,b.type_name,b.offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_2 a right join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.acc_nbr=b.acc_nbr)
a where nbr is null) a where offerd='政企非品牌';
insert into tmp_PACKGE_NAME_AREA_FEEMONTH_2
select distinct acc_nbr,type_name,'商务政企' offerd from
(
select acc_nbr,type_name,offerd from 
(select distinct a.acc_nbr nbr,b.acc_nbr,b.type_name,b.offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_2 a right join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.acc_nbr=b.acc_nbr)
a where nbr is null) a where offerd='商务领航品';
insert into tmp_PACKGE_NAME_AREA_FEEMONTH_2
select distinct acc_nbr,type_name,'天翼品牌' offerd from
(
select acc_nbr,type_name,offerd from 
(select distinct a.acc_nbr nbr,b.acc_nbr,b.type_name,b.offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_2 a right join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.acc_nbr=b.acc_nbr)
a where nbr is null) a where offerd='天翼品牌套';
insert into tmp_PACKGE_NAME_AREA_FEEMONTH_2
select distinct acc_nbr,type_name,'家庭个人' offerd from
(
select acc_nbr,type_name,offerd from 
(select distinct a.acc_nbr nbr,b.acc_nbr,b.type_name,b.offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_2 a right join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.acc_nbr=b.acc_nbr)
a where nbr is null) a where offerd='家庭非品牌';
insert into tmp_PACKGE_NAME_AREA_FEEMONTH_2
select distinct acc_nbr,type_name,'家庭个人' offerd from
(
select acc_nbr,type_name,offerd from 
(select distinct a.acc_nbr nbr,b.acc_nbr,b.type_name,b.offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_2 a right join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.acc_nbr=b.acc_nbr)
a where nbr is null) a where offerd='个人非品牌';
insert into tmp_PACKGE_NAME_AREA_FEEMONTH_2
select distinct acc_nbr,type_name,'其他' offerd from
(
select acc_nbr,type_name,offerd from 
(select distinct a.acc_nbr nbr,b.acc_nbr,b.type_name,b.offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_2 a right join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.acc_nbr=b.acc_nbr)
a where nbr is null) a where offerd='未知';

--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as
select distinct a.offerd,a.注册拨号类,a.普通电话,a.移动业务,d.acc_nbr 视讯应用产品 from
(
select distinct c.offerd,a.注册拨号类,a.普通电话,c.acc_nbr 移动业务 from
(
select distinct b.offerd,a.acc_nbr 注册拨号类,b.acc_nbr 普通电话 from
(select distinct offerd,count(distinct acc_nbr) acc_nbr from tmp_PACKGE_NAME_AREA_FEEMONTH_2 where type_name='注册拨号类' group by 1) a
full join 
(select distinct offerd,count(distinct acc_nbr) acc_nbr from tmp_PACKGE_NAME_AREA_FEEMONTH_2 where type_name='普通电话' group by 1) b
on a.offerd=b.offerd
) a full join 
(select distinct offerd,count(distinct acc_nbr) acc_nbr from tmp_PACKGE_NAME_AREA_FEEMONTH_2 where type_name='移动业务' group by 1) c
on a.offerd=c.offerd
) a full join 
(select distinct offerd,count(distinct acc_nbr) acc_nbr from tmp_PACKGE_NAME_AREA_FEEMONTH_2 where type_name='视讯应用产品' group by 1) d
on a.offerd=d.offerd
order by offerd;
select offerd 一级销售品,注册拨号类,普通电话 固定电话,移动业务,视讯应用产品 IPTV类 from tmp_PACKGE_NAME_AREA_FEEMONTH order by offerd;

--执行结束





