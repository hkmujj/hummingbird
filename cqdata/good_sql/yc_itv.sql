--iTV����IPTV(ADSL)����Ⱥ�ĺ���
--�ٲ����˼·
--���ű���ִ��ʱ����10������
--���������: 1.��iTV,���޶�ӦIPTV(ADSL)����Ⱥ
--2.��IPTV(ADSL)����Ⱥ,�������Աȱʧ
--3.û�п���iTVֱ�Ӽ�װ�ڹ̻��ϵ����
--���Ҫ����ά�������������,�뵼����Ϊ���ӱ���,��������ѯ��ȥ��ѯ��ճ��.û���ڴ�ҳһ��������Щ�ֶ�,��Ϊ�˱��ִ˴����ļ���.
--�Էᶼ,���������,����iTV�п����Ǽ�װ�ڹ̻��ϵ�,���̻�û�н�Ⱥ.��Ҫ����.

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select a.acc_nbr,b.group_id from ds_chn_prd_serv_AREA_FEEMONTH a 
left join dm_prd_crm_service_grp_member b on a.serv_id=b.serv_id and b.member_role_id = 1518  --iTV��Ա
left join dm_prd_crm_service_grp_member c on b.group_id=c.group_id and c.member_role_id in (1520,1519)  -- 1519:�����Ա 1520 �̻���Ա(�˴�����1)
where a.product_id=208511177  --iTV
and a.state='00A' and a.serv_state='2HA'
and a.serv_num=1
and c.group_id is null
limit 22210;

select '33';
--* from tmp_g2_33_201110;
