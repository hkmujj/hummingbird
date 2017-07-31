
select distinct OFFER_COMP_TYPE_DESC6 六级套餐名称,用户数,欠费月份,金额 from
(
select                                                                                           
          t3.offer_comp_type_id6                                                                           
          ,t3.OFFER_COMP_TYPE_DESC6  
          ,(214-BILLING_CYCLE_ID)  欠费月份
          ,count(t3.OFFER_COMP_TYPE_DESC6 ) 用户数                                                                                  
          ,sum(t5.AMOUNT)    金额                                                  
                                                                                         
from                                                                                                        
        DS_CHN_PRD_SERV_44_201107  t1                                                                       
        ,DS_CHN_PRD_OFFER_COMP_201107          t2                                                           
        ,DIM_WD_OFFER_NEW_DIR_SECOND           t3 
        ,     DIM_CRM_PRODUCT_OFFER     t4         
        ,DM_ACT_OWE_ITEM_201107   t5                                     
where   t2.comp_offer_id=t3.offer_comp_type_id6                                                             
         and t1.serv_id=t2.serv_id  
         --and t1.active_serv_flag =0
         and t2.comp_offer_id=t4.offer_id 
         and t4.state='00A'
         and t4.offer_kind ='C'
         and t1.serv_id=t5.serv_id
          group by                                                                                       
          t3.offer_comp_type_id6                                                                           
          ,t3.OFFER_COMP_TYPE_DESC6 
          , BILLING_CYCLE_ID
          order by 欠费月份
) a
where 欠费月份>0
order by 2 desc limit 10
