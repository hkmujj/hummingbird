-- 丰都e9手机清单--专题

drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select distinct a.*
--,inst.acc_nbr adsl_new
--,b.offer_comp_id, prod_offer_id 
,c.offer_name
--, c_prod.offer_name prod_name
--,0.0 score
,phone.enable_flag, phone.intell_flag
--, user_postn_arrive_num
--,term.imei, term.factory, term.type
from 
(
select distinct a.*, b.offer_comp_id
, offer_comp_instance_id
--, prod_offer_inst_id

--, b.prod_offer_id
from      (
select distinct a.acc_nbr, user_name, a.com_grid_id
--, jjx_code, user_grp_type
--, down_velocity
,  completed_date
--, remove_date
, a.serv_id 
, com.com_channel_name, com.com_grid_name, a.mkt_cust_code
, b.group_id, b.member_role_id --群id, 群成员类型
from ds_chn_prd_serv_com_AREA_LAST_DAY a
left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
left join dm_prd_crm_service_grp_member b on a.serv_id=b.serv_id
and b.member_role_id in ('80','36','62')
where  
serv_num=1
and 
product_id=208511296
--and completed_date >='2012-01-01'
   ) a
left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id 
and b.prod_offer_inst_state='00A'
 where  b.offer_comp_id in ( 
	--e9手机的话,需要增加以下方案: e家共享包, 全话费119,全话费149
331494  --e家手机共享包全话费版
,319290
--13388962056	全业务手机共享包5元/月/部（立即生效）,全家乐（e9）套餐2M不限时99元套餐（区县）（老）,手机固话村级V网	319290,321655,315656	全业务手机共享包5元/月/部（立即生效）_基础包,全家乐（e9）套餐2M不限时99元套餐（区县）（老）_基础包,vpn虚拟群(网内免费)群号1-1000000部分CDMA
,331516	--92790330	None	新e9-4M不限时119套餐
,328071	--90655518	None	e家手机共享包
,331488	--90792107	None	新e9-4M不限时149套餐（全话费版）
,331517	--新e9-4M不限时119套餐_基础包
,328072	--e家手机共享包_基础包
,331489	--新e9-4M不限时149套餐（全话费版）_基础包
,331495	--e家手机共享包（全话费版）_基础包
,325498	--全家翼起来e9-ADSL2M不限时99套餐_基础包
,331508	--新e9-4M不限时119套餐（全话费版）_基础包
,331507  --新e9-4M不限时119套餐（全话费版）
--,330675 --承诺消费119元提速1M
--,330398 --承诺消费119元提速2M
--,330677 --承诺消费119元提速3M
,331488 --新e9-4M不限时149套餐（全话费版）
--,329628 --新e9-4M不限时119套餐
--,331516 --描述与329628一样...
,324806	--全家乐（e9）套餐2M不限时99元套餐（区县）_基础包
,324805	--324806	全家乐（e9）套餐2M不限时99元套餐（区县）_基础包
,325497	--全家翼起来e9-ADSL2M不限时99套餐_基础包
,329628	--新e9-4M不限时119套餐_基础包
,329639	--新e9-4M不限时189套餐（含iTV）_基础包
,324805	--全家乐（e9）套餐2M不限时99元套餐（区县）_基础包
,276905	--新e9套餐2M不限时99元套餐（区县）_基础包
,316905	--新e9套餐2M不限时99元套餐（区县）_基础包
,325468	--全家翼起来e9-ADSL1M不限时79套餐_基础包
,321655	--全家乐（e9）套餐2M不限时99元套餐（区县）（老）_基础包
,316901	--新e9套餐1M不限时89元套餐（区县）_基础包
,327977	--327978	我的e家e6-66套餐_基础包
,327987	--327988	我的e家e6-96 套餐_基础包

 )
   ) a
left join dim_crm_product_offer c on a.offer_comp_id=c.offer_id 
--left join dim_crm_product_offer c_prod on a.prod_offer_id=c_prod.offer_id 
--order by a.acc_nbr
--distribute by acc_nbr
--关联3G智能机表以取得3G和智能机标识
left join DS_PRD_SERV_3G_LAST_DAY phone on a.serv_id=phone.serv_id
;
--重新通过建临时表来查询该手机的最新串码信息
create temp table temp1 as 
select a.*, term.* from tmp_PACKGE_NAME_AREA_FEEMONTH a
left join 

(select a.acc_nbr ter_acc, b.type, b.esn from 
(select acc_nbr , max(register_time) reg from ds_evt_terminal_info_all_ry term where acc_nbr in (select acc_nbr from tmp_PACKGE_NAME_AREA_FEEMONTH) group by 1) a left join ds_evt_terminal_info_all_ry b on a.acc_nbr=b.acc_nbr and a.reg=b.register_time )
 term 
on a.acc_nbr=term.ter_acc
;

--将此部分号码涉及的商品实例的受理单先提出来滤重
create temp table temp2_accept as 
select * from dm_evt_sr_accept where offer_comp_instance_id in 
(select offer_comp_instance_id from temp1) and service_id=20000;

create temp table temp3_accept_max as  
select offer_comp_instance_id, max(produce_id) produce_id from temp2_accept group by 1;

create temp table temp3_accept as 
select b.* from temp3_accept_max a left join temp2_accept b on 
a.offer_comp_instance_id=b.offer_comp_instance_id and a.produce_id=b.produce_id;

create temp table temp2 as 
select distinct a.*, b.oper_id, b.terminal_ip --, b.atime
,t8.staff_desc,t8.staff_code
from temp1 a
left join temp3_accept b on 
--a.serv_id=b.serv_id and 
--b.service_id=20000 --售卖
--and 
a.offer_comp_instance_id = b.offer_comp_instance_id
--and 
--a.prod_offer_inst_id = b.product_offer_instance_id
left join DIM_CRM_STAFF t8 on b.OPER_ID=t8.PARTY_ROLE_ID  --关联到受理人名称
;
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as select distinct * from temp2;
drop table temp1;
select '33';
--* from tmp_g2_33_201110;
--20120510 增加提取group_id,和member_role_id(群id,和群成员类型)
