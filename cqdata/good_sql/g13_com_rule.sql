-- ͬ��Ȩ�ͻ�����AD,��δ��C�ϻ���
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
-- 
-- ͳ��ͬ��Ȩ�ͻ�������AD����C����C��ADδ�ϻ���AD�嵥
select a.serv_id,a.acc_nbr,a.product_id, a.mkt_cust_code,b.mkt_cust_code,a.completed_date
,b.user_mobile_arrive_num
--,b.*
 from ds_chn_prd_serv_33_201211 a
left join DS_CHN_PRD_CUST_33_201211 b on a.mkt_cust_code=b.mkt_cust_code
where product_id='102030001' and serv_num=1 
and b.user_mobile_arrive_num=0
and cust_id in (select distinct cust_id from ds_chn_prd_serv_33_201211 where product_id=208511296)
;

/*102030001
cust_id
208511296
*/
;
select '33';

