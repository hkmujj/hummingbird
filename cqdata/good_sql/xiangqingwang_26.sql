--�������ֻ����ֻ��嵥
drop table if exists tmp_PACKGE_NAME_AREA_all;

create temp table tgm_26_{area} as 
select a.*, b.product_id, c.product_name, pag.offer_name, com.com_channel_name, com_grid_name
  from DS_CHN_PRD_OFFER_COMP_{yyyymm} a 
left join ds_chn_prd_serv_com_{area}_{yyyymm} b on a.serv_id=b.serv_id
left join dim_crm_product_offer pag on a.comp_offer_id=pag.offer_id
left join dim_product c on b.product_id=c.product_id
left join DIM_ZONE_COMM com on b.com_grid_id=com.com_grid_id
where 
a.com_area_id={area} and  a.comp_offer_id in (
276858, --	�ƶ��ؼ�26Ԫ�ײ���150���ӣ��ֻ��̻��棩
315968, --	[e6-11]26Ԫ��150���ӣ��¹̻�+���ֻ���[��153]
315997, --	[e6-11]26Ԫ��150���ӣ��¹̻�+���ֻ���[��133/153]
315998, --	[e6-11]26Ԫ��150���ӣ��Ϲ̻�+���ֻ���[��153]
315999, --	[e6-11]26Ԫ��150���ӣ��Ϲ̻�+���ֻ���[��133/153]
316003, --	[e6-11]26Ԫ��100���ӣ��Ϲ̻�+���ֻ���[��153]
316004, --	[e6-11]26Ԫ��100���ӣ��Ϲ̻�+���ֻ���[��133/153]
316005, --	[e6-11]36Ԫ��280���ӣ��¹̻�+���ֻ���[��153]
316007, --	[e6-11]36Ԫ��280���ӣ��Ϲ̻�+���ֻ���[��153]
316008, --	[e6-11]36Ԫ��280���ӣ��Ϲ̻�+���ֻ���[��133/153]
316065, --	[e6-11��ŵ12����]26Ԫ��150���ӣ��Ϲ̻�+���ֻ���[��
316067, --	[e6-11��ŵ12����]26Ԫ��150���ӣ��Ϲ̻�+���ֻ���[��
316868, --	�ƶ��ؼ�26Ԫ�ײ���150���ӣ��ֻ��̻�С��ͨ�棩
318303, --	�������ֻ��棭26�ײ͹���150����
318305, --	�������ֻ��棭36�ײ͹���280����
318306, --	�������ֻ��棭36�ײ͹���220����
321596, --	E6-11������26Ԫ�ײ�
321717, --	����ؼ�E6-26Ԫ�ײͣ��ֻ�+�̻������ϣ�
327818, --	����������26�ײ�
327822, --	����������18�ײ�
327844 --	����ؼ�26�ײ�
);

create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select  a.acc_nbr "26�ײ��ֻ�����", b.acc_nbr "26�ײ���������", a.comp_offer_id, a.offer_name, 
a.com_area_id �ֹ�˾, a.com_channel_name Ӫά��, a.com_grid_name ����, a.offer_eff_date ��Чʱ��,
to_char((a.offer_eff_date+interval '2 year -1 day'),'yyyy-mm-dd') ����ʱ��
  from tgm_26_{area} a 
left join tgm_26_{area} b on a.offer_comp_instance_id=b.offer_comp_instance_id and 
 b.product_name in ('��ͨ�绰','450M����绰')
where a.product_name='����CDMA' and a.offer_exp_date>'2020-01-01'
--��һ��, ����ͨ��׼ȷ�Ա�ʧЧʱ��, ��ȡ��ֹĳһ�µ���Ч�û�
limit 10000
;

select '33';


