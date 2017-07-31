--丰都翼龙迎春活动积分榜

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH (
	id int,
	项目名称 varchar(20)
	, 城东 int
	,城西 int
	,社坛 int
       ,树人 int
,高镇 int
,龙河 int
,分公司 int
);

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (1,'新装宽带总数', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
城东=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都城东营维部') , 
城西=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都城西营维部' ) ,
社坛=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都社坛营维部' ) ,
树人=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都树人营维部' ) ,
高镇=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都高镇营维部' ) ,
龙河=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都龙河营维部' ) ,
分公司=(select count(*) from tmp_fd2_AREA_FEEMONTH where 1=1 )
where 项目名称='新装宽带总数';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (2, '新装宽带计分总数', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
城东=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都城东营维部' and score>0 ) , 
城西=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都城西营维部' and score>0 ) ,
社坛=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都社坛营维部'  and score>0) ,
树人=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都树人营维部'  and score>0) ,
高镇=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都高镇营维部'  and score>0) ,
龙河=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都龙河营维部'  and score>0) ,
分公司=(select count(*) from tmp_fd2_AREA_FEEMONTH where 1=1  and score>0)
where 项目名称='新装宽带计分总数';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (3, '新装宽带未计分总数', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
城东=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都城东营维部' and score=0 ) , 
城西=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都城西营维部' and score=0 ) ,
社坛=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都社坛营维部'  and score=0) ,
树人=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都树人营维部'  and score=0) ,
高镇=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都高镇营维部'  and score=0) ,
龙河=(select count(*) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都龙河营维部'  and score=0) ,
分公司=(select count(*) from tmp_fd2_AREA_FEEMONTH where 1=1  and score=0)
where 项目名称='新装宽带未计分总数';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (4, '新装宽带积分', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
城东=(select sum(score) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都城东营维部'  ) , 
城西=(select sum(score) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都城西营维部'  ) ,
社坛=(select sum(score) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都社坛营维部'  ) ,
树人=(select sum(score) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都树人营维部'  ) ,
高镇=(select sum(score) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都高镇营维部'  ) ,
龙河=(select sum(score) from tmp_fd2_AREA_FEEMONTH where com_channel_name='丰都龙河营维部'  ) ,
分公司=(select sum(score) from tmp_fd2_AREA_FEEMONTH where 1=1  )
where 项目名称='新装宽带积分';


insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (6,'新装手机总数', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
城东=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都城东营维部') , 
城西=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都城西营维部' ) ,
社坛=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都社坛营维部' ) ,
树人=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都树人营维部' ) ,
高镇=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都高镇营维部' ) ,
龙河=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都龙河营维部' ) ,
分公司=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where 1=1 )
where 项目名称='新装手机总数';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (7,'新装手机计分总数', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
城东=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都城东营维部' and score>0 ) , 
城西=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都城西营维部' and score>0 ) ,
社坛=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都社坛营维部'  and score>0) ,
树人=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都树人营维部'  and score>0) ,
高镇=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都高镇营维部'  and score>0) ,
龙河=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都龙河营维部' and score>0 ) ,
分公司=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where 1=1 and score>0 )
where 项目名称='新装手机计分总数';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (8,'新装手机未计分总数', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
城东=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都城东营维部' and score=0 ) , 
城西=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都城西营维部' and score=0 ) ,
社坛=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都社坛营维部'  and score=0) ,
树人=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都树人营维部'  and score=0) ,
高镇=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都高镇营维部'  and score=0) ,
龙河=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都龙河营维部' and score=0 ) ,
分公司=(select count(distinct acc_nbr) from tmp_fd3_AREA_FEEMONTH where 1=1 and score=0 )
where 项目名称='新装手机未计分总数';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (9,'新装手机积分', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
城东=(select sum(score) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都城东营维部' and score>0 ) , 
城西=(select sum(score) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都城西营维部' and score>0 ) ,
社坛=(select sum(score) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都社坛营维部'  and score>0) ,
树人=(select sum(score) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都树人营维部'  and score>0) ,
高镇=(select sum(score) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都高镇营维部'  and score>0) ,
龙河=(select sum(score) from tmp_fd3_AREA_FEEMONTH where com_channel_name='丰都龙河营维部' and score>0 ) ,
分公司=(select sum(score) from tmp_fd3_AREA_FEEMONTH where 1=1 and score>0 )
where 项目名称='新装手机积分';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (18,'老宽带提速到4M个数', 
(select count(*) from tmp_fd4_AREA_FEEMONTH where com_channel_name='丰都城东营维部' and score>0 ) , 
(select count(*) from tmp_fd4_AREA_FEEMONTH where com_channel_name='丰都城西营维部' and score>0 ) ,
(select count(*) from tmp_fd4_AREA_FEEMONTH where com_channel_name='丰都社坛营维部'  and score>0) ,
(select count(*) from tmp_fd4_AREA_FEEMONTH where com_channel_name='丰都树人营维部'  and score>0) ,
(select count(*) from tmp_fd4_AREA_FEEMONTH where com_channel_name='丰都高镇营维部'  and score>0) ,
(select count(*) from tmp_fd4_AREA_FEEMONTH where com_channel_name='丰都龙河营维部' and score>0 ) ,
(select count(*) from tmp_fd4_AREA_FEEMONTH where 1=1 and score>0 )
)
;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (19,'老宽带提速到4M积分', 
(select sum(score) from tmp_fd4_AREA_FEEMONTH where com_channel_name='丰都城东营维部' and score>0 ) , 
(select sum(score) from tmp_fd4_AREA_FEEMONTH where com_channel_name='丰都城西营维部' and score>0 ) ,
(select sum(score) from tmp_fd4_AREA_FEEMONTH where com_channel_name='丰都社坛营维部'  and score>0) ,
(select sum(score) from tmp_fd4_AREA_FEEMONTH where com_channel_name='丰都树人营维部'  and score>0) ,
(select sum(score) from tmp_fd4_AREA_FEEMONTH where com_channel_name='丰都高镇营维部'  and score>0) ,
(select sum(score) from tmp_fd4_AREA_FEEMONTH where com_channel_name='丰都龙河营维部' and score>0 ) ,
(select sum(score) from tmp_fd4_AREA_FEEMONTH where 1=1 and score>0 )
)
;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (21,'宽带拆机积分', 
(select sum(score) from tmp_fd5_AREA_FEEMONTH where com_channel_name='丰都城东营维部') , 
(select sum(score) from tmp_fd5_AREA_FEEMONTH where com_channel_name='丰都城西营维部') ,
(select sum(score) from tmp_fd5_AREA_FEEMONTH where com_channel_name='丰都社坛营维部') ,
(select sum(score) from tmp_fd5_AREA_FEEMONTH where com_channel_name='丰都树人营维部') ,
(select sum(score) from tmp_fd5_AREA_FEEMONTH where com_channel_name='丰都高镇营维部') ,
(select sum(score) from tmp_fd5_AREA_FEEMONTH where com_channel_name='丰都龙河营维部') ,
(select sum(score) from tmp_fd5_AREA_FEEMONTH where 1=1 )
)
;

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (31,'手机拆机积分', 
(select sum(score) from tmp_fd6_AREA_FEEMONTH where com_channel_name='丰都城东营维部') , 
(select sum(score) from tmp_fd6_AREA_FEEMONTH where com_channel_name='丰都城西营维部') ,
(select sum(score) from tmp_fd6_AREA_FEEMONTH where com_channel_name='丰都社坛营维部') ,
(select sum(score) from tmp_fd6_AREA_FEEMONTH where com_channel_name='丰都树人营维部') ,
(select sum(score) from tmp_fd6_AREA_FEEMONTH where com_channel_name='丰都高镇营维部') ,
(select sum(score) from tmp_fd6_AREA_FEEMONTH where com_channel_name='丰都龙河营维部') ,
(select sum(score) from tmp_fd6_AREA_FEEMONTH where 1=1  )
)
;
insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (31,'iTV新增积分', 
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where com_channel_name='丰都城东营维部') , 
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where com_channel_name='丰都城西营维部') ,
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where com_channel_name='丰都社坛营维部') ,
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where com_channel_name='丰都树人营维部') ,
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where com_channel_name='丰都高镇营维部') ,
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where com_channel_name='丰都龙河营维部') ,
(select sum(score) from tmp_fd_itv_AREA_FEEMONTH where 1=1  )
)
;
-- 城东 城西 社坛 树人  高镇 龙河 分公司
insert into tmp_PACKGE_NAME_AREA_FEEMONTH values(80,'智能机临时加分',
	000, 000, 000, 0, 2740, 0, 2740);
-- 高镇: 兴义75,双路13, 智能机,但未及录入串码,不是翼龙,不是优惠购25元

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values(89,'FTTH接入宽带改造加分',
	3210, 150, 000, 000, 000, 0, 3360);
insert into tmp_PACKGE_NAME_AREA_FEEMONTH values(80,'天翼办公加分',
	1000, 1000, 2000, 1000, 2000, 0, 7000);
-- 城东 三峡水务丰都排水有限责任公司天翼办公：OA100296
-- 城西 OA100279 客户名称：湛普镇政府 
-- 高镇 兴义政府,双路政府天翼办公
-- 树人政府天翼办公1000分
insert into tmp_PACKGE_NAME_AREA_FEEMONTH values(80,'光纤专线加分',
36401 , 2200, 0, 0, 2900+5067, 0, 36401+2200+2900+5067);
-- 城东 工地监控专线 30条*800 加分 36401
-- 城西 包鸾小学      专线号：603129552   1000/月 
-- 城西 湛普党政办    专线号：603129383   1200/月 
-- 高镇 兴义政府办603128771光纤费2000分
-- 高镇  网名居网吧提速3061008493 2012-1-18 有改计费方案月加900元 加900分
-- 城东 城西 社坛 树人  高镇 龙河 分公司
-- 20120308 高镇
-- 丰二中 年收入从6万变8万；双路月600变2000；高家镇初级中学新装光纤接入2000元每月,已签协议, 另有团购手机约20台,但估记不能在3月10日前竣工.专线加分共计1667+1400+2000=5067
insert into tmp_PACKGE_NAME_AREA_FEEMONTH values(80,'营维部跨区发展加分',
	0, 475, 0, 0, 0, 0, 475);
--城西发展跨区域的翼龙计划，团购5户，请加积分，用户是要求的合帐在固话上。 
--18996706240 --18996706241 --18996706242 --18996706243 --18996736780 --固话号码是：70770888 
--发展人也录入了的，分别是彭秀凤和陈忠(ab)  

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (97,'总积分', 0,0,0,0,0,0,0);
update tmp_PACKGE_NAME_AREA_FEEMONTH set 
城东=(select sum(城东) from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称 in ('新装宽带积分', '新装手机积分', '老宽带提速到4M积分', '宽带拆机积分', '手机拆机积分', 'FTTH接入宽带改造加分', '行业应用积分', '天翼办公加分', 'iTV新增积分','光纤专线加分','营维部跨区发展加分','智能机临时加分') )  
,城西=(select sum(城西) from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称 in ('新装宽带积分', '新装手机积分', '老宽带提速到4M积分', '宽带拆机积分', '手机拆机积分', 'FTTH接入宽带改造加分', '行业应用积分', '天翼办公加分', 'iTV新增积分','光纤专线加分','营维部跨区发展加分','智能机临时加分') )  
,社坛=(select sum(社坛) from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称 in ('新装宽带积分', '新装手机积分', '老宽带提速到4M积分', '宽带拆机积分', '手机拆机积分', 'FTTH接入宽带改造加分', '行业应用积分', '天翼办公加分', 'iTV新增积分','光纤专线加分','营维部跨区发展加分','智能机临时加分') )  
,树人=(select sum(树人) from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称 in ('新装宽带积分', '新装手机积分', '老宽带提速到4M积分', '宽带拆机积分', '手机拆机积分', 'FTTH接入宽带改造加分', '行业应用积分', '天翼办公加分', 'iTV新增积分','光纤专线加分','营维部跨区发展加分','智能机临时加分') )  
,高镇=(select sum(高镇) from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称 in ('新装宽带积分', '新装手机积分', '老宽带提速到4M积分', '宽带拆机积分', '手机拆机积分', 'FTTH接入宽带改造加分', '行业应用积分', '天翼办公加分', 'iTV新增积分','光纤专线加分','营维部跨区发展加分','智能机临时加分') )  
,龙河=(select sum(龙河) from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称 in ('新装宽带积分', '新装手机积分', '老宽带提速到4M积分', '宽带拆机积分', '手机拆机积分', 'FTTH接入宽带改造加分', '行业应用积分', '天翼办公加分', 'iTV新增积分','光纤专线加分','营维部跨区发展加分','智能机临时加分','光纤专线加分','营维部跨区发展加分','智能机临时加分','光纤专线加分','营维部跨区发展加分','智能机临时加分') )  
,分公司=(select sum(分公司) from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称 in ('新装宽带积分', '新装手机积分', '老宽带提速到4M积分', '宽带拆机积分', '手机拆机积分', 'FTTH接入宽带改造加分', '行业应用积分', '天翼办公加分', 'iTV新增积分','光纤专线加分','营维部跨区发展加分','智能机临时加分') )  
where 项目名称='总积分';

insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (98,'T1值', 110500,100000,55000,35000,60000,43000,403500);
insert into tmp_PACKGE_NAME_AREA_FEEMONTH values (99,'进度百分比'
	, (select 城东 from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称='总积分')*1.0/110500.0*100
	, (select 城西 from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称='总积分')/100000.0*100
	, (select 社坛 from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称='总积分')/55000.0*100
	, (select 树人 from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称='总积分')/35000.0*100
	, (select 高镇 from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称='总积分')/60000.0*100
	, (select 龙河 from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称='总积分')/43000.0*100
	, (select 分公司 from tmp_PACKGE_NAME_AREA_FEEMONTH where 项目名称='总积分')/403500.0*100
	--,100000,55000,35000,60000,43000,403500
);
select 33;
--* from tmp_g2_33_201110;
