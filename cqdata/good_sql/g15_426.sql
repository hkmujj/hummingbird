 -- 426����嵥, ֻȡʧЧ���ڴ��ڵ�ʱ��
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select day_id ��ȡ����, acc_nbr ����, cust_name �ͻ�����, cust_code �ͻ�����, offer_eff_date ��Ч����, offer_exp_date ʧЧ����, offer_completed_date ��������
, comp_enable_flag �ײ͵�����, comp_serv_enable_flag �ײ��û�������
 from latn_33_offer where comp_offer_id=121244 and offer_exp_date>now()
 order by offer_exp_date desc; 
 --select * from  tmp_PACKGE_NAME_AREA_FEEMONTH;
select '33';

