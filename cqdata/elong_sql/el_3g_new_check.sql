--天翼3G手机节(20120922-20121031)
--新增手机清单(只取竣工)   --稽核脚本
--两种口径: 1.用户表的竣工日期处于20120922-20121031
--2.从李鸣大师的竣工工单表中竣工日期处于上述时间段
/* 希望能够提取的字段:
日期	手机号码	姓名	新老	手机节	资费	机型	串号	受理人	揽收人	备注
*/

--稽核表名: tmp_el_3g_new_AREA_FEEMONTH
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select '' id,a.* from tmp_el_3g_new_AREA_FEEMONTH a limit 0 distributed by (acc_nbr); 
-- 竣工日期在9月22日以前的清单,无手机节标志的, 需要代理商确认不参加手机节.
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, 竣工日期) values ('受理时间在9月22日以前的,需要代理商确认不参加手机节');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '1受理时间在9月21日以前的',a.* from tmp_el_3g_new_AREA_FEEMONTH a where 受理时间<'2012-09-22 00:00:00' and 手机节 is null and 竣工日期>='2012-09-22 00:00:00';
-- 竣工日期在9月22日以前的清单,手机节标志的, 需要确认终端销售时间在9月22日及以后.

--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (9);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, 竣工日期) values (10, '受理时间在9月22日以前且有串码的,需要代理商确认串码销售时间在9月22日及以后');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '2受理时间在9.22前且有串码的',a.* from tmp_el_3g_new_AREA_FEEMONTH a where 受理时间<'2012-09-22 00:00:00' and 手机节 is not null and 竣工日期>='2012-09-22 00:00:00' and  serv_state='2HA';

--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (19);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, 竣工日期) values (20, '没有录串码的,是否都为用户带机入户,或是代理商销售非手机节的裸机?');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '3没有录串码的',a.* from tmp_el_3g_new_AREA_FEEMONTH a where 受理时间>='2012-09-22 00:00:00' and (串码='\\' or 串码 is null) and 竣工日期>='2012-09-22 00:00:00'  and serv_state='2HA';


--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (30);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, 竣工日期) values (31, '录了串码没有录手机节标志,确认?');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '4有串码无手机节打标的',a.* from tmp_el_3g_new_AREA_FEEMONTH a where 受理时间>='2012-09-22 00:00:00' and not (串码='\\' or 串码 is null) and 手机节 is null and 竣工日期>='2012-09-22 00:00:00'  and serv_state='2HA';


--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (40);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, 竣工日期) values (41, '未录串码而有录手机节标志,应有错');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '5未录串码而有手机节标志',a.* from tmp_el_3g_new_AREA_FEEMONTH a where 受理时间>='2012-09-22 00:00:00' and (串码='\\' or 串码 is null) and 手机节 is not null and 竣工日期>='2012-09-22 00:00:00' and serv_state='2HA';

--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (50);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, 竣工日期) values (51, '基础包为空, 多半是加装手机只录了加装包,没有录基础包');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '6基础包为空,肯定有错',a.* from tmp_el_3g_new_AREA_FEEMONTH a where 基础包 is  null and 竣工日期>='2012-09-22 00:00:00'  and serv_state='2HA';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '65未与宽带或固话合户,但付费方式为后付费的',a.* from tmp_el_3g_new_AREA_FEEMONTH a where ad加固话数量=0 and 
付费模式=1 and serv_state='2HA' 
and 竣工日期>='2012-10-25 00:00:00'
;

--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (60);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, 竣工日期) values (61, '到达标志为0, 因何原因拆机');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '7拆机或停机的',a.* from tmp_el_3g_new_AREA_FEEMONTH a where remove_date<'2030-12-31' and 竣工日期>='2012-09-22 00:00:00'  and serv_state<>'2HA';


--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (70);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, 竣工日期) values (71, '工号为空,可能因重庆配置不及');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '8工号为空',a.* from tmp_el_3g_new_AREA_FEEMONTH a where 受理员工 is null  and 竣工日期>='2012-09-22 00:00:00'  and serv_state='2HA';


--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (80);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, 竣工日期) values (81, '龙卡而未选档次的');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '90龙卡而未选档次',a.* from tmp_el_3g_new_AREA_FEEMONTH a where 基础包 like '%%天翼龙卡套餐%%' and 龙卡或翼龙档次 is null and 竣工日期>='2012-09-22 00:00:00' and serv_state='2HA';


--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id) values (90);
--insert into tmp_PACKGE_NAME_AREA_FEEMONTH (id, 竣工日期) values (91, '龙卡而未送话费的,确认');
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '91龙卡而未送话费',a.* from tmp_el_3g_new_AREA_FEEMONTH a where 基础包 like '%%天翼龙卡套餐%%' and 送话费 is null and 竣工日期>='2012-09-22 00:00:00' and serv_state='2HA';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '92打标智能机而未送100M流量的',a.* from tmp_el_3g_new_AREA_FEEMONTH a where 手机节 like '%%智能机%%' and 送流量 is null and 竣工日期>='2012-09-22 00:00:00' and serv_state='2HA';

-- 经客服谭娇艳提醒, 增加一种: 合同号建档时间早于手机节, 即采用了老合同号的
insert into tmp_PACKGE_NAME_AREA_FEEMONTH select '93怀疑采用了老合同号的',a.* from tmp_el_3g_new_AREA_FEEMONTH a where 合同号建立时间<'2012-09-22 00:00:00' and 竣工日期>='2012-09-22 00:00:00' and serv_state='2HA';

select '33';
