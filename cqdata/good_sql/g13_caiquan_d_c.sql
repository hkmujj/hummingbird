-- ͬ��Ȩ�ͻ�����AD,��δ��C�ϻ���
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
-- 
--��ͬ��Ȩ�ͻ������ֻ���δ���ʵĿ���嵥
select a.acc_nbr �������,
a.down_velocity ����, mkt_channel_name Ӫ��_Ӫά��, mkt_grid_name Ӫ������,
com_channel_name ά��_Ӫά��, com_grid_name ά������, c.acc_nbr �ֻ�����, c.billing_mode_id ���ѷ�ʽ, a.cust_id ��Ȩ�ͻ�ID, a.mkt_cust_code �����ͬ��, c.mkt_cust_code �ֻ���ͬ�� from ds_chn_prd_serv_33_201211 a 
left join DS_CHN_PRD_CUST_33_201211 b on a.mkt_cust_code=b.mkt_cust_code
left join ds_chn_prd_serv_33_201211 c on a.cust_id=c.cust_id and c.product_id=208511296 and c.serv_num=1
left join DIM_ZONE_area area on a.mkt_grid_id=area.mkt_grid_id 
left join dim_zone_comm comm on a.com_grid_id=comm.com_grid_id 

where a.product_id='102030001' and a.serv_num=1
 and b.user_mobile_arrive_num=0  --��ͬ����C���豸������Ϊ0
 and c.billing_mode_id=1  --�ֻ����ѷ�ʽΪ��
order by 1
limit 5000
;

select '33';

