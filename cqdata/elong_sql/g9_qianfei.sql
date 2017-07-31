--营销营维部欠费查询
--淼哥友请提供SQL语句

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 

select t3.mkt_channel_name 营销营维部,
     (sum(t4.amount)/10000-sum(case when t4.pseudo_flag='1' then t4.amount else 0 end)/10000)::float 列收欠费,
     (sum(case when t4.pseudo_flag='1' then t4.amount else 0 end)/10000)::float 不列收欠费,
     (sum(t4.amount)/10000)::float 总欠费,     
     (sum(balance_paid)/10000)::float 余额冲帐 from 
        (select
          t1.serv_id, 
          t1.acc_nbr,
         t1.mkt_area_id,
	t2.mkt_area_name,
          t2.mkt_channel_name,
          t2.mkt_region_name,
          t2.mkt_grid_name
            from ds_chn_prd_serv_AREA_LAST_DAY t1 
            left join dim_zone_area t2 on t1.mkt_grid_id=t2.mkt_grid_id 
            where t1.mkt_area_id='AREA') t3 
            inner join dm_act_owe_item t4 on t3.serv_id=t4.serv_id  
            inner join ds_act_acct_LAST_DAY t5 on t4.acct_id=t5.acct_id
      
          group by t3.mkt_channel_name
;
select '33';
--* from tmp_g2_33_201110;

