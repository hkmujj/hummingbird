/* 
一、全部替换DS_CHN_PRD_SERV_AREA_201108为DS_CHN_PRD_SERV_AREA_FEEMONTH
二、全部替换DS_CHN_PRD_OFFER_COMP_201108为DS_CHN_PRD_OFFER_COMP_FEEMONTH
三、全部替换DS_CHN_PRD_SERV_AREA_201108为DS_CHN_PRD_SERV_AREA_FEEMONTH
四、从提示执行开始拉黑至提示执行结束，点击执行查询，结果粘贴到EXCEL操作表，生成图表。
*/
--本页的执行时间约在36秒左右
--执行开始
--PPT1.2
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH_l;
create temporary table tmp_PACKGE_NAME_AREA_FEEMONTH_l as
select distinct a.serv_id,b.type_name,substring(e.OFFER_COMP_TYPE_DESC1 from 1 for 5) offerd
from 
DS_CHN_PRD_SERV_AREA_FEEMONTH a,--此处改用户表帐期和分公司，为分析帐期当月
DIM_PRODUCT b,DS_CHN_PRD_OFFER_COMP_FEEMONTH c,--此处改套餐分析表帐期，为分析帐期当月
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
select distinct a.serv_id,a.type_name,'未知' offerd from 
(
select distinct a.serv_id,a.type_name from 
(
select distinct a.serv_id,a.type_name,b.serv_id serv_id1 from 
(
select distinct a.serv_id,b.type_name
from 
DS_CHN_PRD_SERV_AREA_FEEMONTH a,--此处改用户表帐期，为分析帐期当月
DIM_PRODUCT b
where
a.product_id=b.product_id 
and 
b.type_name in ('注册拨号类','普通电话','移动业务','视讯应用产品') 
and 
a.state='00A'
and
a.SERV_NUM='1'
) a left join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.serv_id=b.serv_id
) a where serv_id1 is null
) a;
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH_2;--这里用了一个优先级来确认套餐类型归属，有E家套餐就先算E家套餐，没得就看有无政企非品牌，有的话就算商务政企，以此类推
create temporary table tmp_PACKGE_NAME_AREA_FEEMONTH_2 as
select distinct serv_id,type_name,'我的e家' offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_l where offerd='我的e家品';
insert into tmp_PACKGE_NAME_AREA_FEEMONTH_2
select distinct serv_id,type_name,'商务政企' offerd from
(
select serv_id,type_name,offerd from 
(select distinct a.serv_id nbr,b.serv_id,b.type_name,b.offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_2 a right join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.serv_id=b.serv_id)
a where nbr is null) a where offerd='政企非品牌';
insert into tmp_PACKGE_NAME_AREA_FEEMONTH_2
select distinct serv_id,type_name,'商务政企' offerd from
(
select serv_id,type_name,offerd from 
(select distinct a.serv_id nbr,b.serv_id,b.type_name,b.offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_2 a right join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.serv_id=b.serv_id)
a where nbr is null) a where offerd='商务领航品';
insert into tmp_PACKGE_NAME_AREA_FEEMONTH_2
select distinct serv_id,type_name,'天翼品牌' offerd from
(
select serv_id,type_name,offerd from 
(select distinct a.serv_id nbr,b.serv_id,b.type_name,b.offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_2 a right join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.serv_id=b.serv_id)
a where nbr is null) a where offerd='天翼品牌套';
insert into tmp_PACKGE_NAME_AREA_FEEMONTH_2
select distinct serv_id,type_name,'家庭个人' offerd from
(
select serv_id,type_name,offerd from 
(select distinct a.serv_id nbr,b.serv_id,b.type_name,b.offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_2 a right join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.serv_id=b.serv_id)
a where nbr is null) a where offerd='家庭非品牌';
insert into tmp_PACKGE_NAME_AREA_FEEMONTH_2
select distinct serv_id,type_name,'家庭个人' offerd from
(
select serv_id,type_name,offerd from 
(select distinct a.serv_id nbr,b.serv_id,b.type_name,b.offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_2 a right join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.serv_id=b.serv_id)
a where nbr is null) a where offerd='个人非品牌';
insert into tmp_PACKGE_NAME_AREA_FEEMONTH_2
select distinct serv_id,type_name,'其他' offerd from
(
select serv_id,type_name,offerd from 
(select distinct a.serv_id nbr,b.serv_id,b.type_name,b.offerd from tmp_PACKGE_NAME_AREA_FEEMONTH_2 a right join tmp_PACKGE_NAME_AREA_FEEMONTH_l b on a.serv_id=b.serv_id)
a where nbr is null) a where offerd='未知';

--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH_3;
create temporary table tmp_PACKGE_NAME_AREA_FEEMONTH_3 as
select distinct a.*,sum(c.amount) amount from 
tmp_PACKGE_NAME_AREA_FEEMONTH_2 a,DS_CHN_PRD_SERV_AREA_FEEMONTH b,--此处改用户表帐期，为分析帐期当月
DS_ACT_ACCT_ITEM_FEEMONTH c  --此处改BSN应收表帐期，为分析帐期当月
where a.serv_id=b.serv_id 
and a.serv_id=c.serv_id 
group by 1,2,3;
--此表是用PPT1的设备ID取BSN的应收账单，除去ITV、光纤等设备的设备费用。我本人的号码7月出账是208.8元，上表我的合同号下所有设备ID取出来的费用去掉ITV20元后，为188.8。
--这个表的费用肯定和每月财务营维支撑系统差距很大，仅代表一般公众套餐费用。特殊套餐、专线费这里不做处理。
--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as
select distinct a.offerd,a.注册拨号类,a.普通电话,a.移动业务,d.amount 视讯应用产品 from
(
select distinct c.offerd,a.注册拨号类,a.普通电话,c.amount 移动业务 from
(
select distinct b.offerd,a.amount 注册拨号类,b.amount 普通电话 from
(select distinct offerd,sum(amount) amount from tmp_PACKGE_NAME_AREA_FEEMONTH_3 where type_name='注册拨号类' group by 1) a
full join 
(select distinct offerd,sum(amount) amount from tmp_PACKGE_NAME_AREA_FEEMONTH_3 where type_name='普通电话' group by 1) b
on a.offerd=b.offerd
) a full join 
(select distinct offerd,sum(amount) amount from tmp_PACKGE_NAME_AREA_FEEMONTH_3 where type_name='移动业务' group by 1) c
on a.offerd=c.offerd
) a full join 
(select distinct offerd,sum(amount) amount from tmp_PACKGE_NAME_AREA_FEEMONTH_3 where type_name='视讯应用产品' group by 1) d
on a.offerd=d.offerd
order by offerd;
select offerd 一级销售品,注册拨号类,普通电话 固定电话,移动业务,视讯应用产品 IPTV类 from tmp_PACKGE_NAME_AREA_FEEMONTH order by offerd;
--执行结束
