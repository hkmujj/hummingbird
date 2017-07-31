-- 丰都新增手机, E9部分
--简单统计

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH (
       id integer, item1 varchar(200), item2 varchar(200), value integer , t1 varchar(200), t2 varchar(200));
insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 1,'优惠数量统计', offer_name, count(*),'','' from tmp_elong3_AREA_FEEMONTH
GROUP by  1, 2, 3 order by 1, 2, 3;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 2,'套餐个数', 'e9商品包实例个数',count(distinct offer_comp_instance_id) , '', '' from tmp_elong3_AREA_FEEMONTH where offer_name not in (
'e家手机共享包（全话费版）' --331494
, 'e家手机共享包' --328071	--
,'全业务手机共享包5元/月/部（立即生效）' --319290
);

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 3,'手机个数', '手机号码个数',count(distinct acc_nbr) , '','' from tmp_elong3_AREA_FEEMONTH where 1=1; --offer_name='天翼领航翼龙手机套餐39档次';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 4,'其中手机新增个数', '新增手机号码个数',count(distinct acc_nbr), '', '' from tmp_elong3_AREA_FEEMONTH where completed_date>='2012-01-01 00:00:00'; --offer_name='天翼领航翼龙手机套餐39档次';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 5,'其中主套餐手机数量', '应与套餐个数相等',count(distinct a.acc_nbr) ,'','' from tmp_elong3_AREA_FEEMONTH a
left join (select acc_nbr from tmp_elong3_AREA_FEEMONTH where offer_name in ('e家手机共享包','e家手机共享包（全话费版）','全业务手机共享包5元/月/部（立即生效）' --319290
) ) b on a.acc_nbr=b.acc_nbr
where a.offer_name  not in (
'e家手机共享包（全话费版）' --331494
, 'e家手机共享包' --328071	--
,'全业务手机共享包5元/月/部（立即生效）' --319290
)
and b.acc_nbr is null
;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 15,'其中加装手机数量', '直接取E家手机加装包',count(distinct a.acc_nbr) ,'' ,'' from tmp_elong3_AREA_FEEMONTH a where offer_name in ('e家手机共享包','e家手机共享包（全话费版）','全业务手机共享包5元/月/部（立即生效）' --319290
);

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 25,'下面开始提可能的错误', '', 0, '','';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select 28,'录加装包而未选e9基础包的', a.acc_nbr, 0 ,a.staff_desc, a.com_grid_name from tmp_elong3_AREA_FEEMONTH a left join ( select acc_nbr from tmp_elong3_AREA_FEEMONTH where offer_name not in ('e家手机共享包','e家手机共享包（全话费版）','全业务手机共享包5元/月/部（立即生效）' --319290
) ) b on a.acc_nbr=b.acc_nbr
where a.offer_name  in ('e家手机共享包','e家手机共享包（全话费版）','全业务手机共享包5元/月/部（立即生效）' --319290
)  and b.acc_nbr is null;

-- 提加装包号码:
create temp table tmp0 as  
select distinct acc_nbr from tmp_elong3_AREA_FEEMONTH a where a.offer_name in ( 'e家手机共享包','e家手机共享包（全话费版）'
--319290	1319290	
,'全业务手机共享包5元/月/部（立即生效）' --	100298272882
,'全业务手机共享包5元/月/部（立即生效）' --319290
);
-- 提加装包同号的实例
create temp table tmp_id as select distinct offer_comp_instance_id from tmp_elong3_AREA_FEEMONTH where acc_nbr in (select acc_nbr from tmp0);
--提有基础包,而无共享包的剩余全部,其大于1的为有误
create temp table tmp3 as select distinct acc_nbr, staff_desc, com_grid_name, offer_name, offer_comp_instance_id from tmp_elong3_AREA_FEEMONTH where offer_comp_instance_id not in (select * from tmp_id);
create temp table tmp4 as 
select offer_comp_instance_id from tmp3 
where offer_comp_instance_id<>-99 group by 1 having count(*)>1;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select distinct 29,'录基础包而无加装包的',b.acc_nbr, b.offer_comp_instance_id,b.staff_desc, b.com_grid_name from tmp4 a left join tmp_elong3_AREA_FEEMONTH b on a.offer_comp_instance_id=b.offer_comp_instance_id ;

-- 还有: 未录V网的, 同套餐而不同V网群的, 进V网群而未录互打免费优惠商品的
--13310275328	108885	313835	vpn虚拟群(网内免费)群号1-1000000部分CDMA
--023-70708080	108885	62190	vpn虚拟群(网内免费)群号1-1000000部分普通电话	100192796468
insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select distinct 33,'未录V网的',b.acc_nbr, b.offer_comp_instance_id,b.staff_desc, b.com_grid_name from tmp_elong3_AREA_FEEMONTH b
where b.group_id is null
;
insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select distinct 44,'同套餐而不同V网的',a.offer_comp_instance_id||':'||a.acc_nbr, a.offer_comp_instance_id,a.staff_desc, a.com_grid_name from tmp_elong3_AREA_FEEMONTH a left join tmp_elong3_AREA_FEEMONTH b on a.offer_comp_instance_id=b.offer_comp_instance_id where a.group_id<>b.group_id and a.group_id is not null and b.group_id is not null
order by a.offer_comp_instance_id;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select distinct 46,'同套餐而不同合同号',a.offer_comp_instance_id||':'||a.acc_nbr, a.offer_comp_instance_id,a.staff_desc, a.com_grid_name from tmp_elong3_AREA_FEEMONTH a left join tmp_elong3_AREA_FEEMONTH b on a.offer_comp_instance_id=b.offer_comp_instance_id where a.mkt_cust_code<>b.mkt_cust_code  and a.offer_comp_instance_id<>-99
order by a.offer_comp_instance_id;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH 
select distinct 54,'做V网而未做互打免费的',a.acc_nbr, a.offer_comp_instance_id,a.staff_desc, a.com_grid_name from tmp_elong3_AREA_FEEMONTH a 
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='00A' and b.prod_offer_id in ('62190','313835')
where b.serv_id is null
--order by a.offer_comp_instance_id;
;

select '33';
--* from tmp_g2_33_201110;
