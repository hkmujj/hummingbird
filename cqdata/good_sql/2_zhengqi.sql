--提取怀疑被错划政企客户群的个人,家庭客户清单,营销客户(合同号)
--本脚本的执行时间在10秒左右
--提取思路：证件类型为身份证，但战略分群为政企客户的
--并关联帐单表,将当月优惠后费用取出来, 以便发给各营维部确认时,营维部重点对费用较高的客户进行核对,排除个别确系用身份证登记的政企客户的.
--另外,排除的话,还应该根据客户姓名的长度排序,再手工排除一次.一般大于3个汉字的都不应修改,但有人个别客户姓名不规范而导致大于3个汉字.
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select a.mkt_cust_code, a.mkt_cust_name, cust_certificate_type, 
cust_certificate_no, cust_address, cust_grp_type, deputy_acc_nbr
,sum(b.amount), count(*)
from DS_CHN_PRD_CUST_AREA_FEEMONTH a
left join ds_chn_prd_serv_AREA_FEEMONTH ab on a.mkt_cust_code=ab.mkt_cust_code
left join DS_ACT_ACCT_ITEM_FEEMONTH b on ab.serv_id=b.serv_id
where cust_certificate_type=10   --证件类型为身份证
and CUST_GRP_TYPE=10  --客户群为政企客户
group by 1,2,3,4,5,6,7
order by sum desc;
select '33';
--* from tmp_g2_33_201110;
