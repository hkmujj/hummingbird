--规范名称过短的政企客户资料
--本脚本的执行时间在10秒左右
--提取战略客户群为政企客户,但客户名称长度小于4个汉字的客户清单
--此处为提取营销客户及名称,对应CRM中的帐户及帐户名称.修改时应同时关注产权客户及名称.
--以下记需要清理的内容:
--营销客户 政企但姓名小于4个汉字的 公众但姓名大于3个汉字的
--产权客户 同上
--产权客户 政企但证件类型为身份证的(待重庆更正此次提交的一部分后) 公众但类型为介绍信 公章的
drop table if exists tmp_PACKGE_NAME_AREA_FEEMONTH;
create table tmp_PACKGE_NAME_AREA_FEEMONTH as 
select a.mkt_cust_code, a.mkt_cust_name, cust_certificate_type, 
cust_certificate_no, cust_address, cust_grp_type, deputy_acc_nbr
--,sum(b.amount), count(*)
from DS_CHN_PRD_CUST_AREA_FEEMONTH a
--left join ds_chn_prd_serv_AREA_FEEMONTH ab on a.mkt_cust_code=ab.mkt_cust_code
--left join DS_ACT_ACCT_ITEM_FEEMONTH b on ab.serv_id=b.serv_id
where 
length(mkt_cust_name)<4
--cust_certificate_type=10   --证件类型为身份证
and CUST_GRP_TYPE=10  --客户群为政企客户
and deputy_acc_nbr<>-99
--group by 1,2,3,4,5,6,7
--order by sum desc
;
select '33';
--* from tmp_g2_33_201110;
