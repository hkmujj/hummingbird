--����3G�ֻ���(20120922-20121031)
--���3G�ֻ��ڱ�־(�����û�)

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as
select a.*
, b.completed_date
, mgr_org_id,'����' ���淢չ��־ 
,mkt.mkt_channel_name Ӫ��Ӫά��
,com.com_channel_name ά��Ӫά��
from ST_MKT_MBL_FESTIVAL_DETAIL_DM a

left join DWD_S_CRM_STAFF staff on a.staff_code=staff.staff_code 
left join ds_chn_prd_serv_AREA_LAST_DAY b on a.acc_nbr=b.acc_nbr
left join DIM_ZONE_area mkt on b.mkt_grid_id=mkt.mkt_grid_id 
left join dim_zone_comm com on b.com_grid_id=com.com_grid_id 

where
-- area_name like 'ɳƺ��' 
(area_id=AREA or mgr_org_id=AREA_ID3 )
and handle_time between '2012-09-22 00:00:00' and '2012-10-31 23:59:59' 
distributed by (acc_nbr)
;

update tmp_PACKGE_NAME_AREA_FEEMONTH set ���淢չ��־='����' where mgr_org_id=AREA_ID3 and area_id<>AREA;
update tmp_PACKGE_NAME_AREA_FEEMONTH set ���淢չ��־='����' where mgr_org_id<>AREA_ID3 and area_id=AREA;

-- ���ӿ���ʱ��
drop table if exists  ttgm_AREA_1;
create temp table ttgm_AREA_1 as 
select acc_nbr, max(completed_date) max from tmp_PACKGE_NAME_AREA_FEEMONTH group by acc_nbr;

--delete from tmp_PACKGE_NAME_AREA_FEEMONTH where acc_nbr||completed_date not in (select acc_nbr||max from ttgm_AREA_1);

drop table if exists ttgm_AREA_2;
create table ttgm_AREA_2 as select b.* from ttgm_AREA_1 a left join tmp_PACKGE_NAME_AREA_FEEMONTH b on a.acc_nbr=b.acc_nbr and a.max=b.completed_date
where b.acc_nbr is not null;
insert into ttgm_AREA_2 select * from tmp_PACKGE_NAME_AREA_FEEMONTH where acc_nbr in (select acc_nbr from ttgm_AREA_1 where max is null) and acc_nbr not in (select acc_nbr from ttgm_AREA_2);

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select a.*, case when a.completed_date>='2012-09-22 00:00:00' and area_id=AREA then '��' else '�ɻ�����' end �¾ɱ�־ from ttgm_AREA_2 a;

--select * from ST_MKT_MBL_FESTIVAL_DETAIL_DM  where area_name like 'ɳƺ��'  and handle_time <'2012-09-25 00:00:00' and handle_time>='2012-09-24 00:00:00' ;
select '33';
