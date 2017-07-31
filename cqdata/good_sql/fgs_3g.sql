--�ֹ�˾3g����
--�ֹ�˾	C�������û�	ȫ���û�	��Ծ�û�	������MB��	��Ծ��	��������	3G��͸��	���ܻ�ȫ���û�	���ܻ���Ծ�û�	���ܻ�������MB��	���ܻ���Ծ��	���ܻ���������	����ȫ���û�	������Ծ�û�	�����û�������MB��	�����û���Ծ��	�����û���������

-----------------FEEMONTH------2012-04-01----2012-04-30----------

--�û���Ϊ����-3G��Ծ�û� 
select e.* ,a.serv_id ,c.net_throughput  into temp ryt_3g_active 
from ds_prd_group_tgserv_FEEMONTH a  
left join (select serv_id from ds_evt_group_call_FEEMONTH where CALL_DURATION > 0 group by serv_id) b 
on a.serv_id = b.serv_id  
left join (select serv_id,sum(net_throughput) net_throughput from ds_evt_group_call_FEEMONTH  
where  group_event_type_id = 7003 group by serv_id) c on a.serv_id = c.serv_id  
left join DS_CHN_PRD_SERV_MKT_AREA_FEEMONTH d on a.serv_id = d.serv_id 
left join dim_zone_area e on d.mkt_grid_id=e.mkt_grid_id and e.active_flag = 1 
where g3_flag = 0  and a.product_id = 10  
and b.SERV_ID is not null and net_throughput < 5*1024*1024;

select count(*) from ryt_3g_active;

--�������ݼ����ϵ�3G�ն˱����ݼ����ϵ�3G�ն˱���ڽ�β�пո����������磺BW-BenWee S106  
select trim(evdo_type) evdo_type into temp dim_evdo_terminal_type_ry_asia from dim_evdo_terminal_type_ry; 

--ȡ��ע��3G�û� 
select acc_nbr ,type ,register_time ,rank() over(partition by acc_nbr order by register_time desc)  into temp ryt_terminal 
from ds_evt_terminal_info_all_ry where date(register_time) <='LAST_DAY'
--'2012-04-30'
; 

select acc_nbr,type into temp ryt_terminal_3g from ryt_terminal where rank = 1 and type in (select evdo_type from dim_evdo_terminal_type_ry_asia); 

select count(*) from ryt_terminal_3g;

--3G��Ĭ�û� 
select e.*,a.serv_id  into temp ryt_3g_not_active 
from ds_prd_group_tgserv_FEEMONTH a --���뼶�����û����ϱ� 
left join (select serv_id from ds_evt_group_call_FEEMONTH --���뼶�����û�ҵ������ 
where CALL_DURATION > 0 /*ͨ��ʱ������0*/ group by serv_id) b on a.serv_id = b.serv_id  
left join (select serv_id,sum(net_throughput) net_throughput from ds_evt_group_call_FEEMONTH where  group_event_type_id = 7003 /*��EVDO����*/group by serv_id) c on a.serv_id =c.serv_id  
left join DS_CHN_PRD_SERV_MKT_AREA_FEEMONTH d on a.serv_id = d.serv_id 
left join dim_zone_area e on d.mkt_grid_id = e.mkt_grid_id and e.active_flag = 1 
where g3_flag = 0 /*�������ײͱ�ǩ*/ and a.product_id = 10 and c.net_throughput is null 
and b.SERV_ID is not null 
and a.acc_nbr in(select acc_nbr from ryt_terminal_3g); 

--����ȫ���û� 
select serv_id,mkt_grid_id,net_throughput/1024 flow,1 active_flag into temp ryt_3g_all from ryt_3g_active; 
insert into ryt_3g_all select serv_id,mkt_grid_id,0 flow,0 active_flag from ryt_3g_not_active; 

-------------------------------------------����Ȧ��Ŀ��ͻ�--------------------------------------------------

select a.*,b.acc_nbr into temp ryt1
from ryt_3g_all a,DS_CHN_PRD_SERV_MKT_AREA_FEEMONTH b
where a.serv_id = b.serv_id;

--�ն��ͺ�
select distinct a.*,b.type into temp ryt2
from ryt1 a left outer join ryt_terminal b
on a.acc_nbr = b.acc_nbr and b.rank = 1;

--���ܻ���ʶ
select distinct a.*,b.phone_type into temp ryt3
from ryt2 a left outer join dim_smart_phone_type_ry b
on a.type = b.phone_type;

--����
select b.mkt_area_name,b.mkt_channel_name,b.mkt_grid_name,a.serv_id,a.acc_nbr,a.type,a.phone_type smart_flag,a.active_flag,a.flow
into temp ryt4 from ryt3 a left outer join dim_zone_area b
on a.mkt_grid_id = b.mkt_grid_id;

update ryt4 set smart_flag = '1' where smart_flag is not null;
update ryt4 set smart_flag = '0' where smart_flag is null;

--������ʶ
select a.*,b.onln_flg new_flag into temp ryt5
from ryt4 a left outer join DS_CHN_PRD_SERV_MKT_AREA_FEEMONTH b
on a.serv_id = b.serv_id and 
--b.created_date >= '2012-04-01 00:00:00' and b.created_date <= '2012-04-30 23:59:59' 
b.created_date like '{yyyy-mm}%%' and onln_flg = '1';

---�ײ����
select distinct a.owner_id,
         case when a.INIT_VALUE = '0' then a.PEAK_VALUE
              when a.PEAK_VALUE = '0' then a.INIT_VALUE
            end "��ʼֵ",
         a.BALANCE ʹ����,
         case when a.INIT_VALUE = '0' then a.PEAK_VALUE-a.BALANCE
              when a.PEAK_VALUE = '0' then a.INIT_VALUE-a.BALANCE
         end "ʣ����",
         case when c.acc_unit = 'MB'  then  c.acc_unit 
         end "����",
         case when c.acc_unit = '����'  then  c.acc_unit 
         end "ʱ��"
into temp ryt_tc_all
from DM_PRD_OFFER_ACCUMULATOR  a left join DM_EVT_QUERY_ACCUMULATOR_CONFIG_FEEMONTH b 
on a.RATABLE_RESOURCE_ID = b.RATABLE_RESOURCE_ID 
left join DM_EVT_QUERY_ACCUMULATOR_FEEMONTH c on b.query_accumulator_id = c.query_accumulator_id 
where a.eff_date like '{yyyy-mm}%%'
--a.eff_date = '2012-04-01 00:00:00'
;

select distinct b.serv_id,b.acc_nbr,b.mkt_grid_id,a.* into temp ryt_flow_taoc_FEEMONTH 
from ryt_tc_all a ,DS_CHN_PRD_SERV_MKT_AREA_FEEMONTH b 
where a.owner_id = b.serv_id and a.���� like 'MB' and b.product_id = '208511296' and b.state = '00A' and b.serv_state = '2HA';


select distinct a.*,sum(b.��ʼֵ)/1024 start_values,sum(b.ʹ����)/1024 used_values,sum(b.ʣ����)/1024 unused_values into temp ryt6
from ryt5 a left outer join ryt_flow_taoc_FEEMONTH b
on a.serv_id = b.serv_id group by 1,2,3,4,5,6,7,8,9,10;


--3G�û��嵥

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select mkt_area_name,mkt_channel_name,mkt_grid_name,serv_id,acc_nbr,type,smart_flag,active_flag,flow,new_flag,start_values,used_values,unused_values 
--into temp ryt_3g_AREA_FEEMONTH
from ryt6;

/* ͳ�Ʒ��ڵ��ӱ�����Լ��ֹ�����������
--C�������û�
select a.serv_id,b.mkt_area_name,b.MKT_CHANNEL_NAME into temp ryt_acct_c
from DS_CHN_PRD_SERV_MKT_AREA_FEEMONTH a,dim_zone_area b
where a.mkt_grid_id = b.mkt_grid_id and a.ACCT_SERV_FLAG = 1 and a.product_id = 208511296;
-- update ryt_acct_c set mkt_area_name = '����' where mkt_area_name like '%%�ᶼ%%'; update ryt_acct_c set mkt_area_name = '�ᶼ' where mkt_area_name like '%%��ʢ%%';


--------------ͳ��FEEMONTH--------------
select mkt_area_name �ֹ�˾,mkt_channel_name Ӫά��,mkt_grid_name ��������,serv_id,acc_nbr �û��绰����,type �ն��ͺ�,smart_flag ���ܻ���ʶ,active_flag ��Ծ��ʶ,new_flag ����������ʶ,flow ����EVDO����,start_values �ײ�������ʼֵ,used_values �ײ�����ʹ����,unused_values �ײ�����ʣ����
from ryt_3g_AREA_FEEMONTH where mkt_area_name like '%%�ᶼ%%' order by 1,2; --3G�û��嵥


--ȫ���û�
select count(distinct serv_id),sum(flow) from ryt_3g_AREA_FEEMONTH; --3Gȫ���û�,evdo����
select count(active_flag) from ryt_3g_AREA_FEEMONTH where active_flag = 1; --��Ծ�û���
select count(active_flag) from ryt_3g_AREA_FEEMONTH where active_flag = 0; --��Ĭ�û���

--���ܻ��û�
select count(distinct serv_id),sum(flow) from ryt_3g_AREA_FEEMONTH where smart_flag = 1; --3Gȫ���û�,evdo����
select count(active_flag) from ryt_3g_AREA_FEEMONTH where active_flag = 1 and smart_flag = 1; --��Ծ�û���
select count(active_flag) from ryt_3g_AREA_FEEMONTH where active_flag = 0 and smart_flag = 1; --��Ĭ�û���

--�����û�
select count(distinct serv_id),sum(flow) from ryt_3g_AREA_FEEMONTH where new_flag is not null; --3Gȫ���û�,evdo����
select count(active_flag) from ryt_3g_AREA_FEEMONTH where active_flag = 1 and new_flag is not null; --��Ծ�û���
select count(active_flag) from ryt_3g_AREA_FEEMONTH where active_flag = 0 and new_flag is not null; --��Ĭ�û���


--�����ֶ�
select count(*),0 from ryt_3g_AREA_FEEMONTH where flow = 0 group by 2 union
select count(*),1 from ryt_3g_AREA_FEEMONTH where flow > 0 and flow <1 group by 2 union
select count(*),2 from ryt_3g_AREA_FEEMONTH where flow >= 1 and flow <5 group by 2 union
select count(*),3 from ryt_3g_AREA_FEEMONTH where flow >= 5 and flow <30 group by 2 union
select count(*),4 from ryt_3g_AREA_FEEMONTH where flow >= 30 and flow <100 group by 2 union
select count(*),5 from ryt_3g_AREA_FEEMONTH where flow >= 100 and flow <500 group by 2 union
select count(*),6 from ryt_3g_AREA_FEEMONTH where flow >= 500
 order by 2;

--���ܻ������ֶ�
select count(*),0 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow = 0 group by 2 union
select count(*),1 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow > 0 and flow <1 group by 2 union
select count(*),2 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow >= 1 and flow <5 group by 2 union
select count(*),3 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow >= 5 and flow <30 group by 2 union
select count(*),4 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow >= 30 and flow <100 group by 2 union
select count(*),5 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow >= 100 and flow <500 group by 2 union
select count(*),6 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and flow >= 500
 order by 2;
 

-----------------------�ֹ�˾ͳ��---------------------
drop table if exists qij_1;
drop table if exists qij_2;
drop table if exists qij_3;
drop table if exists qij_4;
drop table if exists qij_5;
drop table if exists qij_6;
drop table if exists qij_7;
drop table if exists qij_8;
drop table if exists qij_9;
drop table if exists qij_10;
drop table if exists qij_11;
drop table if exists qij_12;

select mkt_area_name �ֹ�˾,MKT_CHANNEL_NAME Ӫά��,count(distinct serv_id) �ֻ������� into temp qij_1 from ryt_acct_c where mkt_area_name like '%%�ᶼ%%' group by 1,2 order by 1,2; --C�������û�

select mkt_area_name �ֹ�˾,MKT_CHANNEL_NAME Ӫά��,count(distinct serv_id) ��G�û�������,sum(flow) ��G�û�evdo�����ϼ� into temp qij_2 from ryt_3g_AREA_FEEMONTH where mkt_area_name like '%%�ᶼ%%' group by 1,2 order by 1,2; --3Gȫ���û�,����

select mkt_area_name �ֹ�˾,MKT_CHANNEL_NAME Ӫά��,count(active_flag) ��G��Ծ�û��� into temp qij_3 from ryt_3g_AREA_FEEMONTH where active_flag = 1 and mkt_area_name like '%%�ᶼ%%' group by 1,2 order by 1,2; --3G��Ծ�û�

select mkt_area_name �ֹ�˾,MKT_CHANNEL_NAME Ӫά��,count(active_flag) ��G��Ĭ�û��� into temp qij_4 from ryt_3g_AREA_FEEMONTH where active_flag = 0 and mkt_area_name like '%%�ᶼ%%' group by 1,2 order by 1,2; --3G��Ĭ�û�

select mkt_area_name �ֹ�˾,MKT_CHANNEL_NAME Ӫά��,count(distinct serv_id) ���ܻ�������,sum(flow) ���ܻ��û�evdo�����ϼ� into temp qij_5 from ryt_3g_AREA_FEEMONTH where smart_flag = 1 and mkt_area_name like '%%�ᶼ%%' group by 1,2 order by 1,2; --���ܻ�ȫ���û�,evdo����

select mkt_area_name �ֹ�˾,MKT_CHANNEL_NAME Ӫά��,count(active_flag) ���ܻ���Ծ�û��� into temp qij_6 from ryt_3g_AREA_FEEMONTH where active_flag = 1 and smart_flag = 1 and mkt_area_name like '%%�ᶼ%%' group by 1,2 order by 1,2; --���ܻ���Ծ�û�

select mkt_area_name �ֹ�˾,MKT_CHANNEL_NAME Ӫά��,count(active_flag) ���ܻ���Ĭ�û��� into temp qij_7 from ryt_3g_AREA_FEEMONTH where active_flag = 0 and smart_flag = 1 and mkt_area_name like '%%�ᶼ%%' group by 1,2 order by 1,2; --���ܻ���Ĭ�û�

select a.�ֹ�˾,a.Ӫά��,a.��G�û�������-b.���ܻ������� �����ܻ�������,a.��G�û�evdo�����ϼ�-b.���ܻ��û�evdo�����ϼ� �����ܻ��û�evdo�����ϼ� into temp qij_8 from qij_2 a,qij_5 b where a.Ӫά��=b.Ӫά�� order by 1,2; --�����ܻ�ȫ���û�,evdo����

select a.�ֹ�˾,a.Ӫά��,a.��G��Ծ�û���-b.���ܻ���Ծ�û��� �����ܻ���Ծ�û�,c.��G��Ĭ�û���-d.���ܻ���Ĭ�û��� �����ܻ���Ĭ�û� into temp qij_9 from qij_3 a,qij_6 b,qij_4 c,qij_7 d where a.Ӫά��=b.Ӫά�� and a.Ӫά��=c.Ӫά�� and a.Ӫά��=d.Ӫά�� order by 1,2; --�����ܻ���Ծ�û�,�����ܻ���Ĭ�û�

select mkt_area_name �ֹ�˾,MKT_CHANNEL_NAME Ӫά��,count(distinct serv_id) ����������G�û���,sum(flow) ����������G�û�evdo�����ϼ� into temp qij_10 from ryt_3g_AREA_FEEMONTH where new_flag is not null and mkt_area_name like '%%�ᶼ%%' group by 1,2 order by 1,2; --��������3G�û�,����

select mkt_area_name �ֹ�˾,MKT_CHANNEL_NAME Ӫά��,count(active_flag) ����������G��Ծ�û��� into temp qij_11 from ryt_3g_AREA_FEEMONTH where active_flag = 1 and new_flag is not null and mkt_area_name like '%%�ᶼ%%' group by 1,2 order by 1,2; --��������3G��Ծ�û�

select mkt_area_name �ֹ�˾,MKT_CHANNEL_NAME Ӫά��,count(active_flag) ����������G��Ĭ�û��� into temp qij_12 from ryt_3g_AREA_FEEMONTH where active_flag = 0 and new_flag is not null and mkt_area_name like '%%�ᶼ%%' group by 1,2 order by 1,2; --��������3G��Ĭ�û�

select mkt_area_name �ֹ�˾,MKT_CHANNEL_NAME Ӫά��,count(distinct serv_id) �����������ܻ��û���,sum(flow) �����������ܻ��û�evdo�����ϼ� from ryt_3g_AREA_FEEMONTH where new_flag is not null and smart_flag = 1 and mkt_area_name like '%%�ᶼ%%' group by 1,2 order by 1,2; --�����������ܻ�(���ڿ�������)

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

------�ϲ�-----------
        select a.�ֹ�˾,
               a.Ӫά��,
               a.�ֻ�������,
               b.��G�û�������,
               c.��G��Ծ�û���,
               d.��G��Ĭ�û���,
               b.��G�û�evdo�����ϼ�,
               e.���ܻ�������,
               f.���ܻ���Ծ�û���,
               g.���ܻ���Ĭ�û���,
               e.���ܻ��û�evdo�����ϼ�,
               h.�����ܻ�������,
               i.�����ܻ���Ծ�û�,
               i.�����ܻ���Ĭ�û�,
               h.�����ܻ��û�evdo�����ϼ�,
               j.����������G�û���,
               k.����������G��Ծ�û���,
               l.����������G��Ĭ�û���,
               j.����������G�û�evdo�����ϼ�
               from qij_1 a 
               left join qij_2 b on a.Ӫά��=b.Ӫά��
               left join qij_3 c on a.Ӫά��=c.Ӫά��
               left join qij_4 d on a.Ӫά��=d.Ӫά��
               left join qij_5 e on a.Ӫά��=e.Ӫά��
               left join qij_6 f on a.Ӫά��=f.Ӫά��
               left join qij_7 g on a.Ӫά��=g.Ӫά��
               left join qij_8 h on a.Ӫά��=h.Ӫά��
               left join qij_9 i on a.Ӫά��=i.Ӫά��
               left join qij_10 j on a.Ӫά��=j.Ӫά��
               left join qij_11 k on a.Ӫά��=k.Ӫά��
               left join qij_12 l on a.Ӫά��=l.Ӫά��
               and a.�ֹ�˾ like '%%�ᶼ%%';

*/
select '33';
--* from tmp_g2_AREA_201110;
