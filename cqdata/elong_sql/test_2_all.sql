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
select a.serv_id, a.acc_nbr,a.prod_addr, a.user_name, b.com_channel_name, b.com_grid_name, down_velocity
,a.product_id, pro.product_name

  into temp tab_4m_all
  from DS_CHN_PRD_SERV_com_AREA_FEEMONTH a
  left join DIM_ZONE_comm b
    on (a.com_GRID_ID = b.com_GRID_ID)
left join dim_product pro on a.product_id=pro.product_id

where a.PRODUCT_ID in (
--102010002 --ADSLר��
102030001 --ADSLע���鲦����
,102030002 --LANע���鲦����
)   and a.SERV_NUM = 1
   and a.DOWN_VELOCITY not in ('512K','640K','1M','1.5M','2M', '2.5M','3M');
--select count(*) from tab_4m_all;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select a.*, b.offer_name comp_name,c.offer_name from tab_4m_all a left join 
(select serv_id, pg_concat(t3.offer_name||'\n') offer_name from ds_prd_offer_comp_detail a
left join dim_crm_product_offer t3 on a.offer_comp_id=t3.offer_id
-- and t3.offer_kind='C'
where serv_id in (select serv_id from tab_4m_all) 
--and t3.state='00A'
and t3.offer_kind not in ('0') group by 1)
b on a.serv_id=b.serv_id
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

