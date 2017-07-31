--宽带而无ADSL共线群的号码
--荣昌提出思路
--本脚本的执行时间在10秒左右
--有两种情况: 1.是宽带,而无对应ADSL共线群
--2.有ADSL共线群,但固话成员缺失
--如果要增加维护线网格等数据,请导出成为电子表格后,在批量查询里去查询了粘贴.没有在此页一并增加那些字段,是为了保持此处语句的简单性.

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select a.acc_nbr,b.group_id from ds_chn_prd_serv_AREA_FEEMONTH a 
left join dm_prd_crm_service_grp_member b on a.serv_id=b.serv_id and b.member_role_id = 2
left join dm_prd_crm_service_grp_member c on b.group_id=c.group_id and c.member_role_id=1
where a.product_id=102030001  --ADSL
and a.state='00A' and a.serv_state='2HA'
and c.group_id is null
limit 22210;


select '33';
--* from tmp_g2_33_201110;
