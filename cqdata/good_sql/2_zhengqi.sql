--��ȡ���ɱ�������ͻ�Ⱥ�ĸ���,��ͥ�ͻ��嵥,Ӫ���ͻ�(��ͬ��)
--���ű���ִ��ʱ����10������
--��ȡ˼·��֤������Ϊ���֤����ս�Է�ȺΪ����ͻ���
--�������ʵ���,�������Żݺ����ȡ����, �Ա㷢����Ӫά��ȷ��ʱ,Ӫά���ص�Է��ýϸߵĿͻ����к˶�,�ų�����ȷϵ�����֤�Ǽǵ�����ͻ���.
--����,�ų��Ļ�,��Ӧ�ø��ݿͻ������ĳ�������,���ֹ��ų�һ��.һ�����3�����ֵĶ���Ӧ�޸�,�����˸���ͻ��������淶�����´���3������.
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select a.mkt_cust_code, a.mkt_cust_name, cust_certificate_type, 
cust_certificate_no, cust_address, cust_grp_type, deputy_acc_nbr
,sum(b.amount), count(*)
from DS_CHN_PRD_CUST_AREA_FEEMONTH a
left join ds_chn_prd_serv_AREA_FEEMONTH ab on a.mkt_cust_code=ab.mkt_cust_code
left join DS_ACT_ACCT_ITEM_FEEMONTH b on ab.serv_id=b.serv_id
where cust_certificate_type=10   --֤������Ϊ���֤
and CUST_GRP_TYPE=10  --�ͻ�ȺΪ����ͻ�
group by 1,2,3,4,5,6,7
order by sum desc;
select '33';
--* from tmp_g2_33_201110;
