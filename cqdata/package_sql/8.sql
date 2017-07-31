select distinct b.OFFER_COMP_TYPE_DESC1 一级套餐名称,count(distinct a.acc_nbr) 号码个数 from
(
select    t1.serv_id                                                                                        
          ,t1.acc_nbr                                                                                       
          ,t3.offer_comp_type_id6                                                                           
          ,t3.OFFER_COMP_TYPE_DESC6                                                                         
          ,t2.offer_eff_date                                                                                
          ,t2.offer_exp_date                                                                                
from                                                                                                        
        DS_CHN_PRD_SERV_44_201107  t1                       --改此处帐期                                                   
        ,DS_CHN_PRD_OFFER_COMP_201107          t2  --改此处帐期                                                         
        ,DIM_WD_OFFER_NEW_DIR_SECOND           t3 
        ,     DIM_CRM_PRODUCT_OFFER     t4                                                     
where   t2.comp_offer_id=t3.offer_comp_type_id6                                                             
         and t1.serv_id=t2.serv_id  
         and t1.active_serv_flag =0
         and t2.comp_offer_id=t4.offer_id 
         and t4.state='00A'
         and t4.offer_kind ='C'
         and t1.product_id in ('208511296','101010001')
) a,DIM_WD_OFFER_NEW_DIR_SECOND b 
where a.OFFER_COMP_TYPE_DESC6=b.OFFER_COMP_TYPE_DESC6
group by 1 order by 2 desc limit 10
