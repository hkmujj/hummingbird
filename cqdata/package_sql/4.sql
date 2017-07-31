--因为2月帐期的月表数据集市没的了，如果本地有备份，则可以按月份和数据格式添加。下面一直执行到结束。表名请取xx_monttx。（分公司名称字母缩写加月份数。记得 替换名字。
如果直接用下表可以不改名称，因为建的是临时表）
一、全部替换DS_CHN_PRD_SERV_44为DS_CHN_PRD_SERV_xx

--执行开始
--9月
--drop table cs_month9;
create temporary table cs_month9 as
--E9部分
select distinct 'e9' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201109 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e9','尊享e9（天翼宽带尊享B版）')
and c.offer_kind='C'
and a.remove_date>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))))) and a.product_id='208511296' group by 1;
--E6部分
insert into cs_month9
select distinct 'e6' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201109 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e6','E6-11','e6手机版','乡情网-1','乡情网-2')
and c.offer_kind='C'
and a.remove_date>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))))) group by 1;
--E8部分
insert into cs_month9
select distinct 'e8' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201109 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e8','e8农村版（e8-11）','尊享e8（e8-2）')
and c.offer_kind='C'
and a.remove_date>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))))) group by 1;
--天翼CDMA部分
insert into cs_month9
select distinct '天翼T系列套餐' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201109 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP)))))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('商旅套餐（T1 ）','畅聊套餐(T3)','大众套餐(T4)','时尚套餐(T5)','天翼校园套餐（T7）','乐享3G套餐（T8）','年轻群体套餐(T9)')
and c.offer_kind='C'
and a.remove_date>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))))) group by 1;

--8月
--drop table cs_month8;
create temporary table cs_month8 as
--E9部分
select distinct 'e9' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201108 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e9','尊享e9（天翼宽带尊享B版）')
and c.offer_kind='C'
and a.remove_date>'2011-09-01 00:00:00' and a.product_id='208511296' group by 1;
--E6部分
insert into cs_month8
select distinct 'e6' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201108 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e6','E6-11','e6手机版','乡情网-1','乡情网-2')
and c.offer_kind='C'
and a.remove_date>'2011-09-01 00:00:00' group by 1;
--E8部分
insert into cs_month8
select distinct 'e8' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201108 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e8','e8农村版（e8-11）','尊享e8（e8-2）')
and c.offer_kind='C'
and a.remove_date>'2011-08-01 00:00:00' group by 1;
--天翼CDMA部分
insert into cs_month8
select distinct '天翼T系列套餐' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201108 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '1 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('商旅套餐（T1 ）','畅聊套餐(T3)','大众套餐(T4)','时尚套餐(T5)','天翼校园套餐（T7）','乐享3G套餐（T8）','年轻群体套餐(T9)')
and c.offer_kind='C'
and a.remove_date>'2011-09-01 00:00:00' group by 1;
--7月
--drop table cs_month7;
create temporary table cs_month7 as
--E9部分
select distinct 'e9' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201107 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '2 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '2 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e9','尊享e9（天翼宽带尊享B版）')
and c.offer_kind='C'
and a.remove_date>'2011-08-01 00:00:00' and a.product_id='208511296' group by 1;
--E6部分
insert into cs_month7
select distinct 'e6' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201107 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '2 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '2 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e6','E6-11','e6手机版','乡情网-1','乡情网-2')
and c.offer_kind='C'
and a.remove_date>'2011-08-01 00:00:00' group by 1;
--E8部分
insert into cs_month7
select distinct 'e8' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201107 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '2 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '2 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e8','e8农村版（e8-11）','尊享e8（e8-2）')
and c.offer_kind='C'
and a.remove_date>'2011-08-01 00:00:00' group by 1;
--天翼CDMA部分
insert into cs_month7
select distinct '天翼T系列套餐' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201107 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '2 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '2 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('商旅套餐（T1 ）','畅聊套餐(T3)','大众套餐(T4)','时尚套餐(T5)','天翼校园套餐（T7）','乐享3G套餐（T8）','年轻群体套餐(T9)')
and c.offer_kind='C'
and a.remove_date>'2011-08-01 00:00:00' group by 1;
--6月
--drop table cs_month6;
create temporary table cs_month6 as
--E9部分
select distinct 'e9' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201106 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '3 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '3 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e9','尊享e9（天翼宽带尊享B版）')
and c.offer_kind='C'
and a.remove_date>'2011-07-01 00:00:00' and a.product_id='208511296' group by 1;
--E6部分
insert into cs_month6
select distinct 'e6' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201106 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '3 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '3 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e6','E6-11','e6手机版','乡情网-1','乡情网-2')
and c.offer_kind='C'
and a.remove_date>'2011-07-01 00:00:00' group by 1;
--E8部分
insert into cs_month6
select distinct 'e8' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201106 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '3 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '3 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e8','e8农村版（e8-11）','尊享e8（e8-2）')
and c.offer_kind='C'
and a.remove_date>'2011-07-01 00:00:00' group by 1;
--天翼CDMA部分
insert into cs_month6
select distinct '天翼T系列套餐' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201106 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '3 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '3 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('商旅套餐（T1 ）','畅聊套餐(T3)','大众套餐(T4)','时尚套餐(T5)','天翼校园套餐（T7）','乐享3G套餐（T8）','年轻群体套餐(T9)')
and c.offer_kind='C'
and a.remove_date>'2011-07-01 00:00:00' group by 1;
--5月
--drop table cs_month5;
create temporary table cs_month5 as
--E9部分
select distinct 'e9' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201105 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e9','尊享e9（天翼宽带尊享B版）')
and c.offer_kind='C'
and a.remove_date>'2011-06-01 00:00:00' and a.product_id='208511296' group by 1;
--E6部分
insert into cs_month5
select distinct 'e6' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201105 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e6','E6-11','e6手机版','乡情网-1','乡情网-2')
and c.offer_kind='C'
and a.remove_date>'2011-06-01 00:00:00' group by 1;
--E8部分
insert into cs_month5
select distinct 'e8' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201105 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e8','e8农村版（e8-11）','尊享e8（e8-2）')
and c.offer_kind='C'
and a.remove_date>'2011-06-01 00:00:00' group by 1;
--天翼CDMA部分
insert into cs_month5
select distinct '天翼T系列套餐' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201105 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('商旅套餐（T1 ）','畅聊套餐(T3)','大众套餐(T4)','时尚套餐(T5)','天翼校园套餐（T7）','乐享3G套餐（T8）','年轻群体套餐(T9)')
and c.offer_kind='C'
and a.remove_date>'2011-06-01 00:00:00' group by 1;
--4月
--drop table cs_month3;
create temporary table cs_month4 as
--E9部分
select distinct 'e9' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201104 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e9','尊享e9（天翼宽带尊享B版）')
and c.offer_kind='C'
and a.remove_date>'2011-05-01 00:00:00' and a.product_id='208511296' group by 1;
--E6部分
insert into cs_month4
select distinct 'e6' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201104 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e6','E6-11','e6手机版','乡情网-1','乡情网-2')
and c.offer_kind='C'
and a.remove_date>'2011-05-01 00:00:00' group by 1;
--E8部分
insert into cs_month4
select distinct 'e8' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201104 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e8','e8农村版（e8-11）','尊享e8（e8-2）')
and c.offer_kind='C'
and a.remove_date>'2011-05-01 00:00:00' group by 1;
--天翼CDMA部分
insert into cs_month4
select distinct '天翼T系列套餐' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201104 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '4 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('商旅套餐（T1 ）','畅聊套餐(T3)','大众套餐(T4)','时尚套餐(T5)','天翼校园套餐（T7）','乐享3G套餐（T8）','年轻群体套餐(T9)')
and c.offer_kind='C'
and a.remove_date>'2011-05-01 00:00:00' group by 1;



--执行结束


--3月
--drop table cs_month3;
create temporary table cs_month3 as
--E9部分
select distinct 'e9' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201103 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '5 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '5 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e9','尊享e9（天翼宽带尊享B版）')
and c.offer_kind='C'
and a.remove_date>'2011-04-01 00:00:00' and a.product_id='208511296' group by 1;
--E6部分
insert into cs_month3
select distinct 'e6' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201103 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '5 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '5 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e6','E6-11','e6手机版','乡情网-1','乡情网-2')
and c.offer_kind='C'
and a.remove_date>'2011-04-01 00:00:00' group by 1;
--E8部分
insert into cs_month3
select distinct 'e8' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201103 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '5 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '5 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('e8','e8农村版（e8-11）','尊享e8（e8-2）')
and c.offer_kind='C'
and a.remove_date>'2011-04-01 00:00:00' group by 1;
--天翼CDMA部分
insert into cs_month3
select distinct '天翼T系列套餐' 四级套餐,count(distinct b.offer_comp_instance_id) 商品包个数
from 
DS_CHN_PRD_SERV_44_201103 a,
DS_PRD_OFFER_COMP_DETAIL b,
DIM_CRM_PRODUCT_OFFER c,
DIM_WD_OFFER_NEW_DIR_SECOND d
where 
a.serv_id=b.serv_id
and a.SERV_NUM='1'
and b.PROD_OFFER_INST_EXP_DATE>(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '5 month'))
and b.PROD_OFFER_INST_eff_DATE<(Values ((SELECT date_trunc('month', (select CURRENT_TIMESTAMP))) - interval '5 month'))
and b.offer_comp_id=c.offer_id
and c.offer_name=d.OFFER_COMP_TYPE_DESC6
and d.OFFER_COMP_TYPE_DESC4 in ('商旅套餐（T1 ）','畅聊套餐(T3)','大众套餐(T4)','时尚套餐(T5)','天翼校园套餐（T7）','乐享3G套餐（T8）','年轻群体套餐(T9)')
and c.offer_kind='C'
and a.remove_date>'2011-04-01 00:00:00' group by 1;




--汇总合计，最后结果。
select distinct a9.四级套餐,a4.商品包个数,a5.商品包个数,a6.商品包个数,a7.商品包个数,a8.商品包个数,a9.商品包个数
from 
cs_month9 a9,cs_month8 a8,cs_month7 a7,cs_month6 a6,cs_month5 a5,cs_month4 a4
where 
a9.四级套餐=a8.四级套餐
and a9.四级套餐=a7.四级套餐
and a9.四级套餐=a6.四级套餐
and a9.四级套餐=a5.四级套餐
and a9.四级套餐=a4.四级套餐;







