-- ��Ĭ�û�(����)�嵥

-- ��ȡ����: �û�����,�����־Ϊ1, ����Ծ��־Ϊ0���ֻ��嵥, Ȼ�����������Ϣ,��������, �Ż���Ϣ��, ��Ӫά������Ҫ��

--drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
--create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
drop table if exists tgm_ls;
create temp table tgm_ls as 
select acc_nbr,a.serv_id, user_name
--, a.com_grid_id, jjx_code, user_grp_type
--, down_velocity
,  completed_date
--, remove_date, serv_id 
, com.com_channel_name, com.com_grid_name, a.mkt_cust_code
from ds_chn_prd_serv_com_33_201205 a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
where  serv_num=1
and product_id=208511296 
and active_serv_flag=0
;

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select a.*, pg_concat( distinct c.offer_name||',') comp_name
--,pg_concat(c.offer_name||',') c_name
,pg_concat(distinct d.offer_comp_type_desc4||',') �ļ��ײ�
from tgm_ls a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='00A' 
left join dim_crm_product_offer c on b.offer_comp_id=c.offer_id
--and chh.base_flag=1
-- and t3.offer_kind='C'
--and t3.offer_kind not in ('0')
left join DIM_WD_OFFER_NEW_DIR_SECOND d on b.offer_comp_id=d.offer_comp_type_id6
and (d.offer_comp_type_desc4 not in ('�ƶ��Ż��ײ�','�ֻ����������ڣ�','���߿���ײͣ�T2)','�����ײ�','����ײ�','����Խ������ȣ�','���Լ������ײ�','С��ͨ�Ż��ײ�1','�ܻ�����','С��ͨ�Ż��ײ�2','��ͥ����ײ�','��������','�����ƶ��ײ�','�ۺϰ칫-������')
	or (d.offer_comp_type_desc4='��ͥ����ײ�' and c.offer_name like 'ȫ��������%%%%' and c.offer_name not like 'ȫ����������ŵ����%%%%')
	or (d.offer_comp_type_desc4='�����ƶ��ײ�' and c.offer_name not in ('[IVPN]���ڳ�Ա�������','�����캽�����ֻ��ײ�39����','�����캽�����ײͿ�����ٰ�','[IVPN]���ڳ�Ա������ѣ�OCS��','�����Ź��³�ŵ����100Ԫ������D280'))
	)
and c.offer_name not in ('�����캽���X��','�����캽���X���Ż�')
where d.base_flag=1
--�����ײ�Ŀ¼ά��
group by acc_nbr,a.serv_id, user_name
,  completed_date
, com_channel_name, com_grid_name, mkt_cust_code

;

drop table if exists tgm_ls;

select '33';
--* from tmp_g2_33_201110;

