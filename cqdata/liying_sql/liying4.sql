--C����������嵥
--������ȡ�ò��ֺ�����ײ����

drop table if exists tmp_PACKGE_NAME_{area}_{yyyymm};
create table tmp_PACKGE_NAME_{area}_{yyyymm} as 
select acc_nbr, remove_date from ds_chn_prd_serv_mkt_{area}_{yyyymm}
where remove_date like '{yyyy-mm}%%' and product_id=208511296  ;

select '33';
--* from tmp_g2_33_201110;
