-- 丰都新增手机清单--翼龙部分,专题
--简单统计

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH (
       id integer, item1 varchar(200), item2 varchar(200), value integer );
insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 1,'优惠数量统计', offer_name, count(*) from tmp_elong1_AREA_FEEMONTH
GROUP by  1, 2, 3 order by 1, 2, 3;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 2,'套餐个数', '39商品包实例个数',count(distinct offer_comp_instance_id) from tmp_elong1_AREA_FEEMONTH where offer_name='天翼领航翼龙手机套餐39档次';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 3,'手机个数', '手机号码个数',count(distinct acc_nbr) from tmp_elong1_AREA_FEEMONTH where 1=1; --offer_name='天翼领航翼龙手机套餐39档次';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 4,'其中手机新增个数', '新增手机号码个数',count(distinct acc_nbr) from tmp_elong1_AREA_FEEMONTH where completed_date>='2012-01-01 00:00:00'; --offer_name='天翼领航翼龙手机套餐39档次';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 5,'其中主套餐手机数量', '应与套餐个数相等',count(distinct a.acc_nbr) from tmp_elong1_AREA_FEEMONTH a
left join (select acc_nbr from tmp_elong1_AREA_FEEMONTH where offer_name ='翼龙套餐手机加装包') b on a.acc_nbr=b.acc_nbr
where a.offer_name='天翼领航翼龙手机套餐39档次' 
and b.acc_nbr is null
;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 15,'其中加装手机数量', '直接取翼龙手机加装包',count(distinct a.acc_nbr) from tmp_elong1_AREA_FEEMONTH a where offer_name='翼龙套餐手机加装包';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 25,'下面开始提可能的错误', '', 0;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 26,'录39基础包而未选语音包的', a.acc_nbr, 0 from tmp_elong1_AREA_FEEMONTH a left join ( select acc_nbr from tmp_elong1_AREA_FEEMONTH where offer_name like '%%天翼领航%%元翼龙语音包') b on a.acc_nbr=b.acc_nbr
where a.offer_name = '天翼领航翼龙手机套餐39档次' and b.acc_nbr is null;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 26,'录语音包而未选39基础包', a.acc_nbr, 0 from tmp_elong1_AREA_FEEMONTH a left join ( select acc_nbr from tmp_elong1_AREA_FEEMONTH where offer_name ='天翼领航翼龙手机套餐39档次') b on a.acc_nbr=b.acc_nbr
where a.offer_name like '%%天翼领航%%元翼龙语音包' and b.acc_nbr is null;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 27,'录加装包而未选语音包的', a.acc_nbr, 0 from tmp_elong1_AREA_FEEMONTH a left join ( select acc_nbr from tmp_elong1_AREA_FEEMONTH where offer_name like '%%天翼领航%%元翼龙语音包') b on a.acc_nbr=b.acc_nbr
where a.offer_name = '翼龙套餐手机加装包' and b.acc_nbr is null;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 28,'录加装包而未选39基础包的', a.acc_nbr, 0 from tmp_elong1_AREA_FEEMONTH a left join ( select acc_nbr from tmp_elong1_AREA_FEEMONTH where offer_name = '天翼领航翼龙手机套餐39档次') b on a.acc_nbr=b.acc_nbr
where a.offer_name = '翼龙套餐手机加装包' and b.acc_nbr is null;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 30,'怀疑录漏加装包的', pg_concat(a.acc_nbr||'-'), offer_comp_instance_id 
from tmp_elong1_AREA_FEEMONTH a left join (select acc_nbr from tmp_elong1_AREA_FEEMONTH where offer_name='翼龙套餐手机加装包') b on a.acc_nbr=b.acc_nbr
where a.offer_name<>'翼龙套餐手机加装包' and b.acc_nbr is null
group by 1,2,4
having count(*)>1;

--只有加装包而没有主套餐号码的, 思路为与加装包号码共39的号码不能少于1个
--这玩意儿还真不好提
insert into tmp_PACKGE_NAME_AREA_FEEMONTH
select b.* from 
(select 33,'只有加装包的', a.acc_nbr, b.offer_comp_instance_id from tmp_elong1_AREA_FEEMONTH a left join (select acc_nbr, offer_comp_instance_id from tmp_elong1_AREA_FEEMONTH where offer_name='天翼领航翼龙手机套餐39档次') b on a.acc_nbr=b.acc_nbr
--and  a.offer_comp_instance_id=b.offer_comp_instance_id
where a.offer_name='翼龙套餐手机加装包') b
left join tmp_elong1_AREA_FEEMONTH c on c.offer_comp_instance_id=b.offer_comp_instance_id and c.acc_nbr<>b.acc_nbr
where c.offer_comp_instance_id is null;

--共套餐而不同合同号的
--容易出现其中一个号码欠费
insert into tmp_PACKGE_NAME_AREA_FEEMONTH
select '32','同套餐而不同合同号',''||a.acc_nbr, b.acc_nbr from tmp_elong1_AREA_FEEMONTH a 
left join tmp_elong1_AREA_FEEMONTH b on a.offer_comp_instance_id=b.offer_comp_instance_id 
and b.offer_name='天翼领航翼龙手机套餐39档次' and b.acc_nbr>a.acc_nbr
where a.offer_name='天翼领航翼龙手机套餐39档次' and a.mkt_cust_code<>b.mkt_cust_code
;

select '33';
--* from tmp_g2_33_201110;
