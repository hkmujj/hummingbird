--����4M����嵥
--���ݼ�����ȿ����
--��ֹ�˾��Ӫά��4M���ռ��
--���ű���ִ��ʱ����10������
--1���ܱ�
--�ֹ�˾���Լ��ֹ�˾4M�û�����ռ�Լ��ֹ�˾���п���û���ռ��
--2��	�嵥��
--��ʽ���ֹ�˾��4M���ҵ����롢�����C����Ʒ����ȡ�ײ���Чʱ�������һ����
--����ȡ��ά����
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
drop table if exists tab_4m_all;
select a.serv_id, a.acc_nbr,a.prod_addr, a.user_name, b.com_channel_name, b.com_grid_name, down_velocity, jjx_code ���������
,a.product_id, pro.product_name

  into temp tab_4m_all
  from DS_CHN_PRD_SERV_com_AREA_{yyyymm} a
  left join DIM_ZONE_comm b
    on (a.com_GRID_ID = b.com_GRID_ID)
left join dim_product pro on a.product_id=pro.product_id

where a.PRODUCT_ID in (
--102010002 --ADSLר��
102030001 --ADSLע���鲦����
,102030002 --LANע���鲦����
)   and a.SERV_NUM = 1
   and a.DOWN_VELOCITY in ('512K','640K','1M','1.5M','2M', '2.5M','3M');
--select count(*) from tab_4m_all;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select a.*, b.offer_name comp_name,c.offer_name from tab_4m_all a left join 
(select serv_id, pg_concat(t3.offer_name||'\n') offer_name from ds_prd_offer_comp_detail a
left join dim_crm_product_offer t3 on a.offer_comp_id=t3.offer_id
-- and t3.offer_kind='C'
where serv_id in (select serv_id from tab_4m_all) 
--and t3.state='00A'
and t3.offer_kind not in ('0') group by 1)
b on a.serv_id=b.serv_id and b.offer_name not in (
	'ȫ���������������1M'
,'ȫ�������������2M'
,'iTV���������298Ԫ���꣨E�ң�'
,'iTV���������28Ԫ���£���E��-���û���'
,'�̼����˿��20Ԫ����'
,'iTV�����Ա�������'
,'iTV���������28Ԫ���£�E��-���û���'
,'iTV���������298Ԫ���꣨��E�ң�'
,'������װT3����129�ײͣ���CDMA������Ч��'
,'T3����89�ײ�'
,'iTV����28Ԫ���£����ޣ������飩'
,'e6�ƶ��ؼ�46�ײͣ��Ϲ̻������ֻ���'
,'iTV��������300Ԫ����298Ԫ����B�棨���飩'
,'��E���û�itv��ǿ�����ײ�'
,'iTV���������28Ԫ���£�E�ң�'
,'iTV����298Ԫ���꣨���ޣ������飩'
,'iTV���������28Ԫ���£�E�ң�'
,'��ŵ����119Ԫ����1M'
,'��ŵ����119Ԫ����2M'
,'��ŵ����119Ԫ����3M'
,'09PC������¹�180Ԫ��24���£�'
,'iTV����298Ԫ���꣨���ޣ�'
,'iTV����20Ԫ���£�Ա���棩'
,'��AC-76�����߿��76Ԫ�����ײ�(������Ч)(��133/153)'
,'�ҵ�E���û�itv��ǿ�����ײ�'
,'�����캽�����ײͿ�����ٰ�'
,'��E���û�itv��ǿ�����ײ�(��װ���û�)'
,'ADSL�鲦Э��۵�Ԫ[ADSL�������]'
,'iTV����28Ԫ���£����ޣ�'
,'�ҵ�E���û�itv��ǿ�����ײ�(��װ���û�)'
,'iTV���������28Ԫ���£���E��-���û���'
,'��װ�����ŵ12����1��'
,'�ҵ�E���û�itv��ǿ�����ײ�(��װ���û�)'
,'iTV��������300Ԫ����298Ԫ����B��'
,'[AC-76]���߿��76Ԫ�����ײ�(���û�������Ч)(��'
,'[AC-76]���߿��76Ԫ�����ײ�(���û�������Ч)(��133/'
,'����ITV298Ԫ�����ײ�'
,'[122]�ᶼ�����Żݺ�����'
)
left join (select serv_id, pg_concat(t3.offer_name||'\n') offer_name from ds_prd_offer_comp_detail a
left join dim_crm_product_offer t3 on a.prod_offer_id=t3.offer_id
-- and t3.offer_kind='C'
where serv_id in (select serv_id from tab_4m_all) 
--and t3.state='00A'
and t3.offer_kind not in ('0') group by 1)
c on a.serv_id=c.serv_id

;

select '33';
--* from tmp_g2_33_201110;


