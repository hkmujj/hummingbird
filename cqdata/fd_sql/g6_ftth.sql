--��ֹ�˾FTTH�豸�嵥
--���ű���ִ��ʱ����10������
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select acc_nbr �û��绰����, user_name �û�����, prod_addr �û���ַ, a.state �û�״̬, serv_state �豸״̬, down_velocity ���д���, serv_num ������, mkt_cust_code ��ͬ��, mdf_code ���߼ܱ���, jjx_code ���������, fxh_code ���ߺб���, com.com_channel_name ά��Ӫά��, com.com_grid_name ά������, pro.product_name �ļ���Ʒ����

,case when rule_type='000' then '����·����'  when rule_type='001' then '������'  when rule_type='002' then '���߼�'  when rule_type='003' then '���ߺ�'  when rule_type='004' then 'CRMĸ��'  when rule_type='005' then 'GIS��վ'  when rule_type='006' then 'С������'  when rule_type='007' then '��·�û��Ŷι���'  when rule_type='008' then 'CRM��վ'  when rule_type='009' then '������'  when rule_type='010' then '�ۺ�������' end  ά������·�������

from 
ds_chn_prd_serv_com_AREA_FEEMONTH a
left join 
 DM_EVT_ALL_SERV_ACCESS_MODE_FEEMONTH b on a.serv_id=b.prodinscode
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
left join dim_crm_product pro on a.product_id=pro.product_id
--where a.acc_nbr in ('023-70708080','023-70701899')
where b.accessmode=2
--limit 10
;

select '33';
--* from tmp_g2_33_201110;

