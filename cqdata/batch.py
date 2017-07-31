# -*- coding: utf-8 -*-
# $Header: D:\\RCS\\D\\python_study\\cherrypy\\forum\\__init__.py,v 1.0 2011-10-08 22:54:04+08 administrator Exp administrator $
import sqlite3, os, chardet, MySQL, cherrypy, cgi, sys, xlrd, time, datetime, traceback, my_tools, config, dbapi, MySQLdb
from HTMLTags import TR, TD, INPUT, SELECT, OPTION
name = '批量即席查询'
__all__ = ['batch1', 'batch1_mon',  'batch1_pstn', 'batch1_ad', 'batch1_pstn_ad', 'batch2', 'batch2_all', 'batch2_ivpn', 'batch2_ivpn_8',  
		'batch3', 'batch4', 'batch4_muti', 'batch4_base', 'batch4_base_month', 'batch4_base_detail', 'batch5', 'batch5_serv_fd', 'batch5_con', 'batch5_con_con', 'batch5_con_mid', 'batch5_con_fd', 'batch5_con_pay', 'batch5_con_balan',
		'batch4_c','batch4_c_lost', 'batch4_adsl', 'batch6', 'batch7', 'batch7_msg', 'batch8', 'batch_cust', 'batch_cust2acc', \
		'batch_uim', 'batch_byte', 'batch_byte_all', 'batch_byte_tc', 'batch_esn', 'batch_esn_last', 'batch_esn_acc', 'batch_esn_acc_first', 'batch_esn_xxx', 'batch_zk1', 'batch_ht', 'batch_owe', 'batch_staff', 'batch_balance' , 'batch_imp']

def header(forum_url=".",url='',**kw):
	'''论坛页眉,公用先调用的函数, 可以只在此处检查是否登录,而不用对每一个需要发布的函数都检查登录情况'''

	if 'fengongshi' in kw or cherrypy.session.get('fengongshi','')=='':
		cherrypy.session['fengongshi'] = str(kw.get('fengongshi','33')) or '33'
		raise cherrypy.HTTPRedirect(cherrypy.url().decode('utf-8'))
	init_days = 0	# 此处设置次月几日才出帐
	fee_month = int((datetime.datetime.now()+datetime.timedelta(days=-init_days)).strftime('%Y%m'))-1
	fee_month = fee_month % 100 and str(fee_month) or str(fee_month-88)
	if 'feemonth' in kw or cherrypy.session.get('feemonth','')=='':
		cherrypy.session['feemonth'] = str(kw.get('feemonth',fee_month)) or fee_month
		raise cherrypy.HTTPRedirect(cherrypy.url().decode('utf-8'))
	yield '<html><head><title>数据集市</title><script language="JavaScript" src="/static_files/calendar.js"></script><link rel="Stylesheet" href="/static_files/k_base.css"></link></head><body>\n'
	yield '<form style="display:inline" name="form0" ><select name=fengongshi onchange="document.form0.submit()">'
	s_name, s_id = config.dict_name.values(), config.dict_name.keys()
	yield '%s' % OPTION(s_name, value=s_id, selected=cherrypy.session.setdefault('fengongshi',''))
	yield '</select></form>'
	yield '<form style="display:inline" name="form1" ><select name=feemonth onchange="document.form1.submit()">'
	months = []
	#months += map(lambda x:'2013'+('0'+str(x))[-2:], range(1,13))
	months += map(lambda x:'2014'+('0'+str(x))[-2:], range(1,13))
	months += map(lambda x:'2015'+('0'+str(x))[-2:], range(1,13))
	months += map(lambda x:'2016'+('0'+str(x))[-2:], range(1,13))
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-0)).strftime('%Y%m')
	if ymd in months:
		index = months.index(ymd)
		months = months[:index+1]
	s_name, s_id = months,months
	yield '%s' % OPTION(s_name, value=s_id, selected=cherrypy.session.setdefault('feemonth',fee_month))
	yield '</select></form>'
	yield '<a href="..">上级</a> | <a href="%s">返回首页</a>' % forum_url
	for col in globals()['__all__']:
		#yield ' | <a href="%s">%s</a>' % (col, getattr(globals()[col],'__doc__',col))
		yield url<>col and ' | <a href="%s">%s</a>' % (col, getattr(globals()[col], '__doc__', col)) or ' | %s' % getattr(globals()[col], '__doc__', col)
		#yield url==col and ' | %s' % __all_name[__all__.index(col)] or ' | <a href="%s/%s">%s</a>' % (forum_url, col, __all_name[__all__.index(col)]
	yield '<hr />'

def footer():
	'''论坛页脚'''

	yield '\n</body></html>'

def index(**kw):
	'''论坛首页'''

	yield ''.join(header(**kw))
	yield '''本页是根据日常应用中的一些需求,将批量查询抽象为一个界面,可以一次查多个号码的相关信息,相当于营维系统导入查询的改进.
	1.号码网格等基本资料查询
	'''.replace('\n', '<br />\n')
	yield '%s' % globals().keys()
	yield '%s' % sys.modules[__name__]
	yield 'name: %s ' % __name__
	yield ''.join(footer())
index.exposed = True

def add_pro(num):
	'''处理号码请求,1:在固定电话前面自动加'023-', 2:在宽带前面自动加"023-0" '''
	num = num.strip()
        num = ''.join(filter(lambda x:x.isalnum() or x in '-.@i', num))
	if num.startswith('23'): num = '023-0' + num
	if num[:3] not in ('133','153','189', '177','180','181','173') and not num.startswith('023-'):
		num = '023-' + num
	return num

def batch1(*k, **kw):
	'''批量查询(最新)'''

	t1 = time.time()
	yield ''.join(header(url='batch1', **kw))
	kw_n = my_tools.query_dict(**kw)
        sql = ''' select %s, a.completed_date cd2 from  latn_33_serv a
        --left join wid_chn_prd_serv_mkt_day_33 b 
        --left join tmp_33_cust cust on a.cust_id=cust.cust_id
        --left join DIM_ZONE_AREA_NEW b on a.mkt_grid_id=b.mkt_grid_id
        --left join DIM_ZONE_comm_NEW comm on a.com_grid_id=comm.mkt_comm_id
	--left join dim_crm_product product on a.product_id=product.product_id
        --left join MID_L_ACCESS_PRD_INST_DAY inst on replace(a.acc_nbr,'023-','')=inst.acc_nbr
        left join WID_SERV_BB_DETAIL_DAY_33 bb on a.serv_id=bb.serv_id --用户宽表
        where --day_id=20140225 and 
        a.acc_nbr in (%s)
        and a.product_id <> '208511203' -- 排除WLAN产品
        order by cd2 desc   --按竣工日期倒序, 确保展示最新的记录
        ;
        '''
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	#tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-3)).strftime('_%Y%m%d')
	fee_month = '_'+cherrypy.session.get('feemonth',ymd[1:7])
	# 如果不是选取的当前月份,则采用月表,否则采取最近的日表数据
	#print '--', fee_month, ymd[:7]
	if fee_month == ymd[:7]:
		tbl_name += ymd
		#tbl_cust += ymd
		tbl_cust_code += ymd
	else:
		#fee_month = '_20121031'
		tbl_name += fee_month
		#tbl_cust += fee_month
		tbl_cust_code += fee_month
	#sql = sql % ('%s', tbl_name, tbl_cust_code, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱;013 光分路器"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['a.acc_nbr']+kw_n['dis_cols'])
		sql = sql % (kw_n['dis_cols'], ','.join(acc_nbr))
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:-1])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = ['a.acc_nbr', 'a.serv_id','a.day_id', 'a.user_name', 'a.prod_addr', 'a.mkt_chnl_name', 'a.mkt_region_name', 'a.mkt_grid_name', 'a.com_chnl_name', 'a.com_grid_name', 'a.rule_type_name', 'a.jjx_code', 'a.fxh_code', 'a.sub_exch_id', 'a.obd_no', 'a.main_prod_type_name', 'a.product_name', 'a.base_down_velocity', 'a.add_down_velocity', 'a.resid_flag', 'a.acct_code', 'a.acct_name'
                #, 'd.user_ad_arrive_num','d.user_postn_arrive_num'
                , "a.user_grp_type", "a.deputy_acc_nbr", "a.state", 'a.serv_state', 'a.arrive_flag', 'a.completed_date', 'a.remove_date', 'a.billing_mode_id', 'a.cust_name', 'a.cust_address', 'a.telephone', 'cust_certificate_no', 'a.billing_flag_id', 'a.physical_no', 'a.is_owe_flag', 'a.owe_monshts', 'a.sales_resource_name', 'a.resource_instance_code', 'a.cust_code', 'a.cstop_flag', 'a.smart_flag', 'a.access_name', 'a.serv_id', 'a.service_level', 'inst.col2', 'a.contact_name', 'a.contact_tel'
                ,'a.staff_name', 'a.party_name', 'bb.main_offer_comp_name', 'bb.factory', 'bb.type', 'bb.imei', 'a.g4_type', 'bb.staff_id', 'bb.depart_id']
	cols_name = """用户电话号码 a.serv_id day_id 用户名称 用户地址 营销线_营维部名称 营销线_片区名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 分线盒 母局名称 光OBD 产品一级名称 产品四级名称 带宽速率_下行 带宽_附加下行 政企属性 账户编码 账户名称 
        用户战略分群 客户_代表号码 用户状态 设备状态 到达标志 竣工时间 拆机日期 计费模式 产权客户姓名 产权客户地址 产权客户联系电话 产权客户证件号码 公免标志 物理号码 欠费标志 欠费月份 终端类型 串号信息 产权客户编码 催停标志 智能机标识 接入方式 a.serv_id 用户差异化等级 电路维护等级 联系人 联系电话 
        录入人 发展人 主套餐 厂家 机型 串码 4G用户 staff_id depart_id""".split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若选取的月份不是当前月,则用该月的月表.若是当前月,则采取最新的日表.
	6.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch1.exposed = True

def batch1_mon(*k, **kw):
	'''批量查询(按月)'''

	t1 = time.time()
	yield ''.join(header(url='batch1_mon', **kw))
	kw_n = my_tools.query_dict(**kw)
        sql = ''' select %s, a.completed_date cd2 from  latn_33_serv_FEEMONTH a
        --left join wid_chn_prd_serv_mkt_day_33 b 
        --left join wid_cust_day cust on a.cust_id=cust.cust_id
        --left join DIM_ZONE_AREA_NEW b on a.mkt_grid_id=b.mkt_grid_id
        --left join DIM_ZONE_comm_NEW comm on a.com_grid_id=comm.mkt_comm_id
	--left join dim_crm_product product on a.product_id=product.product_id
        --left join MID_L_ACCESS_PRD_INST_DAY inst on replace(a.acc_nbr,'023-','')=inst.acc_nbr
        left join WID_SERV_BB_DETAIL_DAY_33 bb on a.serv_id=bb.serv_id --用户宽表
        where --day_id=20140225 and 
        a.acc_nbr in (%s)
        and a.product_id <> '208511203' -- 排除WLAN产品
        order by cd2 desc   --按竣工日期倒序, 确保展示最新的记录
        ;
        '''
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	#tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-3)).strftime('_%Y%m%d')
	fee_month = '_'+cherrypy.session.get('feemonth',ymd[1:7])
	# 如果不是选取的当前月份,则采用月表,否则采取最近的日表数据
        sql = sql.replace('FEEMONTH', fee_month[1:])
	#print '--', fee_month, ymd[:7]
	if fee_month == ymd[:7]:
		tbl_name += ymd
		#tbl_cust += ymd
		tbl_cust_code += ymd
	else:
		#fee_month = '_20121031'
		tbl_name += fee_month
		#tbl_cust += fee_month
		tbl_cust_code += fee_month
	#sql = sql % ('%s', tbl_name, tbl_cust_code, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱;013 光分路器"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['a.acc_nbr']+kw_n['dis_cols'])
		sql = sql % (kw_n['dis_cols'], ','.join(acc_nbr))
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:-1])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = ['a.acc_nbr', 'a.serv_id','a.day_id', 'a.user_name', 'a.prod_addr', 'a.mkt_chnl_name', 'a.mkt_region_name', 'a.mkt_grid_name', 'a.com_chnl_name', 'a.com_grid_name', 'a.rule_type_name', 'a.jjx_code', 'a.fxh_code', 'a.sub_exch_id', 'a.obd_no', 'a.main_prod_type_name', 'product.product_name', 'a.base_down_velocity', 'a.add_down_velocity', 'a.resid_flag', 'a.acct_code', 'a.acct_name'
                #, 'd.user_ad_arrive_num','d.user_postn_arrive_num'
                , "a.user_grp_type", "a.deputy_acc_nbr", "a.state", 'a.serv_state', 'a.arrive_flag', 'a.completed_date', 'a.remove_date', 'a.billing_mode_id', 'a.cust_name', 'cust.cust_address', 'cust.telephone', 'cust_certificate_no', 'a.billing_flag_id', 'a.physical_no', 'a.is_owe_flag', 'a.owe_monshts', 'a.sales_resource_name', 'a.resource_instance_code', 'a.cust_code', 'a.cstop_flag', 'a.smart_flag', 'a.access_name', 'a.serv_id', 'a.service_level', 'inst.col2', 'a.contact_name', 'a.contact_tel'
                ,'a.staff_name', 'a.party_name', 'bb.main_offer_comp_name', 'bb.factory', 'bb.type', 'bb.imei', 'a.g4_type']
	cols_name = """用户电话号码 a.serv_id day_id 用户名称 用户地址 营销线_营维部名称 营销线_片区名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 分线盒 母局名称 光OBD 产品一级名称 产品四级名称 带宽速率_下行 带宽_附加下行 政企属性 账户编码 账户名称 
        用户战略分群 客户_代表号码 用户状态 设备状态 到达标志 竣工时间 拆机日期 计费模式 产权客户姓名 产权客户地址 产权客户联系电话 产权客户证件号码 公免标志 物理号码 欠费标志 欠费月份 终端类型 串号信息 产权客户编码 催停标志 智能机标识 接入方式 a.serv_id 用户差异化等级 电路维护等级 联系人 联系电话 
        录入人 发展人 主套餐 厂家 机型 串码 4G用户""".split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若选取的月份不是当前月,则用该月的月表.若是当前月,则采取最新的日表.
	6.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch1_mon.exposed = True

def batch1_pstn(*k, **kw):
	'''批量查询手机同帐号下AD和固话数量'''

	t1 = time.time()
	yield ''.join(header(url='batch1_pstn', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''
	select a.acc_nbr, a.mkt_cust_code
	--,sum(case when b.product_id=102030001 then 1 else 0 end) adsl_count
	--,sum(case when b.product_id=101010001 then 1 else 0 end) adsl_count
        ,sum(case when b.product_id in (102030001,101010001) then 1 else 0 end) adsl_ptsn_count
	--count(*)
	--,a.mkt_cust_code, b.acc_nbr, b.product_id 
	from %s a
	left join %s b on a.mkt_cust_code=b.mkt_cust_code and b.serv_num=1
	where a.acc_nbr in (%s) and a.serv_num=1
	group by 1,2
	limit 1000;
	;''' 
        sql = """
        select a.acc_nbr, a.acct_code, a.day_id
        --, b.product_id 
        ,sum(case when b.product_id in (102030001,101010001) then 1 else 0 end) adsl_ptsn_count
        from 
        latn_33_serv a 
        left join latn_33_serv b on a.acct_code=b.acct_code
        --wid_chn_prd_serv_mkt_day_33 a
        --left join wid_chn_prd_serv_mkt_day_33 b on a.acct_code=b.acct_code
         --and b.serv_state='2HA'
         --and b.day_id=(select max(day_id) from public.ods_data_msg  --数据更新日志表, 可知哪个表更新到了哪一天.
         --where table_code = 'wid_chn_prd_serv_mkt_day')
        where a.acc_nbr in (%s) 
        -- and a.arrive_flag=1
        --and a.serv_state='2HA'
        -- and a.day_id=(select max(day_id) from public.ods_data_msg  --数据更新日志表, 可知哪个表更新到了哪一天.
        --where table_code = 'wid_chn_prd_serv_mkt_day')
        group by 1,2,3 
        limit 2000;
        """


	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-3)).strftime('_%Y%m%d')
	fee_month = '_'+cherrypy.session.get('feemonth',ymd[1:7])
	# 如果不是选取的当前月份,则采用月表,否则采取最近的日表数据
	#print '--', fee_month, ymd[:7]
	if fee_month == ymd[:7]:
		tbl_name += ymd
		tbl_cust += ymd
		tbl_cust_code += ymd
	else:
		#fee_month = '_20121031'
		tbl_name += fee_month
		tbl_cust += fee_month
		tbl_cust_code += fee_month
	# sql = sql % (tbl_name, tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	kw_n['dis_cols'] = ['acc_nbr','mkt_cust_code','ad_count', 'pstn_count']
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (','.join(acc_nbr))
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[0:])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = ['acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'fxh_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', 'd.user_ad_arrive_num','d.user_postn_arrive_num', "user_grp_type", "deputy_acc_nbr", "a.state", 'a.serv_state', 'a.serv_num', 'a.completed_date', 'a.remove_date', 'billing_mode_id', 'cust.cust_name', 'cust.cust_address', 'cust.telephone', 'billing_flag_id', 'physical_no', 'obd_no', 'owe_monshts']
	cols_name = '用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 分线盒 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 AD到达数量 固话到达数量 用户战略分群 客户_代表号码 用户状态 设备状态 到达标志 竣工时间 拆机日期 计费模式 产权客户姓名 产权客户地址 产权客户联系电话 公免标志 物理号码 光OBD 欠费月份'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若选取的月份不是当前月,则用该月的月表.若是当前月,则采取最新的日表.
	6.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch1_pstn.exposed = True

def batch1_ad(*k, **kw):
	'''批量查询AD基本资料'''

	t1 = time.time()
	yield ''.join(header(url='batch1_ad', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''select %s from %s a left join DIM_ZONE_area b on a.mkt_grid_id=b.mkt_grid_id left join dim_zone_comm c on a.com_grid_id=c.com_grid_id left join %s d on a.mkt_cust_code=d.mkt_cust_code left join dim_crm_product product on a.product_id=product.product_id

	left join %s cust on a.cust_id=cust.cust_id where acc_nbr in (%s) 
	and a.product_id=102030001 --只查ADSL
	and serv_num=1
	;''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-3)).strftime('_%Y%m%d')
	fee_month = '_'+cherrypy.session.get('feemonth',ymd[1:7])
	# 如果不是选取的当前月份,则采用月表,否则采取最近的日表数据
	#print '--', fee_month, ymd[:7]
	if fee_month == ymd[:7]:
		tbl_name += ymd
		tbl_cust += ymd
		tbl_cust_code += ymd
	else:
		tbl_name += fee_month
		tbl_cust += fee_month
		tbl_cust_code += fee_month
	sql = sql % ('%s', tbl_name, tbl_cust, tbl_cust_code, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = acc_nbr_query = map(lambda x:x.startswith('1') and '023-'+x or x, acc_nbr)
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (kw_n['dis_cols'], ','.join(acc_nbr))
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = ['acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'fxh_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "user_grp_type", "contact_tel", "deputy_acc_nbr", "a.state", 'a.serv_state', 'a.serv_num', 'a.completed_date', 'a.remove_date', 'billing_mode_id', 'cust.cust_name', 'cust.cust_address', 'billing_flag_id', 'physical_no']
	cols_name = '用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 分线盒 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 用户战略分群 客户_联系电话 客户_代表号码 用户状态 设备状态 到达标志 竣工时间 拆机日期 计费模式 产权客户姓名 产权客户地址 公免标志 物理号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若选取的月份不是当前月,则用该月的月表.若是当前月,则采取最新的日表.
	6.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch1_ad.exposed = True

def batch1_pstn_ad(*k, **kw):
	'''查询固话加装宽带/iTV'''

	t1 = time.time()
	yield ''.join(header(url='batch1_pstn_ad', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''select %s from %s a left join DIM_ZONE_area b on a.mkt_grid_id=b.mkt_grid_id left join dim_zone_comm c on a.com_grid_id=c.com_grid_id left join %s d on a.mkt_cust_code=d.mkt_cust_code left join dim_crm_product product on a.product_id=product.product_id
	left join %s cust on a.cust_id=cust.cust_id where acc_nbr in (%%s) 
	and a.product_id=102030001 --只查ADSL
	and serv_num=1 ;''' 
        sql = ''' select a.acc_nbr, a.serv_id, a.acct_code
        , b.*
        ,bs.acc_nbr, bs.serv_id
        ,c.*, cs.acc_nbr, cs.serv_id
        , cdma.acc_nbr
         from latn_33_serv a 
        left join  MID_L_PROD_INST_REL_DAY b on a.serv_id=b.prod_inst_z_id
        left join latn_33_serv bs on b.prod_inst_a_id=bs.serv_id
        left join  MID_L_PROD_INST_REL_DAY c on b.prod_inst_a_id=c.prod_inst_z_id
        left join latn_33_serv cs on c.prod_inst_a_id=cs.serv_id
        left join latn_33_serv cdma on a.acct_id=cdma.acct_id and cdma.product_id=208511296 
        where a.acc_nbr in (%s)
        and b.relation_id=700208
        limit 1000;
        --结果字段显示为: 固话, 加装宽带, 加装iTV, 同合同号下手机(如有多个是任选一个)
        '''
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-3)).strftime('_%Y%m%d')
	fee_month = '_'+cherrypy.session.get('feemonth',ymd[1:7])
	# 如果不是选取的当前月份,则采用月表,否则采取最近的日表数据
	#print '--', fee_month, ymd[:7]
	if fee_month == ymd[:7]:
		tbl_name += ymd
		tbl_cust += ymd
		tbl_cust_code += ymd
	else:
		tbl_name += fee_month
		tbl_cust += fee_month
		tbl_cust_code += fee_month
	#sql = sql % ('%s', tbl_name, tbl_cust, tbl_cust_code, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = acc_nbr_query = map(lambda x:x.startswith('1') and '023-'+x or x, acc_nbr)
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
        if len(acc_nbr) :#and kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (','.join(acc_nbr))
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
                print 'Len', len(recs)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = ['acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'fxh_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "user_grp_type", "contact_tel", "deputy_acc_nbr", "a.state", 'a.serv_state', 'a.serv_num', 'a.completed_date', 'a.remove_date', 'billing_mode_id', 'cust.cust_name', 'cust.cust_address', 'billing_flag_id', 'physical_no']
	cols_name = '用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 分线盒 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 用户战略分群 客户_联系电话 客户_代表号码 用户状态 设备状态 到达标志 竣工时间 拆机日期 计费模式 产权客户姓名 产权客户地址 公免标志 物理号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若选取的月份不是当前月,则用该月的月表.若是当前月,则采取最新的日表.
	6.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch1_pstn_ad.exposed = True


def batch2(*k, **kw):
	'''ADSL共线群查询'''

	t1 = time.time()
        kw['url'] = 'batch2'
	yield ''.join(header(**kw))
	kw_n = my_tools.query_dict(**kw)
	sql = ''' select %(dis_cols)s, a.group_id, gh_a.acc_nbr, adsl_a.acc_nbr, itv_a.acc_nbr, itv.serv_id serv_id from 
	(select a.acc_nbr,a.user_name, a.prod_addr, a.jjx_code, a.sub_exch_id, a.down_velocity, a.mkt_cust_code, cust_grp_type, contact_tel, deputy_acc_nbr, b.group_id, a.serv_id, com_grid_name, com_channel_name, mkt_grid_name, mkt_channel_name, rule_type, product_name
	from ds_chn_prd_serv_AREA_FEEMONTH a 
	left join dm_prd_crm_service_grp_member b on a.serv_id=b.serv_id 
	and b.member_role_id in (%(rule1)s, %(rule2)s, %(rule3)s) 
	left join DM_PRD_SERVICE_GROUP c on b.group_id=c.group_id
	left join dim_zone_area mkt on a.mkt_grid_id=mkt.mkt_grid_id
	left join dim_zone_comm com on a.com_grid_id=com.com_grid_id
	left join ds_chn_prd_cust_AREA_FEEMONTH cust on a.mkt_cust_code=cust.mkt_cust_code
	left join dim_crm_product product on a.product_id=product.product_id
	where a.acc_nbr in (%(acc_nbr_sql)s)
	and c.group_type_id=%(group_type_id)s)  a
	left join dm_prd_crm_service_grp_member gh on a.group_id=gh.group_id and gh.member_role_id=%(rule1)s
	left join ds_chn_prd_serv_AREA_FEEMONTH gh_a on gh.serv_id=gh_a.serv_id
	left join dm_prd_crm_service_grp_member adsl on a.group_id=adsl.group_id and adsl.member_role_id=%(rule2)s
	left join ds_chn_prd_serv_AREA_FEEMONTH adsl_a on adsl.serv_id=adsl_a.serv_id
	left join dm_prd_crm_service_grp_member itv on a.group_id=itv.group_id and itv.member_role_id=%(rule3)s
	left join ds_chn_prd_serv_AREA_FEEMONTH itv_a on itv.serv_id=itv_a.serv_id ;'''

        sql = '''
        select a.acc_nbr acc_nbr,a.day_id, c.acc_nbr pstn, c2.acc_nbr itv
        from latn_33_serv a 
        --left join tmp_33_rel_1 b on a.serv_id=b.prod_inst_a_id and b.relation_id=700193
        left join MID_L_PROD_INST_REL_DAY b on a.serv_id=b.prod_inst_a_id and b.relation_id=700193
        left join latn_33_serv c on b.prod_inst_z_id=c.serv_id
        --left join tmp_33_rel_1 b2 on a.serv_id=b2.prod_inst_z_id and b2.relation_id=700291
        left join MID_L_PROD_INST_REL_DAY b2 on a.serv_id=b2.prod_inst_z_id and b2.relation_id=700291
        left join latn_33_serv c2 on b2.prod_inst_a_id=c2.serv_id
        where a.acc_nbr in (%s);
        -- 结果字段: 更新日期 固话号码 iTV号码
        '''

        acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	kw_n['acc_nbr_sql'] = ','.join(acc_nbr)
	sql = sql.replace('AREA', cherrypy.session.get('fengongshi','33'))
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-3)).strftime('%Y%m%d')
	sql = sql.replace('FEEMONTH', ymd)
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n', '<br />')
	if 'a.rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when a.rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('a.rule_type')] = "case %s end" % str_tmp 
	if len(acc_nbr):
		if kw_n['dis_cols']=='':
			kw_n['dis_cols'] = []
		if type(kw_n['dis_cols'])<>type([]):
			kw_n['dis_cols'] = [kw_n['dis_cols']]
		kw_n['dis_cols'] = ','.join(['a.acc_nbr']+kw_n['dis_cols'])
		#sql = sql % kw_n
                sql = sql % (','.join(acc_nbr))
                #print sql
		recs = dbapi.Table( _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or '\t',dis_serial))).decode('utf-8')
	yield '''<tr><td width="20%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = ['a.acc_nbr', 'a.user_name', 'a.prod_addr', 'a.mkt_channel_name', 'a.mkt_grid_name', 'a.com_channel_name', 'a.com_grid_name', 'a.rule_type', 'a.jjx_code', 'a.sub_exch_id', 'a.product_name', 'a.down_velocity', 'a.mkt_cust_code', "a.cust_grp_type", "a.contact_tel", "a.deputy_acc_nbr"]
	cols_name = '用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	#yield '<td width="15%%" align="center">选择输出字段<br />%s</td>' % INPUT(type="submit", value="提取")
	yield '''<td with="60%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' 
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch2.exposed = True


def batch2_all(*k, **kw):
	'''通用产品关联关系查询'''

	t1 = time.time()
        kw['url'] = 'batch2_all'
	yield ''.join(header(**kw))
	kw_n = my_tools.query_dict(**kw)
        sql = '''
        select a.acc_nbr acc_nbr,a.day_id 更新日期, b.relation_id A端关系, c.acc_nbr A端号码, b2.relation_id Z端关系, c2.acc_nbr Z端号码
        from latn_33_serv a 
        left join MID_L_PROD_INST_REL_DAY b on a.serv_id=b.prod_inst_a_id -- and b.relation_id=700193
        left join latn_33_serv c on b.prod_inst_z_id=c.serv_id
        left join MID_L_PROD_INST_REL_DAY b2 on a.serv_id=b2.prod_inst_z_id -- and b2.relation_id=700291
        left join latn_33_serv c2 on b2.prod_inst_a_id=c2.serv_id
        where a.acc_nbr in (%s);
        --此处查询对应CRM综合查询产品界面的"关联产品信息",目前已知的关系id对应描述: 
        --700131 - CHINANET与光纤专线绑定关系
        --700291 - iTV与ADSL宽带上网绑定关系
        --700193 - ADSL宽带上网与固定电话加装关系
        --700208 - ADSL宽带上网与固定电话账号关联关系
        --遇到其他不明的关系, 请再联系确定后添加
        --iVPN群和iPVPN群组成员查询, 不在此处查询.
        -- 结果字段: 查询号码 更新日期 A端关系 A端号码 Z端关系 Z端号码
        '''

        acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	kw_n['acc_nbr_sql'] = ','.join(acc_nbr)
	sql = sql.replace('AREA', cherrypy.session.get('fengongshi','33'))
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-3)).strftime('%Y%m%d')
	sql = sql.replace('FEEMONTH', ymd)
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n', '<br />')
	if 'a.rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when a.rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('a.rule_type')] = "case %s end" % str_tmp 
	if len(acc_nbr):
		if kw_n['dis_cols']=='':
			kw_n['dis_cols'] = []
		if type(kw_n['dis_cols'])<>type([]):
			kw_n['dis_cols'] = [kw_n['dis_cols']]
		kw_n['dis_cols'] = ','.join(['a.acc_nbr']+kw_n['dis_cols'])
		#sql = sql % kw_n
                sql = sql % (','.join(acc_nbr))
                #print sql
		recs = dbapi.Table( _sqlment = sql, _sqlment_values=[], _values_1=False)
                # 如下原两行要取消, 现在显示全部结果, 非按行一对一
		#dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or '\t',dis_serial))).decode('utf-8')
		kw_n['right'] = cgi.escape('\n'.join('\t'.join(map(str,rec._data)) for rec in recs))
	yield '''<tr><td width="20%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = ['a.acc_nbr', 'a.user_name', 'a.prod_addr', 'a.mkt_channel_name', 'a.mkt_grid_name', 'a.com_channel_name', 'a.com_grid_name', 'a.rule_type', 'a.jjx_code', 'a.sub_exch_id', 'a.product_name', 'a.down_velocity', 'a.mkt_cust_code', "a.cust_grp_type", "a.contact_tel", "a.deputy_acc_nbr"]
	cols_name = '用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	#yield '<td width="15%%" align="center">选择输出字段<br />%s</td>' % INPUT(type="submit", value="提取")
	yield '''<td with="60%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' 
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch2_all.exposed = True

def batch2_ivpn(*k, **kw):
	'''iVPN同群号码查询'''

	t1 = time.time()
        kw['url'] = 'batch2_ivpn'
	yield ''.join(header(**kw))
	kw_n = my_tools.query_dict(**kw)
        sql = '''
        select distinct b.acc_nbr, a.col8 , attr.attr_value_id, a.col1
        from latn_33_func_prod_ivpn a
        left join latn_33_access_prd b on a.comp_inst_id=b.comp_inst_id
        left join MID_L_FUNC_PROD_INST_ATTR_DAY attr on a.comp_inst_id=attr.comp_inst_id and attr.field_name='col17' --and attr.beg_time=1    -- 集团付费额度
        where a.action_type not in ('D') and a.col1 in (
        select distinct b.col1 from latn_33_access_prd a
        left join latn_33_func_prod_ivpn b on a.comp_inst_id=b.comp_inst_id --and b.product_id in ('700600004')
        where acc_nbr in (%s))
        order by b.acc_nbr
        limit 1000 
        ;
        -- 结果字段: 长号 短号 集团付费额度 IVPN群标识
        -- 注意: 付费额度为0, 有可能表示集团全额付费. 因取集团付费策略还要再关联一次表格, 省了.

        '''

        acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	kw_n['acc_nbr_sql'] = ','.join(acc_nbr)
	sql = sql.replace('AREA', cherrypy.session.get('fengongshi','33'))
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-3)).strftime('%Y%m%d')
	sql = sql.replace('FEEMONTH', ymd)
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n', '<br />')
	if 'a.rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when a.rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('a.rule_type')] = "case %s end" % str_tmp 
	if len(acc_nbr):
		if kw_n['dis_cols']=='':
			kw_n['dis_cols'] = []
		if type(kw_n['dis_cols'])<>type([]):
			kw_n['dis_cols'] = [kw_n['dis_cols']]
		kw_n['dis_cols'] = ','.join(['a.acc_nbr']+kw_n['dis_cols'])
		#sql = sql % kw_n
                sql = sql % (','.join(acc_nbr))
                #print sql
		recs = dbapi.Table( _sqlment = sql, _sqlment_values=[], _values_1=False)
                # 如下原两行要取消, 现在显示全部结果, 非按行一对一
		#dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or '\t',dis_serial))).decode('utf-8')
		kw_n['right'] = cgi.escape('\n'.join('\t'.join(map(str,rec._data)) for rec in recs))
	yield '''<tr><td width="20%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = ['a.acc_nbr', 'a.user_name', 'a.prod_addr', 'a.mkt_channel_name', 'a.mkt_grid_name', 'a.com_channel_name', 'a.com_grid_name', 'a.rule_type', 'a.jjx_code', 'a.sub_exch_id', 'a.product_name', 'a.down_velocity', 'a.mkt_cust_code', "a.cust_grp_type", "a.contact_tel", "a.deputy_acc_nbr"]
	cols_name = '用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	#yield '<td width="15%%" align="center">选择输出字段<br />%s</td>' % INPUT(type="submit", value="提取")
	yield '''<td with="60%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' 
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch2_ivpn.exposed = True

def batch2_ivpn_8(*k, **kw):
	'''iVPN成员号码查询'''

	t1 = time.time()
        kw['url'] = 'batch2_ivpn_8'
	yield ''.join(header(**kw))
	kw_n = my_tools.query_dict(**kw)
        sql = '''
        select distinct aa.acc_nbr, b.acc_nbr, a.col8 , attr.attr_value_id , a.stop_rent_time
        --, a.*, b.*, attr.*
        from latn_33_serv aa left join 
        latn_33_func_prod_ivpn a on aa.serv_id=a.col1
        left join latn_33_access_prd b on a.comp_inst_id=b.comp_inst_id
        left join MID_L_FUNC_PROD_INST_ATTR_DAY attr on a.comp_inst_id=attr.comp_inst_id and attr.field_name='col17' --and attr.beg_time=1 -- 集团付费额度
        where 
        aa.acc_nbr in (%s)
        order by b.acc_nbr
        ;
        '''

        acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	kw_n['acc_nbr_sql'] = ','.join(acc_nbr)
	sql = sql.replace('AREA', cherrypy.session.get('fengongshi','33'))
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-3)).strftime('%Y%m%d')
	sql = sql.replace('FEEMONTH', ymd)
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n', '<br />')
	if 'a.rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when a.rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('a.rule_type')] = "case %s end" % str_tmp 
	if len(acc_nbr):
		if kw_n['dis_cols']=='':
			kw_n['dis_cols'] = []
		if type(kw_n['dis_cols'])<>type([]):
			kw_n['dis_cols'] = [kw_n['dis_cols']]
		kw_n['dis_cols'] = ','.join(['a.acc_nbr']+kw_n['dis_cols'])
		#sql = sql % kw_n
                sql = sql % (','.join(acc_nbr))
                #print sql
		recs = dbapi.Table( _sqlment = sql, _sqlment_values=[], _values_1=False)
                # 如下原两行要取消, 现在显示全部结果, 非按行一对一
		#dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or '\t',dis_serial))).decode('utf-8')
		kw_n['right'] = cgi.escape('\n'.join('\t'.join(map(str,rec._data)) for rec in recs))
	yield '''<tr><td width="20%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = ['a.acc_nbr', 'a.user_name', 'a.prod_addr', 'a.mkt_channel_name', 'a.mkt_grid_name', 'a.com_channel_name', 'a.com_grid_name', 'a.rule_type', 'a.jjx_code', 'a.sub_exch_id', 'a.product_name', 'a.down_velocity', 'a.mkt_cust_code', "a.cust_grp_type", "a.contact_tel", "a.deputy_acc_nbr"]
	cols_name = '用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	#yield '<td width="15%%" align="center">选择输出字段<br />%s</td>' % INPUT(type="submit", value="提取")
	yield '''<td with="60%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' 
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch2_ivpn_8.exposed = True

def batch3(*k, **kw):
	'''根据合同号提电话号码'''

	t1 = time.time()
	yield ''.join(header(url='batch3', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''select acct_code acc_nbr, acc_nbr acc from latn_33_serv a where acct_code in (%s)
	--and serv_num=1
        order by 1
	;''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	acc_nbr = map(lambda x:x.strip(), acc_nbr)
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		kw_n['right'] = cgi.escape('\n'.join(['\t'.join(i._data) for i in recs]))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是合同号,即营销客户编码.
	2.右边出来的是多行号码,与营销客户并不一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch3.exposed = True

def batch4(*k, **kw):
	'''根据号码提商品包优惠商品'''

	sql = ''' select a.serv_id, a.acc_nbr
	  into temp tab_4m_all
	  from %s a
	 where acc_nbr in (%s);
	select a.*, b.offer_name comp_name, b.offer_comp_id, c.offer_name from tab_4m_all a left join 
	(select serv_id, pg_concat(t3.offer_name||',') offer_name, pg_concat(a.offer_comp_id||',') offer_comp_id from ds_prd_offer_comp_detail a
	left join dim_crm_product_offer t3 on a.offer_comp_id=t3.offer_id --and t3.base_flag=1
	-- and t3.offer_kind='C'
	where serv_id in (select serv_id from tab_4m_all) 
	--and t3.state='00A'
	and t3.offer_kind not in ('0') group by 1)
	b on a.serv_id=b.serv_id
	left join (select serv_id, pg_concat(t3.offer_name||',') offer_name from ds_prd_offer_comp_detail a
	left join dim_crm_product_offer t3 on a.prod_offer_id=t3.offer_id
	-- and t3.offer_kind='C'
	where serv_id in (select serv_id from tab_4m_all) 
	--and t3.state='00A' 
	and t3.offer_kind not in ('0') group by 1)
	c on a.serv_id=c.serv_id

	;
	'''
	t1 = time.time()
	yield ''.join(header(url='batch4', **kw))
	kw_n = my_tools.query_dict(**kw)
	#sql = '''select acc_nbr from %s a where acc_nbr in (%s); ''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	tbl_name += ymd
	sql = sql % (tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是合同号,即营销客户编码.
	2.右边出来的是多行号码,与营销客户并不一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch4.exposed = True

def batch4_muti(*k, **kw):
	'''根据号码提优惠商品'''

	sql = ''' --根据号码提优惠商品,字段为:号码,商品包id, 商品包名称, 商品包实例id
		--若实例id相同, 则表明是处于同一个优惠商品包中,此可以判断是否共同的122,或是否共同的e9套餐等.
		select a.acc_nbr, b.prod_offer_id, b.offer_comp_id, t3.offer_id,t3.offer_name
		--, prod_offer_inst_id
		, offer_comp_instance_id 
		, prod_offer_class_id
		, t4.base_flag, offer_comp_type_desc0, offer_comp_type_desc1, offer_comp_type_desc2, offer_comp_type_desc3, offer_comp_type_desc4, offer_comp_type_desc5, offer_comp_type_desc6
                , b.prod_offer_inst_eff_date 生效时间
                , b.prod_offer_inst_exp_date 失效时间
		from ds_chn_prd_serv_{area}_{yyyymm} a 
		left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='001' and prod_offer_inst_detail_state='001'
		left join dim_crm_product_offer t3 on b.prod_offer_id=t3.offer_id 
		left join DIM_WD_OFFER_NEW_DIR_SECOND t4 on b.offer_comp_id=t4.offer_comp_type_id6 
		where acc_nbr IN (%s) 
		-- and t3.offer_id is not null
		and b.serv_id is not null
		limit 5100;
	'''
        sql = '''
        select acc_nbr, user_name
        --, completed_date,  serv.product_id
        ,b.OFFER_EFF_DATE,--	套餐生效时间
        b.OFFER_EXP_DATE,--	套餐失效时间
        b.OFFER_COMPLETED_DATE,--	套餐竣工时间
        b.OPER_ID,--	操作员
        b.COMP_ENABLE_FLAG, --	套餐到达标记
        COMP_ONLG_FLAG	,--月新增套餐标记
        COMP_SERV_NEW_FLAG,--	套餐新入网用户标记
        b.comp_offer_id,
        c.OFFER_COMP_TYPE_DESC6,
        c.SELECT_FLAG,c.BASE_FLAG,c.main_flag
        --,zj.mkt_chnl_name, zj.mkt_grid_name

         from 
         --WID_CHN_OFFER_COMP_COM_MON_33 b  --套餐日表
        --WID_CHN_PRD_OFFER_COMP_MKT_DAY_33 b
        latn_33_offer b
        left join DIM_WD_OFFER_NEW_DIR_SECOND c on b.comp_offer_id=c.offer_comp_type_id6 
        where 
        --acct_month=201401 
        --day_id=20140214 --改为用日表, 套餐日表名称不一样
        acc_nbr in (%s)
        -- and serv.completed_date like '2014-01%%' --暂不考虑CRM竣工时间 or crm_completed_date like '2014-01%%'
        --and serv.product_id ='208511296' --手机
        --'101010001'	--宽带 '''        
	t1 = time.time()
	yield ''.join(header(url='batch4_muti', **kw))
	kw_n = my_tools.query_dict(**kw)
	#sql = '''select acc_nbr from %s a where acc_nbr in (%s); ''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	# 如果是上午,则取前2点的数据,如果是下午,则应该可以取前1天的数据
	days = time.strftime('%H')>'12' and 1 or 2
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-days)).strftime('%Y%m%d')
	fee_month = cherrypy.session.get('feemonth','')
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi','33'))
	if fee_month == ymd[:6]: # 是当月
		sql = sql.replace('{yyyymm}', ymd)
	else:
		sql = sql.replace('{yyyymm}',cherrypy.session.get('feemonth',''))
	tbl_name += ymd
	# sql = sql % (tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		kw_n['right'] = cgi.escape('\n'.join('\t'.join(map(str,rec._data)) for rec in recs))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是合同号,即营销客户编码.
	2.右边出来的是多行号码,与营销客户并不一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch4_muti.exposed = True

def batch4_base(*k, **kw):
	'''提基础商品包'''

        sql = ''' select 
        acc_nbr, -- 号码, 
        OFFER_EFF_DATE,--	套餐生效时间,
        OFFER_EXP_DATE, --	套餐失效时间,
        OFFER_COMPLETED_DATE	, --套餐竣工时间,
        --OPER_ID	,--操作员,
        --ACCEPT_CHANNEL_ID	,--受理渠道
        --COMP_SERV_ENABLE_FLAG, --套餐到达标记
        --a.comp_offer_id,
        OFFER_COMP_TYPE_DESC6	--套餐目录6级名称
        --from tmp_33_WID_CHN_PRD_OFFER_COMP_MKT_DAY_33 a
        ,a.offer_comp_instance_id
        , c.prod_comp_role_cd
        --, a.offer_exp_date
        , fee_class
        , d.staff_code, d.staff_name, org.org_name
        from 
        latn_33_offer a -- 来自套餐分析日表的简化表
        --WID_CHN_PRD_OFFER_COMP_MKT_DAY_33 a
        left join DIM_WD_OFFER_NEW_DIR_SECOND b 
        on a.comp_offer_id=b.offer_comp_type_id6 
        left join mid_l_offer_prod_inst_rel_day c on a.serv_id=c.instance_id and a.offer_comp_instance_id=c.prod_offer_inst_id and action_type<>'D'
        left join dim_crm_staff d on d.staff_id=a.oper_id
        left join dim_crm_organization org on d.org_id=org.party_id
         where 
         --a.day_id=20140226
            --and 
            a.acc_nbr in (%s)
        -- add by tgm , 20150403
        -- 对宽带, 涉iTV优惠的也是主套餐, 结果本身主套餐提漏, 所以以排除. 查询iTV主套餐时, 再注销本条件
        --and not OFFER_COMP_TYPE_DESC6 ~* 'iTV'  -- 这个条件下移到main_flag处, 以便手工添加的主套餐能够始终有效
        and (
        (b.main_flag=1 
        -- and ( 
        ------(a.acc_nbr ~* 'iTV' and offer_comp_type_desc6 ~* 'iTV') or
        --(not a.acc_nbr ~* 'iTV' and not offer_comp_type_desc6 ~* 'iTV')  
        --or a.acc_nbr ~* 'iTV'
         --   )
        )
         or 
        --b.main_flag=1 or 
        a.comp_offer_id in (121244,326526,326529,334143,1316365, 1312203, 1312191, 326498, 308329, 10034981, 10037854, 
        10009354, 10009365, 10009373, 10009376
                ,63277	--ADSL50元包月ADSL注册虚拨上网
        ,1245	--ADSL100元包月
        ,211035	--ADSL120元包月
        ,63278	--ADSL200元包月ADSL注册虚拨上网
        ,63277	--ADSL50元包月ADSL注册虚拨上网
        ,1315	--ADSL65元包月
        ,211036	--ADSL80元包月
        ,303338	--ADSL宽带38元包月
        ,303572	--1M学子在家A288元(绿网+时间控制)	
        ,303573	--1M学子在家B228元(绿网+时间控制)	
        ,303575	--2M学子在家B288元(绿网+时间控制)	
        ,10029505	--e9-8M-99套餐惠民版（全话费iTV频道版）_促销	
        ,331509	--新e9-4M不限时119套餐（全话费版）_过渡期资费	
        ,10009859	--翼通限时宽带-单宽ITV版（4M，35元包10小时）	
        ,10059827  -- 89全家版(2元关联包20M)   
        , 10060259  -- 副号5元
        , 10060265 -- 副号5元200M
        , 10060268  -- 副号5元
        , 10060273  -- 副号5元
        ,10070897, 10070899
    ) )
        -- 426包年要手工添加, ADSL虚拨协议价单元[ADSL宽带上网], LAN虚拨协议价单元[LAN宽带上网],334143 单固话龙卡套餐
        -- 1316365	（酒店）非E家用户itv基础28元包月套餐
        -- 1312203	iTV标清基础包298元包年（E家）
        -- 1312191	iTV标清基础包28元包月（非E家-新用户）
        -- 326498	光纤专线协议价单元[光纤专线]
        -- 308329	光纤专线协议价单元
        -- 10034981	天翼宽带速通卡360元包半年套餐
        -- 10037854	4M-360元半年包（OCS）
        -- 10009354, 10009365, 10009373, 10009376 --新版翼龙, 直接是主套餐
        ----order by offer_exp_date desc; 
        --order by offer_completed_date desc, 
        -- 根据竣工时间, 还是失效时间, 还是生效时间取, 存疑.
        order by OFFER_completed_date desc , OFFER_EFF_DATE desc; --当月变更, 根据套餐竣工时间取最后可能更准确'''
	t1 = time.time()
	yield ''.join(header(url='batch4_base', **kw))
	kw_n = my_tools.query_dict(**kw)
	#sql = '''select acc_nbr from %s a where acc_nbr in (%s); ''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	tbl_name += ymd
	#--sql = sql % (tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
        #kw['acc_nbr'] = kw['acc_nbr'].rstrip()  # 去掉后面多余的空行
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
                #print('dis_serial', dis_serial)
                # 要另文处理一个号码查出来多个主套餐的情况, 因为4G版E9是组合出来的,其宽带查出来有三个合法主套餐:58,169,iTV免费...要优先取169.
                def get_res(n):
                    #print recs.acc_nbr, n
                    if recs.acc_nbr.count(recs.acc_nbr[n])>1:   # 出现多个主套餐
                        # 首先删除已经失效的主套餐
                        
                        # 如果套餐描述有"全家版"字样, 优先采用.
                        rec1 = [i for i in recs if i.acc_nbr==recs.acc_nbr[n]]
                        #print([i.offer_exp_date for i in rec1])
                        rec1 = [i for i in rec1 if i.offer_exp_date>datetime.datetime.now()]
                        # rec1 应该大于1
                        #print('two yh')
                        #print(rec1[0]._data, rec1[1]._data)
                        for rec in rec1:
                            if rec.offer_comp_type_desc6.find('全家版')>-1:
                                idx = recs._columns.index('fee_class')
                                rec._data[idx] = rec.offer_comp_type_desc6[:rec.offer_comp_type_desc6.find('全家版')]    # 将档次从12修改为169或129
                                #print('all fami...')
                                return '\t'.join(map(str, rec._data[1:]))
                        for rec in rec1:    # 有4G聊天版, 优先采用.
                            if rec.offer_comp_type_desc6.find('4G聊天版')>-1 or rec.offer_comp_type_desc6.find('飞Young')>-1 or rec.offer_comp_type_desc6.find('单宽带')>-1:
                                #idx = recs._columns.index('fee_class')
                                #rec._data[idx] = rec.offer_comp_type_desc6[:rec.offer_comp_type_desc6.find('全家版')]    # 将档次从12修改为169或129
                                #print('all fly...')
                                return '\t'.join(map(str, rec._data[1:]))
                        if 'i' in recs.acc_nbr[n]:  # 如果号码是iTV, 优先采用优惠中为也有iTV字样的；
                            #print ('iTV find...')
                            for rec in rec1:
                                if rec.offer_comp_type_desc6.find('i')>-1:
                                    return '\t'.join(map(str, rec._data[1:]))
                        if 'i' not in recs.acc_nbr[n]:  # 如果号码不是iTV, 优先采用优惠描述中没有i字样的.
                            #print (' To be here...' )
                            for rec in rec1:    # 并且套餐不是不含i字的iTV套餐
                                if rec.offer_comp_type_desc6.find('i')==-1 and rec.offer_comp_type_desc6<>'电信电视标准促销版0元（移动）':
                                    return '\t'.join(map(str, rec._data[1:]))
                        #print('End...')
                        return '\t'.join(map(str, recs[n]._data[1:]))
                    #elif n<>-1: #  只查到一个主套餐
                    elif recs.acc_nbr.count(recs.acc_nbr[n])==1:   
                        #print('one yh')
                        if recs[n].offer_comp_type_desc6.find('全家版')>-1:
                            #print('FIND 全家版', recs._data)
                            idx = recs._columns.index('fee_class')
                            tmp = list(recs[n]._data)
                            tmp[idx] = recs[n].offer_comp_type_desc6[:recs[n].offer_comp_type_desc6.find('全家版')]
                            #recs[n]._data = tuple(tmp)
                            recs._data[n] = tuple(tmp)
                            #print('FIND 全家版', recs._data)
                        return '\t'.join(map(str, recs[n]._data[1:]))
                    else:
                        return ' '

                result = []
                for dis in dis_serial:
                    try:
                        if dis==-1:
                            result.append(' ')
                        else:
                            result.append(get_res(dis))
                    except:
                        traceback.print_exc()
                        result.append(' ')
                kw_n['right'] = cgi.escape('\n'.join(result)).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是合同号,即营销客户编码.
	2.右边出来的是多行号码,与营销客户并不一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch4_base.exposed = True

def batch4_base_month(*k, **kw):
	'''提基础商品包(按月)'''

        sql = ''' select 
        acc_nbr, -- 号码, 
        OFFER_EFF_DATE,--	套餐生效时间,
        OFFER_EXP_DATE, --	套餐失效时间,
        OFFER_COMPLETED_DATE	, --套餐竣工时间,
        --OPER_ID	,--操作员,
        --ACCEPT_CHANNEL_ID	,--受理渠道
        --COMP_SERV_ENABLE_FLAG, --套餐到达标记
        --a.comp_offer_id,
        OFFER_COMP_TYPE_DESC6	--套餐目录6级名称
        --from tmp_33_WID_CHN_PRD_OFFER_COMP_MKT_DAY_33 a
        ,a.offer_comp_instance_id
        , c.prod_comp_role_cd
        --, a.offer_exp_date
        , fee_class
        from 
        --latn_33_offer a -- 来自套餐分析日表的简化表
        -- 查历史月数据, 直接使用当月月表.
        --WID_CHN_PRD_OFFER_COMP_MKT_DAY_33 a
        WID_CHN_OFFER_COMP_MKT_MON_33 a
        left join DIM_WD_OFFER_NEW_DIR_SECOND b 
        on a.comp_offer_id=b.offer_comp_type_id6 
        left join latn_33_offer_rel c on a.serv_id=c.instance_id and a.offer_comp_instance_id=c.prod_offer_inst_id
         where 
         --a.day_id=20140226
            --and 
            a.acc_nbr in (%s)
        and a.acct_month<='FEEMONTH'
        and offer_eff_date < 'NEXTMONTH'
        -- add by tgm , 20150403
        -- 对宽带, 涉iTV优惠的也是主套餐, 结果本身主套餐提漏, 所以以排除. 查询iTV主套餐时, 再注销本条件
        and not OFFER_COMP_TYPE_DESC6 ~* 'iTV'
        and (b.main_flag=1 or a.comp_offer_id in (121244,326526,326529,334143,1316365, 1312203, 1312191, 326498, 308329, 10034981, 10037854, 
        10009354, 10009365, 10009373, 10009376
        ,63277	--ADSL50元包月ADSL注册虚拨上网
        ,1245	--ADSL100元包月
        ,211035	--ADSL120元包月
        ,63278	--ADSL200元包月ADSL注册虚拨上网
        ,63277	--ADSL50元包月ADSL注册虚拨上网
        ,1315	--ADSL65元包月
        ,211036	--ADSL80元包月
        ,303338	--ADSL宽带38元包月
        ,303572	--1M*学子在家A288元(绿网+时间控制)	
        ,303573	--1M*学子在家B228元(绿网+时间控制)	
        ,303575	--2M*学子在家B288元(绿网+时间控制)	
        ,10029505	--e9-8M-99套餐惠民版（全话费iTV频道版）_促销	
        ,331509	--新e9-4M不限时119套餐（全话费版）_过渡期资费	
        ,10009859	--翼通限时宽带-单宽ITV版（4M，35元包10小时）	
        ,10059827  -- 89全家版(2元关联包20M)   
        ,10060259   -- 副号5元
        , 10060265 -- 副号5元200M
        , 10060268  -- 副号5元
        , 10060273  -- 副号5元
        ) )
        -- 426包年要手工添加, ADSL虚拨协议价单元[ADSL宽带上网], LAN虚拨协议价单元[LAN宽带上网],334143 单固话龙卡套餐
        -- 1316365	（酒店）非E家用户itv基础28元包月套餐
        -- 1312203	iTV标清基础包298元包年（E家）
        -- 1312191	iTV标清基础包28元包月（非E家-新用户）
        -- 326498	光纤专线协议价单元[光纤专线]
        -- 308329	光纤专线协议价单元
        -- 10034981	天翼宽带速通卡360元包半年套餐
        -- 10037854	4M-360元半年包（OCS）
        -- 10009354, 10009365, 10009373, 10009376 --新版翼龙, 直接是主套餐
        ----order by offer_exp_date desc; 
        ---order by offer_completed_date desc, 
        -- 根据竣工时间, 还是失效时间, 还是生效时间取, 存疑.
        -- 提当月仍有效,则限定条件为:竣工日期在本月1日以前的, 则排除本月及以后变更的套餐
        --and offer_completed_date < 'FEEMONTH' 
        order by 
        --offer_completed_date desc, -- 优先按竣工时间倒序试一下, 能否取到新晚的优惠
        --OFFER_EXP_DATE desc , 
        OFFER_EFF_DATE desc  --当月变更, 根据套餐竣工时间取最后可能更准确
        ,a.comp_offer_id desc -- 再按商品包id排序, 以使多重商品的, 始终出同一商品包'''
	t1 = time.time()
	yield ''.join(header(url='batch4_base_month', **kw))
	kw_n = my_tools.query_dict(**kw)
	#sql = '''select acc_nbr from %s a where acc_nbr in (%s); ''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	tbl_name += ymd
	#--sql = sql % (tbl_name, '%s')
        fm = cherrypy.session.get('feemonth','')
        sql = sql.replace('FEEMONTH', fm)
        #-- 计算下一个月的第1天
        import calendar
        # 调用日历模块,以取得当月的天数
        days = calendar.monthrange(int(fm[:4]), int(fm[4:]))[1]
        nextmonth = datetime.date(int(fm[:4]), int(fm[4:]), 1)
        nextmonth = nextmonth + datetime.timedelta(days=days)
        sql = sql.replace('NEXTMONTH', nextmonth.strftime('%Y-%m-%d'))
        # 以下是为排除优惠竣工日期
        #fm = fm[:4]+'-'+fm[4:] + '-01 00:00:00'
	#sql = sql.replace('FEEMONTH', fm)
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
        #kw['acc_nbr'] = kw['acc_nbr'].rstrip()  # 去掉后面多余的空行
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是合同号,即营销客户编码.
	2.右边出来的是多行号码,与营销客户并不一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch4_base_month.exposed = True

def batch4_base_detail(*k, **kw):
	'''提基础商品_明细表'''

        sql = ''' 
            drop table if exists temp_33_clost_t1;
            create table temp_33_clost_t1 as 
            select distinct aa.acc_nbr, prod_offer_inst_created_date, prod_offer_inst_eff_date, prod_offer_inst_exp_date 
            , offer_comp_type_desc6 
            , b.fee_class, c.prod_comp_role_cd
            , a.offer_comp_instance_id , aa.user_name
            from latn_33_serv aa 
            left join MID_PRD_OFFER_COMP_DETAIL_DAY a on a.serv_id=aa.serv_id
            left join  DIM_WD_OFFER_NEW_DIR_SECOND b on a.offer_comp_id=b.offer_comp_type_id6 
            left join mid_l_offer_prod_inst_rel_day c on a.serv_id=c.instance_id and a.offer_comp_instance_id=c.prod_offer_inst_id and c.action_type<>'D'
            
            where aa.acc_nbr in (%s) and (
            b.main_flag=1 or 
            a.offer_comp_id in (121244,326526,326529,334143,1316365, 1312203, 1312191, 326498, 308329, 10034981, 10037854, 
            10009354, 10009365, 10009373, 10009376
            ,63277,1245 ,211035 ,63278 ,63277 ,1315 ,211036 ,303338 ,303572 ,303573 ,303575 ,10029505 ,331509 ,10009859
            ,10059827  -- 89全家版(2元关联包20M)   
            , 10060259 --副号5元
            , 10060265  -- 副号5元200M
            , 10060261
            , 10060270
            , 334323
        , 10060268  -- 副号5元
        , 10060273  -- 副号5元
            )  )
            ;
            --select * from temp_33_clost_t1;
	--delete from temp_33_clost_t1 where offer_comp_type_desc6 not in 
	--('169全家版（12元关联包）_爱上','129全家版（12元关联包）_爱上','199全家版（42元关联包）_爱上','89全家版(2元关联包20M)','169全家版（12元关联包）')
	--	and acc_nbr in (select distinct acc_nbr from temp_33_clost_t1 where offer_comp_type_desc6 in
	--	('169全家版（12元关联包）_爱上','129全家版（12元关联包）_爱上','199全家版（42元关联包）_爱上','89全家版(2元关联包20M)','169全家版（12元关联包）'));
	-- 如果号码不含'i'字样, 删除iTV主套餐
        -- 20151218: 为查单产品准备单价, 删除全部全家版复合包.
        delete from temp_33_clost_t1 where offer_comp_type_desc6 in 
        ('169全家版（12元关联包）_爱上','129全家版（12元关联包）_爱上','199全家版（42元关联包）_爱上','89全家版(2元关联包20M)','169全家版（12元关联包）')
        ;
	delete from temp_33_clost_t1 where (not acc_nbr ~* 'i') and (offer_comp_type_desc6 ~* '电视' or offer_comp_type_desc6 ~* 'iTV');
	--delete from temp_33_clost_t1 where 主副卡='71000003';	-- 副卡不算酬金

            drop table if exists temp_33_clost_t2 ;
            create table temp_33_clost_t2 as 
            select b.* from 
            (select acc_nbr, max(prod_offer_inst_created_date) completed from temp_33_clost_t1  a group by 1) a
            left join temp_33_clost_t1 b on a.acc_nbr=b.acc_nbr and b.prod_offer_inst_created_date=a.completed;
            select * from temp_33_clost_t2 order by prod_offer_inst_exp_date desc;                    
            '''
	t1 = time.time()
	yield ''.join(header(url='batch4_base_detail', **kw))
	kw_n = my_tools.query_dict(**kw)
	#sql = '''select acc_nbr from %s a where acc_nbr in (%s); ''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	tbl_name += ymd
	#--sql = sql % (tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
        #kw['acc_nbr'] = kw['acc_nbr'].rstrip()  # 去掉后面多余的空行
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
                #print('dis_serial', dis_serial)
                # 要另文处理一个号码查出来多个主套餐的情况, 因为4G版E9是组合出来的,其宽带查出来有三个合法主套餐:58,169,iTV免费...要优先取169.
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是合同号,即营销客户编码.
	2.右边出来的是多行号码,与营销客户并不一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch4_base_detail.exposed = True

def batch5(*k, **kw):
	'''根据号码提某月优惠后费用'''

	sql = ''' --改为从“收入域－收入组成”表取数，包含所有列收收入，而非仅仅BSN
	select a.acc_nbr,sum(charge) amount 
	from ds_chn_prd_serv_{area}_{yyyymm} a
	--left join DS_CHN_PRD_CUST_{area}_{yyyymm} b on a.mkt_cust_code=b.mkt_cust_code
	left join DS_CHN_ACT_SERV_INCOME_{yyyymm} c on a.serv_id=c.serv_id
	where  a.acc_nbr in (%s)
	group by 1;
	'''
        sql = ''' -- 新版数据库, 自建临时表, 费用清单表名为latn_33_acct_item_month
        select acc_nbr, income_flag, source_sys_name, acct_item_type_desc3, acct_item_type_desc4, acct_item_type_desc5, charge, income_flag from latn_33_acct_item_{yyyymm} a where a.acc_nbr in (%s) 
        '''
	t1 = time.time()
	yield ''.join(header(url='batch5', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	#ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	sql = sql.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{yyyymm}', cherrypy.session.get('feemonth',''))
	sql = sql.replace('AREA', cherrypy.session.get('fengongshi',''))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi',''))
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		#dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		kw_n['right'] = cgi.escape('\n'.join('\t'.join(map(str,rec._data)) for rec in recs))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch5.exposed = True

def batch5_serv_fd(*k, **kw):
	'''根据号码提某月设备帐目费用'''

        sql = ''' -- 新版数据库, 自建临时表, 费用清单表名为latn_33_acct_item_month
        select acc_nbr, acc_nbr, mkt_chnl_name, mkt_grid_name, sum(price) price, sum(charge) charge from latn_33_acct_item_{yyyymm} a where a.acc_nbr in (%s) and income_flag=1 
        --and source_sys_name in ('CRM现收','BSN后付费','BSN调帐','BSN赠款')
        and source_sys_id not in ('450','431','840','460') -------排除代收视同销售、佣金分成、翼龙分成、代理商空中充值返费抵收 , 此处和设备查询处统一使用梁平分公司当前使用的收入来源和帐目排除口径. 帐目排除出售商品收入和房租收入.
        and acct_item_type_id3 not in  ('600105','600201','600112')  --此处排除3帐目为: 出售商品收入, 出售通信类商品收入, 出租房屋收入 
        and income_flag=1
        group by 1, 2, 3, 4 ;''' 
        
	t1 = time.time()
	yield ''.join(header(url='batch5_serv_fd', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	#ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	sql = sql.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{yyyymm}', cherrypy.session.get('feemonth',''))
	sql = sql.replace('AREA', cherrypy.session.get('fengongshi',''))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi',''))
	# 是否关联acct_item表查询时,合同号与设备号关系,要依据上一个月的数据?
	fee_month = cherrypy.session.get('feemonth','')
	if fee_month[-2:]=='01':
		last_month = str( int(fee_month)-89)
	else:
		last_month = str(int(fee_month)-1)
	sql = sql.replace('{last_month}', last_month)
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	# 输入为合同号,不经add_pro处理
	#acc_nbr = acc_nbr_query = map(lambda x:x.strip(), kw_n['acc_nbr'].splitlines())
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
        sql_time = time.time()
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
                sql_time = time.time()
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
        yield '其中SQL费时: %s' % (sql_time-t1)
	yield ''.join(footer())
batch5_serv_fd.exposed = True

def batch5_con(*k, **kw):
	'''根据号码提某月合同号优惠后费用'''

        sql = ''' --改为从“收入域－收入组成”表取数，包含所有列收收入，而非仅仅BSN
        select a.acc_nbr,sum(amount) amount 
        from ds_chn_prd_serv_AREA_FEEMONTH a
        left join DS_ACT_ACCT_ITEM_FEEMONTH c on c.acct_id=a.mkt_cust_id
        where a.acc_nbr in (%s)
        group by 1; '''
        sql = '''select a.acc_nbr, sum(b.charge) charge from latn_33_serv a
        left join tmp_33_acct_item_FEEMONTH b on a.serv_id=b.serv_id
        where a.acc_nbr in (%s)
        group by 1 ; '''
        sql = '''select a.acc_nbr, a.acct_code, count(distinct b.acc_nbr) count, sum(c.charge) charge
        from latn_33_serv_FEEMONTH a 
        left join latn_33_serv_FEEMONTH b on a.acct_code=b.acct_code
        left join latn_33_acct_item_FEEMONTH c on b.serv_id=c.serv_id
        where a.acc_nbr in (%s) 
        and source_sys_name not in ('ODS积分兑换','ODS积分收入','BSN赠款','SP分成结算(号百、增值)')
        group by 1, 2;
        -- 输出结果为: 合同号, 号码个数, 合同号金额'''
	t1 = time.time()
	yield ''.join(header(url='batch5_con', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	#ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	sql = sql.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{yyyymm}', cherrypy.session.get('feemonth',''))
	sql = sql.replace('AREA', cherrypy.session.get('fengongshi',''))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi',''))
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch5_con.exposed = True

def batch5_con_con(*k, **kw):
	'''根据合同号提某月合同号优惠后费用'''

        sql = '''select a.acct_code
        , sum(price) price, sum(c.charge) charge
        , count(distinct a.acc_nbr) count
        from latn_33_serv a 
        left join latn_33_acct_item_FEEMONTH c on a.serv_id=c.serv_id
        where a.acct_code in (%s) 
        -- and source_sys_name in ( 'CRM现收','BSN后付费','BSN调帐','BSN赠款')
        and source_sys_id not in ('450','431','840','460') -------排除代收视同销售、佣金分成、翼龙分成、代理商空中充值返费抵收 , 此处和设备查询处统一使用梁平分公司当前使用的收入来源和帐目排除口径. 帐目排除出售商品收入和房租收入.
        and c.income_flag=1 --# 列收
        and acct_item_type_id3 not in  ('600105','600201','600112')  --此处排除3帐目为: 出售商品收入, 出售通信类商品收入, 出租房屋收入 
        group by 1;
        -- 输出结果为: 合同号, 号码个数, 合同号金额'''
	t1 = time.time()
	yield ''.join(header(url='batch5_con_con', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	#ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	sql = sql.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{yyyymm}', cherrypy.session.get('feemonth',''))
	sql = sql.replace('AREA', cherrypy.session.get('fengongshi',''))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi',''))
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	#acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
        # 输入为合同号, 不经过add_pro转化格式
        acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
        acc_nbr = acc_nbr_query = [i.strip() for i in acc_nbr]
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acct_code and -1 or recs.acct_code.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch5_con_con.exposed = True

def batch5_con_mid(*k, **kw):
	'''根据合同号提某月合同号应收费用'''

        sql = '''
        select a.acct_code, sum(b.amount) charge from latn_33_mid_acct_day a 
        left join latn_33_mid_acct_item_mon_FEEMONTH b on a.acct_id=b.acct_id
        where a.acct_code in  (%s)
        group by 1;
        
        -- 此处口径与BSN费用查询处较为吻合, 而且对iVPN分摊付费的情况,能够正确查询.
        -- 输出结果为: 合同号, 号码个数, 合同号金额'''
	t1 = time.time()
	yield ''.join(header(url='batch5_con_mid', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	#ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	sql = sql.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{yyyymm}', cherrypy.session.get('feemonth',''))
	sql = sql.replace('AREA', cherrypy.session.get('fengongshi',''))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi',''))
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	#acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
        # 输入为合同号, 不经过add_pro转化格式
        acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
        acc_nbr = acc_nbr_query = [i.strip() for i in acc_nbr]
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acct_code and -1 or recs.acct_code.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch5_con_mid.exposed = True

def batch5_con_fd(*k, **kw):
	'''根据合同号提某月合同号指定帐目费用'''
	
	sql = ''' --改为从“收入域－收入组成”表取数，包含所有列收收入，而非仅仅BSN
	--用于丰都分公司员工报帐需要,提短信费,补收费总额
	select a.mkt_cust_code, 
	sum(case when d.acct_item_type_desc3='短信' then amount else 0 end) 短信费,
	sum(case when d.acct_item_type_desc5='补收费' then amount else 0 end) 补收费
	,sum(case when d.acct_item_type_desc5='承诺消费补差' then amount else 0 end) 承诺消费补差
	,sum(case when d.acct_item_type_desc5='补贴承诺消费' then amount else 0 end) 补贴承诺消费 
	,sum(amount) 总费用
	--因过户是次月生效,所以,要得到与BSN相符的费用, 取serv_id与mkt_cust_code的关系应该使用上个月的用户表
	from ds_chn_prd_serv_{area}_{last_month} a
	left join DS_ACT_ACCT_ITEM_{yyyymm} c on a.serv_id=c.serv_id -- and bill_flag_id=1
	left join DIM_CHN_ACCT_ITEM_TYPE d on c.acct_item_type_id=d.acct_item_type_id5
	where  a.mkt_cust_code in (%s)
	--and a.serv_num=1
	--and income_flag=1
	group by 1;
	'''
	t1 = time.time()
	yield ''.join(header(url='batch5_con_fd', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	#ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	sql = sql.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{yyyymm}', cherrypy.session.get('feemonth',''))
	sql = sql.replace('AREA', cherrypy.session.get('fengongshi',''))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi',''))
	# 是否关联acct_item表查询时,合同号与设备号关系,要依据上一个月的数据?
	fee_month = cherrypy.session.get('feemonth','')
	if fee_month[-2:]=='01':
		last_month = str( int(fee_month)-89)
	else:
		last_month = str(int(fee_month)-1)
	sql = sql.replace('{last_month}', last_month)
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	# 输入为合同号,不经add_pro处理
	acc_nbr = acc_nbr_query = map(lambda x:x.strip(), kw_n['acc_nbr'].splitlines())
	#acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.mkt_cust_code and -1 or recs.mkt_cust_code.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch5_con_fd.exposed = True

def batch5_con_pay(*k, **kw):
	'''根据合同号提某月实际付款'''
	
	sql = '''
		select a.mkt_cust_code, payment_date 缴费时间, sum(b.bill_amount) 本金, sum(b.late_fee) 滞纳金, min(billing_cycle_id) 最早帐期 from ds_chn_prd_serv_AREA_FEEMONTH a 
		left join ds_act_bill_FEEMONTH b on a.serv_id=b.serv_id
		--where a.acc_nbr in ('18983306330',
		where a.mkt_cust_code in (%s)
		and b.state='5JB' --销帐
		group by 1, 2
		limit 3000;
		'''
        sql = '''select a.acct_code mkt_cust_code, sum(b.amount) from 
        -- 1. 一个月有可能有多笔缴费记录, 比如每月费用分开打发票等,所以要sum
        -- 2. 有可能返销, 所以取state=5JA
        -- 按1025382399合同号在201412的返销记录推算, 应是: state: 5JB 销账, 5JC 被返销, 5JD 返销； operation_type: 5KB 返销, 5KA 销账
        (select distinct acct_code, acct_id from wid_chn_prd_serv_mkt_day_33 where acct_code in (%s) ) a  -- 为了查询呆坏帐等, 只好直接取重庆的用户表
        --(select distinct acct_code, acct_id from latn_33_serv where acct_code in (s) ) a 
        left join MID_PAYMENT_FINANCE_MON b on a.acct_id=b.acct_id and b.payment_date like 'FEE_MONTH%%%%' and state='5JB'
        group by 1 ;
        '''
	t1 = time.time()
	yield ''.join(header(url='batch5_con_pay', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	#ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	sql = sql.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{yyyymm}', cherrypy.session.get('feemonth',''))
	sql = sql.replace('AREA', cherrypy.session.get('fengongshi',''))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi',''))
	# 是否关联acct_item表查询时,合同号与设备号关系,要依据上一个月的数据?
	feemonth = cherrypy.session.get('feemonth','')
	if feemonth[-2:]=='01':
		last_month = str( int(feemonth)-89)
	else:
		last_month = str(int(feemonth)-1)
	sql = sql.replace('{last_month}', last_month)
        sql = sql.replace('FEE_MONTH', feemonth[:4]+'-'+feemonth[4:6])
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	# 输入为合同号,不经add_pro处理
	acc_nbr = acc_nbr_query = map(lambda x:x.strip(), kw_n['acc_nbr'].splitlines())
	#acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.mkt_cust_code and -1 or recs.mkt_cust_code.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch5_con_pay.exposed = True

def batch5_con_balan(*k, **kw):
	'''根据合同号提某月余额转账'''
	
	sql = '''
		select a.mkt_cust_code, payment_date 缴费时间, sum(b.bill_amount) 本金, sum(b.late_fee) 滞纳金, min(billing_cycle_id) 最早帐期 from ds_chn_prd_serv_AREA_FEEMONTH a 
		left join ds_act_bill_FEEMONTH b on a.serv_id=b.serv_id
		--where a.acc_nbr in ('18983306330',
		where a.mkt_cust_code in (%s)
		and b.state='5JB' --销帐
		group by 1, 2
		limit 3000;
		'''
        sql = '''select distinct acct_code mkt_cust_code, amount, oper_date 
        from latn_33_serv a 
        left join mid_balance_source_finance_mon b on a.acct_id=b.object_id and b.oper_date like 'FEE_MONTH%%%%'
        where a.acct_code in (%s);
        '''
	t1 = time.time()
	yield ''.join(header(url='batch5_con_balan', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	#ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	sql = sql.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{yyyymm}', cherrypy.session.get('feemonth',''))
	sql = sql.replace('AREA', cherrypy.session.get('fengongshi',''))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi',''))
	# 是否关联acct_item表查询时,合同号与设备号关系,要依据上一个月的数据?
	feemonth = cherrypy.session.get('feemonth','')
	if feemonth[-2:]=='01':
		last_month = str( int(feemonth)-89)
	else:
		last_month = str(int(feemonth)-1)
	sql = sql.replace('{last_month}', last_month)
        sql = sql.replace('FEE_MONTH', feemonth[:4]+'-'+feemonth[4:6])
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	# 输入为合同号,不经add_pro处理
	acc_nbr = acc_nbr_query = map(lambda x:x.strip(), kw_n['acc_nbr'].splitlines())
	#acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.mkt_cust_code and -1 or recs.mkt_cust_code.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch5_con_balan.exposed = True

def batch6(*k, **kw):
	'''根据合同号提某月优惠后费用'''

	sql = ''' --改为从“收入域－收入组成”表取数，包含所有列收收入，而非仅仅BSN
	select a.mkt_cust_code,sum(charge) amount 
	from DS_CHN_PRD_CUST_{area}_{yyyymm} a left join DS_CHN_ACT_SERV_INCOME_{yyyymm} b on a.mkt_cust_id=b.mkt_cust_id
	 where b.mkt_area_id ='{area}' and a.mkt_cust_code in (%s)
	 group by 1;
	'''
	t1 = time.time()
	yield ''.join(header(url='batch6', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	#ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	sql = sql.replace('{yyyymm}', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi',''))
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	acc_nbr = acc_nbr_query = map(lambda x: x.strip(), kw_n['acc_nbr'].splitlines())
	acc_nbr = map(lambda x:repr(x), acc_nbr)
	#print ','.join(acc_nbr)
	#print map(len, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.mkt_cust_code and -1 or recs.mkt_cust_code.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.mkt_cust_code))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch6.exposed = True

def batch4_c(*k, **kw):
	'''提在用C网号码主优惠商品'''

	sql = ''' --提C网号码有效商品包的列表,排除c_not.txt文件里的非主要优惠商品
	select a.acc_nbr
	--,d.offer_comp_type_desc4 name4, d.offer_comp_type_desc6 name6
	,pg_concat( distinct d.offer_comp_type_desc4||'|') name4, pg_concat( distinct d.offer_comp_type_desc6||'|') name6
	from ds_chn_prd_serv_{area}_FEEMONTH a 
	left join  ds_prd_offer_comp_detail b on a.serv_id=b.serv_id
	and b.prod_offer_inst_state='00A' -- and b.offer_kind not in ('0')
	left join DIM_WD_OFFER_NEW_DIR_SECOND d on b.offer_comp_id=d.offer_comp_type_id6 
	and d.base_flag=1 
	where a.acc_nbr in (%s)
	and d.offer_comp_type_desc6 not in (%s)
	group by 1
	;
	'''
	t1 = time.time()
	yield ''.join(header(url='batch4_c', **kw))
	kw_n = my_tools.query_dict(**kw)
	#sql = '''select acc_nbr from %s a where acc_nbr in (%s); ''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('%Y%m%d')
	tbl_name += ymd
	#sql = sql % (tbl_name, '%s', '%s')
	c_n_file = os.path.join(os.path.dirname(__file__),'c_not.txt')
	c_not = open(c_n_file).read().replace('|',' ').split()
	c_not = list(set(c_not))
	c_not = ','.join(map(repr, c_not))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi','33'))
	sql = sql.replace('{yyyymmdd}', ymd)
	sql = sql.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	sql = sql % ('%s', c_not)
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print recs.acc_nbr, 'acc_nr'
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[0:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是合同号,即营销客户编码.
	2.右边出来的是多行号码,与营销客户并不一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch4_c.exposed = True

def batch4_c_lost(*k, **kw):
	'''提拆机C网号码主优惠商品'''

	sql = ''' --提已拆机C网号码有效商品包的列表,排除c_not.txt文件里的非主要优惠商品
	select a.acc_nbr
	--,d.offer_comp_type_desc4 name4, d.offer_comp_type_desc6 name6
	,pg_concat( distinct d.offer_comp_type_desc3||'|') name3
	,pg_concat( distinct d.offer_comp_type_desc4||'|') name4
	, pg_concat( distinct d.offer_comp_type_desc6||'|') name6
	from ds_chn_prd_serv_{area}_{yyyymmdd} a 
	left join  ds_prd_offer_comp_detail b on a.serv_id=b.serv_id
	and b.prod_offer_inst_state<>'00A' -- and b.offer_kind not in ('0')
	left join DIM_WD_OFFER_NEW_DIR_SECOND d on b.offer_comp_id=d.offer_comp_type_id6 
	and d.base_flag=1 
	where a.acc_nbr in (%s)
	and d.offer_comp_type_desc6 not in (%s)
	group by 1
	;
	'''
	t1 = time.time()
	yield ''.join(header(url='batch4_c_lost', **kw))
	kw_n = my_tools.query_dict(**kw)
	#sql = '''select acc_nbr from %s a where acc_nbr in (%s); ''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('%Y%m%d')
	tbl_name += ymd
	#sql = sql % (tbl_name, '%s', '%s')
	c_n_file = os.path.join(os.path.dirname(__file__),'c_not.txt')
	c_not = open(c_n_file).read().replace('|',' ').split()
	c_not = list(set(c_not))
	c_not = ','.join(map(repr, c_not))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi','33'))
	sql = sql.replace('{yyyymmdd}', ymd)
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	sql = sql % ('%s', c_not)
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print recs.acc_nbr, 'acc_nr'
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[0:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是合同号,即营销客户编码.
	2.右边出来的是多行号码,与营销客户并不一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch4_c_lost.exposed = True

def batch4_adsl(*k, **kw):
	'''提在用宽带主优惠商品'''

	sql = ''' --提在用宽带的主商品包的,排除adsl_not.txt文件里的非主要优惠商品
	select a.acc_nbr
	--,d.offer_comp_type_desc4 name4, d.offer_comp_type_desc6 name6
	,pg_concat( distinct d.offer_comp_type_desc4||'|') name4, pg_concat( distinct d.offer_comp_type_desc6||'|') name6
	from ds_chn_prd_serv_{area}_{yyyymmdd} a 
	left join  ds_prd_offer_comp_detail b on a.serv_id=b.serv_id
	and b.prod_offer_inst_state='00A' -- and b.offer_kind not in ('0')
	left join DIM_WD_OFFER_NEW_DIR_SECOND d on b.offer_comp_id=d.offer_comp_type_id6 
	and d.base_flag=1 
	where a.acc_nbr in (%s)
	and d.offer_comp_type_desc6 not in (%s)
	group by 1
	;
	'''
	t1 = time.time()
	yield ''.join(header(url='batch4_adsl', **kw))
	kw_n = my_tools.query_dict(**kw)
	#sql = '''select acc_nbr from %s a where acc_nbr in (%s); ''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('%Y%m%d')
	tbl_name += ymd
	#sql = sql % (tbl_name, '%s', '%s')
	c_n_file = os.path.join(os.path.dirname(__file__),'adsl_not.txt')
	c_not = open(c_n_file).read().replace('|',' ').split()
	c_not = list(set(c_not))
	c_not = ','.join(map(repr, c_not))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi','33'))
	sql = sql.replace('{yyyymmdd}', ymd)
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	sql = sql % ('%s', c_not)
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print recs.acc_nbr, 'acc_nr'
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[0:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(recs.acc_nbr))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是宽带号码,即营销客户编码.
	2.右边出来的是多行号码,与营销客户并不一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch4_adsl.exposed = True

def batch7(*k, **kw):
	'''根据号码提某月话单张数及费用'''

	sql_gb = ''' create table DS_EVT_CALL_AREA_{area}_FEEMONTH_gb as 
	select calling_nbr calling_nbr, count(*) count, sum(charge) charge
	from 
	DS_EVT_CALL_AREA_{area}_FEEMONTH
	where com_area_id={area}
	--DS_EVT_CALL_AREA_{area}_FEEMONTH
	 group by 1
	distributed by (calling_nbr);
	select '33';
	'''
	sql = ''' 
	--如果不存在ds_evt_call_area_{area}_FEEMONTH_gb, 则自动先生成该表；
	--所以,当月结束后,一定要重跑该表. 方法是手工drop掉即可.
	select calling_nbr acc_nbr, count, charge
	from DS_EVT_CALL_AREA_{area}_FEEMONTH_gb
	where calling_nbr in (%s)
	;
	'''
        sql =  '''select acc_nbr, count, duration, charge from latn_33_cdr_mon_total_FEEMONTH where acc_nbr in (%s);
        -- 查询结果为: 话单张数, 通话时长合计(秒), 费用'''

	t1 = time.time()
	yield ''.join(header(url='batch7', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-8)).strftime('%Y%m%d')
	if ymd[:6] < cherrypy.session.get('feemonth',''):
		sql_gb = sql_gb.replace('DS_EVT_CALL_AREA_{area}_FEEMONTH','DS_EVT_CALL_AREA')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	sql_gb = sql_gb.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql_gb = sql_gb.replace('{area}', cherrypy.session.get('fengongshi',''))
	sql = sql.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi',''))
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	acc_nbr = acc_nbr_query = map(lambda x: x.strip(), kw_n['acc_nbr'].splitlines())
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(lambda x:repr(x), acc_nbr)
	#print ','.join(acc_nbr)
	#print map(len, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		# recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		try:
			recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		except:
			# 如果是当月,则去掉表的后缀(日累积表没有后缀), 否则替换月份和区域
			dbapi.Table(_sqlment = sql_gb, _sqlment_values=[])
			recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch7.exposed = True

def batch7_msg(*k, **kw):
	'''根据号码提某月短信话单张数'''

	sql_gb = ''' create table DS_EVT_CALL_AREA_{area}_FEEMONTH_gb as 
	select calling_nbr calling_nbr, count(*) count, sum(charge) charge
	from 
	DS_EVT_CALL_AREA_{area}_FEEMONTH
	where com_area_id={area}
	--DS_EVT_CALL_AREA_{area}_FEEMONTH
	 group by 1
	distributed by (calling_nbr);
	select '33';
	'''
	sql = ''' 
	--如果不存在ds_evt_call_area_{area}_FEEMONTH_gb, 则自动先生成该表；
	--所以,当月结束后,一定要重跑该表. 方法是手工drop掉即可.
	select calling_nbr acc_nbr, count, charge
	from DS_EVT_CALL_AREA_{area}_FEEMONTH_gb
	where calling_nbr in (%%s)
	;
	'''

        sql =  '''
        select billing_nbr acc_nbr, sum(total_meter) count from mid_cdr_mon
        where acct_month='FEEMONTH' and event_type_id in ('60836','60838')
        and billing_nbr in (%s)
        group by 1;
        -- 查询结果为: 话单张数, 通话时长合计(秒), 费用'''

	t1 = time.time()
	yield ''.join(header(url='batch7_msg', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-8)).strftime('%Y%m%d')
	if ymd[:6] < cherrypy.session.get('feemonth',''):
		sql_gb = sql_gb.replace('DS_EVT_CALL_AREA_{area}_FEEMONTH','DS_EVT_CALL_AREA')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	sql_gb = sql_gb.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql_gb = sql_gb.replace('{area}', cherrypy.session.get('fengongshi',''))
	sql = sql.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi',''))
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	acc_nbr = acc_nbr_query = map(lambda x: x.strip(), kw_n['acc_nbr'].splitlines())
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(lambda x:repr(x), acc_nbr)
	#print ','.join(acc_nbr)
	#print map(len, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		# recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		try:
			recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		except:
			# 如果是当月,则去掉表的后缀(日累积表没有后缀), 否则替换月份和区域
			dbapi.Table(_sqlment = sql_gb, _sqlment_values=[])
			recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch7_msg.exposed = True

def batch8(*k, **kw):
	'''根据合同号查资料'''

	t1 = time.time()
	yield ''.join(header(url='batch8', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''select %s from 
	(select a.*, b.mkt_channel_name, b.mkt_grid_name
	,db.com_channel_name, db.com_grid_name
	from DS_CHN_PRD_CUST_{AREA}_{yyyymm} a
	left join dim_zone_area b on a.mkt_grid_id=b.mkt_grid_id
	left join dim_zone_comm db on a.deputy_com_grid_id=db.com_grid_id
	where mkt_cust_code in (%s) 
	) a
	left join ds_chn_prd_serv_{AREA}_{yyyymm} b on a.mkt_cust_code=b.mkt_cust_code and b.product_id=102030001
	left join ds_chn_prd_serv_{AREA}_{yyyymm} c on a.mkt_cust_code=c.mkt_cust_code and c.product_id=208511177
	;''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('%Y%m%d')
	tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ('%s', tbl_name, tbl_cust, tbl_cust_code, '%s')
	sql = sql.replace('{yyyymmdd}', ymd)
	# 如果是当月,则取日表
	fee_month = cherrypy.session.get('feemonth','')
	if fee_month == ymd[:6]:
		sql = sql.replace('{yyyymm}',ymd)
	else:
		sql = sql.replace('{yyyymm}', fee_month)
	sql = sql.replace('{AREA}', cherrypy.session.get('fengongshi','33'))
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = acc_nbr_query = map(lambda x: x.strip(), kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['a.mkt_cust_code']+kw_n['dis_cols'])
		sql = sql % (kw_n['dis_cols'], ','.join(acc_nbr))
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.mkt_cust_code and -1 or recs.mkt_cust_code.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n

	dis_cols = 'a.mkt_cust_code  a.mkt_cust_name  user_ad_arrive_num  b.acc_nbr adsl  c.acc_nbr itv  mkt_channel_name  mkt_grid_name  deputy_acc_nbr  com_channel_name  com_grid_name  user_postn_arrive_num  cust_state'.split('  ') # 为了别名,是用2个空格分隔!
	cols_name = '营销客户编码 客户名称 ADS到达用户数 ADSL iTV 营销客户营维部 营销客户网格 代表号码 代表号码维护营维部 代表号码维护网格 普通电话到达用户数 客户状态'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch8.exposed = True

def batch_cust(*k, **kw):
	'''提同产权客户设备号码'''

	t1 = time.time()
	yield ''.join(header(url='batch_cust', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''--根据输入号码提其同产权客户下下宽带,手机号码
	select a.*,pg_concat(distinct b.acc_nbr||',') adsl, pg_concat(distinct c.acc_nbr||',') cdma from 
	(select acc_nbr,cust_id from  DS_CHN_PRD_SERV_COM_{AREA}_{yyyymmdd} where acc_nbr in (%s)
	) a
	left join ds_chn_prd_serv_com_{AREA}_{yyyymmdd} b on a.cust_id=b.cust_id and b.product_id=102030001  --adsl
	left join ds_chn_prd_serv_com_{AREA}_{yyyymmdd} c on a.cust_id=c.cust_id and c.product_id=208511296  --cdma
	group by 1,2
	;''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('%Y%m%d')
	tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ('%s', tbl_name, tbl_cust, tbl_cust_code, '%s')
	sql = sql.replace('{yyyymmdd}', ymd)
	sql = sql.replace('{AREA}', cherrypy.session.get('fengongshi','33'))
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	#acc_nbr = acc_nbr_query = map(lambda x: x.strip(), kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr): # and kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['a.mkt_cust_code']+kw_n['dis_cols'])
		#--sql = sql % (kw_n['dis_cols'], ','.join(acc_nbr))
		sql = sql % (','.join(acc_nbr),)
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = 'a.mkt_cust_code  a.mkt_cust_name  user_ad_arrive_num  b.acc_nbr adsl  c.acc_nbr itv  mkt_channel_name  mkt_grid_name  com_channel_name  com_grid_name'.split('  ')
	cols_name = '营销客户编码 客户名称 ADS到达用户数 ADSL iTV 营销客户营维部 营销客户网格 代表号码维护营维部 代表号码维护网格'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_cust.exposed = True

def batch_cust2acc(*k, **kw):
	'''提产权客户下设备号码'''

	t1 = time.time()
	yield ''.join(header(url='batch_cust2acc', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''--根据输入产权客户编码,提其下宽带,手机号码
	select a.cust_code,b.acc_nbr, b.product_id from DS_PTY_CUST_{yyyymmdd} a 
	left join DS_CHN_PRD_SERV_COM_{AREA}_{yyyymmdd} b on a.cust_id=b.cust_id and b.serv_num=1
	where a.cust_code in (%s);
	''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('%Y%m%d')
	tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ('%s', tbl_name, tbl_cust, tbl_cust_code, '%s')
	sql = sql.replace('{yyyymmdd}', ymd)
	sql = sql.replace('{AREA}', cherrypy.session.get('fengongshi','33'))
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = acc_nbr_query = map(lambda x: x.strip(), kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr): # and kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['a.mkt_cust_code']+kw_n['dis_cols'])
		#--sql = sql % (kw_n['dis_cols'], ','.join(acc_nbr))
		sql = sql % (','.join(acc_nbr),)
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.cust_code and -1 or recs.cust_code.index(x), acc_nbr_query)
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		kw_n['right'] = cgi.escape('\n'.join(['\t'.join(map(str,x._data)) for x in recs]))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = 'a.mkt_cust_code  a.mkt_cust_name  user_ad_arrive_num  b.acc_nbr adsl  c.acc_nbr itv  mkt_channel_name  mkt_grid_name  com_channel_name  com_grid_name'.split('  ')
	cols_name = '营销客户编码 客户名称 ADS到达用户数 ADSL iTV 营销客户营维部 营销客户网格 代表号码维护营维部 代表号码维护网格'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_cust2acc.exposed = True

def batch_uim(*k, **kw):
	'''根据uim卡号查号码'''

	t1 = time.time()
	yield ''.join(header(url='batch_uim', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''select col1,acc_nbr from DM_PRD_PD_DYNAMIC where col1 in (%s);''' 
        sql = '''select col1, acc_nbr, state_date from tmp_33_l_access where col1 in (%s) order by state_date desc; '''
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ('%s', tbl_name, tbl_cust, tbl_cust_code, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(lambda x:x, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and 1: #kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (','.join(acc_nbr))
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print sql.replace('\n','<br />')
		print len(recs)
		dis_serial = map(lambda x: x not in recs.col1 and -1 or recs.col1.index(x), acc_nbr_query)
		#print dis_serial
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = []
	cols_name = ''.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_uim.exposed = True

def batch_byte(*k, **kw):
	'''手机流量查询'''

	t1 = time.time()
	yield ''.join(header(url='batch_byte', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''select billing_nbr, count(*) count, sum(ceil((byte_in+byte_out)/1024/Cdr_Piece)) byte from 
	( select distinct * from TABLE_NAME where billing_nbr in (%s) and event_type_id in 
	(select event_type_id from map_group_event_type where group_event_type_id in ('7001','7003') and event_type_name not like '%%%%副卡%%%%' )
	) as a
	group by 1;''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-1)).strftime('_%Y%m%d')
	tbl_name = 'DS_EVT_PS_AREA'
	fee_month = cherrypy.session.get('feemonth','')
	fengs_id = cherrypy.session.get('fengongshi','33')
	#print ymd, fee_month
	if fee_month and not ymd[1:].startswith(fee_month): #不是查询当前月
		tbl_name += '_'
		tbl_name += fengs_id
		tbl_name += '_'
		tbl_name += fee_month
	#tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ( tbl_name, '%s')
	sql = sql.replace('TABLE_NAME', tbl_name)
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(lambda x:x, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and 1: #kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (','.join(acc_nbr))
		#print sql.replace('\n','<br />')
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print len(recs)
		dis_serial = map(lambda x: x not in recs.billing_nbr and -1 or recs.billing_nbr.index(x), acc_nbr_query)
		#print dis_serial
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = []
	cols_name = ''.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_byte.exposed = True

def batch_byte_all(*k, **kw):
	'''手机流量清单'''

	t1 = time.time()
	yield ''.join(header(url='batch_byte_all', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''select 
	serv_id, billing_nbr, byte_out,byte_in, charge, start_time, event_type_id
	--billing_nbr, count(*) count, sum(ceil((byte_in+byte_out)/1024)) byte 
	from (
	select distinct * from TABLE_NAME where billing_nbr in (%s) and event_type_id in 
	(select event_type_id from map_group_event_type where group_event_type_id in ('7001','7003') and event_type_name not like '%%%%副卡%%%%')
	--('60645', '60646', '60640', '60641', '60642', '60643', '60644', '60647', '60648', '60650', '60651', '60649', '60652', '60653', '60654', '60655', '60656', '60657',
	--'90175', '90176', '90170', '90171', '90172', '90173', '90174', '90177', '90178', '90180', '90181', '90179', '90182', '90183', '90184', '90185', '90186', '90187')
	) as a
	--group by 1
	;''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	tbl_name = 'DS_EVT_PS_AREA'
	fee_month = cherrypy.session.get('feemonth','')
	fengs_id = cherrypy.session.get('fengongshi','33')
	#print ymd, fee_month
	if fee_month and not ymd[1:].startswith(fee_month): #不是查询当前月
		tbl_name += '_'
		tbl_name += fengs_id
		tbl_name += '_'
		tbl_name += fee_month
	#tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ( tbl_name, '%s')
	sql = sql.replace('TABLE_NAME', tbl_name)
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(lambda x:x, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and 1: #kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (','.join(acc_nbr))
		#print sql.replace('\n','<br />')
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print len(recs)
		dis_serial = map(lambda x: x not in recs.billing_nbr and -1 or recs.billing_nbr.index(x), acc_nbr_query)
		#print dis_serial
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: '\t'.join(map(str,x._data)), recs)))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = []
	cols_name = ''.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_byte_all.exposed = True

def batch_byte_tc(*k, **kw):
	'''手机套餐内流量'''

	t1 = time.time()
	yield ''.join(header(url='batch_byte_tc', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = ''' select acc_nbr, sum(rate) rate,pg_concat(offer_name||',') names from 
	(
	select * from ds_chn_prd_serv_{area}_{yyyymm} a 
	left join ds_prd_offer_comp_detail b on a.serv_id=b.serv_id and b.prod_offer_inst_state='00A'
	left join (
	-- 套餐与流量配置关系,不完全,请大家提出增加
	select '331578' prod_offer_id, 30 rate ,'0元包30M流量' offer_name union
	select '331445', 200,'3G下乡购3G送200M_基础包' union --
	select '1318430', 50,'单】手机上网5元包50M可选包（新立即老次月）_基础包' union --
	select '330365', 150,'手机上网150M免费（三个月）_基础包' union --
	select '329523', 30,'手机上网30M免费_基础包' union --
	select '327926', 2048,'手机上网包100元包2G_基础包' union --
	select '327337', 60,'手机上网包10元包60M' union --
	select '327918', 60,'手机上网包10元包60M_基础包' union --
	select '327339', 300,'手机上网包30元包300M' union --
	select '327922', 300,'手机上网包30元包300M_基础包' union --
	select '327340', 800,'手机上网包50元包800M' union --
	select '327924', 800,'手机上网包50元包800M_基础包' union --
	select '327915', 30,'手机上网包5元包30M_基础包' union --
	select '323848', 512,'员工3G赠送流量包500M(电信)_基础包' union --
	select '329228', 200,'智领3G翼起来赠送流量包(享200M)_基础包' union --
	select '326619', 200,'智领3G翼起来赠送流量包_基础包' union --
	select '327975', 100,'智领3G赠送100M流量_基础包' union --
	select '330885', 200,'201108上网版49元_基础包' union --
	select '330899', 300,'201108上网版69元_基础包' union --
	select '330902', 400,'201108上网版89元_基础包' union --
	select '330905', 600,'201108上网版129元_基础包' union --
	select '330908', 750,'201108上网版159元_基础包' union --
	select '330911', 1024,'201108上网版189元_基础包' union --
	select '330914', 1024*1.5,'201108上网版289元_基础包' union --
	select '330917', 2048,'201108上网版389元_基础包' union --
	select '330920', 3072,'201108上网版489元_基础包' union --
	select '330923', 4096,'201108上网版589元_基础包' union --
	select '330926', 60,'201108聊天版59元_基础包' union --
	select '330931', 120,'201108聊天版89元_基础包' union --
	select '330940', 120,'201108聊天版129元_基础包' union --
	select '330944', 120,'201108聊天版159元_基础包' union --
	select '330947', 120,'201108聊天版189元_基础包' union --
	select '330950', 120,'201108聊天版389元_基础包' union --
	select '327407', 20,'天翼畅聊19套餐_基础包' union --
	select '327417', 20,'天翼畅聊39套餐_基础包' union --
	select '330839', 20,'T9套餐19元/月_基础包' union --
	select '330852', 20,'T9套餐39元/月_基础包' union --
	select '331559', 100,'智能机流量包赠送_基础包' 
	) c on b.prod_offer_id=c.prod_offer_id
	where a.acc_nbr in (%s) and c.prod_offer_id is not null and b.prod_offer_inst_eff_date<'NEXT_FEE_MONTH-01 00:00:00'
	) a group by 1 ;
	''' 

	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('%Y%m%d')
	tbl_name = 'DS_EVT_PS_AREA'
	fee_month = cherrypy.session.get('feemonth','')
	fengs_id = cherrypy.session.get('fengongshi','33')
	# sql = sql.replace('{yyyymm}', fee_month).
	sql = sql.replace('{area}', fengs_id)
	#print ymd, fee_month
	FEE_MONTH = fee_month[:4]+'-'+fee_month[4:]
	if fee_month[-2:]<>'12':
		NEXT_FEE_MONTH = fee_month[:4]+'-'+'%02d' % (int(fee_month[4:])+1)
	else:
		NEXT_FEE_MONTH = str(int(fee_month[:4])+1)+'-01'
	if fee_month and not ymd.startswith(fee_month): #不是查询当前月
		sql = sql.replace('{yyyymm}', fee_month)
		sql = sql.replace('NEXT_FEE_MONTH', NEXT_FEE_MONTH)
		sql = sql.replace('FEE_MONTH', FEE_MONTH)
		tbl_name += '_'
		tbl_name += fengs_id
		tbl_name += '_'
		tbl_name += fee_month
	else:
		sql = sql.replace('{yyyymm}', ymd)
		sql = sql.replace('NEXT_FEE_MONTH', NEXT_FEE_MONTH)
		sql = sql.replace('FEE_MONTH', FEE_MONTH)
	#tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ( tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(lambda x:x, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and 1: #kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (','.join(acc_nbr))
		#print sql.replace('\n','<br />')
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print len(recs)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		#print dis_serial
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = []
	cols_name = ''.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_byte_tc.exposed = True

def batch_esn(*k, **kw):
	'''手机型号历史查询'''

	t1 = time.time()
	yield ''.join(header(url='batch_esn', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''select * from dm_evt_termination_info_add_all where acc_nbr in (%s)order by acc_nbr, register_time desc; '''
        sql = '''select * from wid_zd_termination_info_MON where acc_nbr in (%s) order by acc_nbr, register_time desc;'''
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	tbl_name = 'DS_EVT_PS_AREA'
	fee_month = cherrypy.session.get('feemonth','')
	fengs_id = cherrypy.session.get('fengongshi','33')
	#print ymd, fee_month
	if fee_month and not ymd[1:].startswith(fee_month): #不是查询当前月
		tbl_name += '_'
		tbl_name += fengs_id
		tbl_name += '_'
		tbl_name += fee_month
	#tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ( tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(lambda x:x, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and 1: #kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (','.join(acc_nbr))
		#print sql.replace('\n','<br />')
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print len(recs)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		#print dis_serial
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: '\t'.join(map(str,x._data)), recs)))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = []
	cols_name = ''.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_esn.exposed = True

def batch_esn_last(*k, **kw):
	'''手机最近型号'''

	t1 = time.time()
	yield ''.join(header(url='batch_esn_last', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''
	--先取最大的注册时间

	--create temp table fd_ter as select * from WID_ZD_TERMINATION_INFO_MON where acc_nbr in (s) ;
	--create temp table fd_max as select acc_nbr, max(register_time) register_time from fd_ter group by 1;
	--select a.* from fd_ter a left join fd_max b on a.acc_nbr=b.acc_nbr and a.register_time=b.register_time where b.acc_nbr is not null;
        select * from wid_zd_termination_info_mon where acc_nbr in (%s) 
            order by register_time desc'''
	sql2 = '''
	select * from dm_evt_termination_info_add_all a where register_time=(select max(register_time) from dm_evt_termination_info_add_all where acc_nbr=a.acc_nbr);
	'''
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	tbl_name = 'DS_EVT_PS_AREA'
	fee_month = cherrypy.session.get('feemonth','')
	fengs_id = cherrypy.session.get('fengongshi','33')
	#print ymd, fee_month
	if fee_month and not ymd[1:].startswith(fee_month): #不是查询当前月
		tbl_name += '_'
		tbl_name += fengs_id
		tbl_name += '_'
		tbl_name += fee_month
	#tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ( tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(lambda x:x, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and 1: #kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (','.join(acc_nbr))
		#print sql.replace('\n','<br />')
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print len(recs)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		#print dis_serial
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: '\t'.join(map(str,x._data)), recs)))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = []
	cols_name = ''.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_esn_last.exposed = True

def batch_esn_xxx(*k, **kw):
	'''手机某月型号查询'''

	t1 = time.time()
	yield ''.join(header(url='batch_esn_xxx', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''--注意选择月份,选当前月份可以查最近的串号信息.
	select b.acc_nbr,b.esn, b.factory, b.type, b.register_time, system
	from (select acc_nbr,max(register_time) last_time from dm_evt_termination_info_add_all where acc_nbr in (%s) and register_time<'FEEMONTH' group by 1 order by acc_nbr) a
	left join dm_evt_termination_info_add_all b on a.acc_nbr=b.acc_nbr and a.last_time=b.register_time
	--left join ds_chn_prd_serv_{area}_{yyyymmdd} c on b.acc_nbr=c.acc_nbr 
	left join (select * from dm_evt_termination_info_add_all 
	union select 'HW-HUAWEI C8600', 'Android 2.2'
	union select 'HW-HUAWEI C8650+', 'Android 2.3'
	union select 'HTC-X515d', 'Android 2.3'
	union select 'LNV-LenovoA68e', 'Android 2.3'
	union select 'HTC-Z510d', 'Android 2.3'
	) ry on b.type=ry.phone_type
	--华为C8600在配置表中不正确,手工加上
	;'''
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi','33'))
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('%Y%m%d')
	sql = sql.replace('{yyyymmdd}', ymd)
	tbl_name = 'DS_EVT_PS_AREA'
	fee_month = cherrypy.session.get('feemonth','')
	fengs_id = cherrypy.session.get('fengongshi','33')
	#print ymd, fee_month
	if fee_month and not ymd.startswith(fee_month): #不是查询当前月
		sql = sql.replace('LAST_DAY', fee_month)
		tbl_name += '_'
		tbl_name += fengs_id
		tbl_name += '_'
		tbl_name += fee_month
	else:
		sql = sql.replace('LAST_DAY', ymd)
	# 要取截止feemonth月份底的串码,时间应为小于其次月的1日
	if fee_month[-2:] == '12':
		fee_month = str(int(fee_month)+89)
	else:
		fee_month = str(int(fee_month)+1)
	fee_month = fee_month[:4]+'-'+fee_month[4:]+'-01'
	sql = sql.replace('FEEMONTH', fee_month)
	#tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ( tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(lambda x:x, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and 1: #kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (','.join(acc_nbr))
		#print sql.replace('\n','<br />')
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print len(recs)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		#print dis_serial
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: '\t'.join(map(str,x._data)), recs)))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = []
	cols_name = ''.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_esn_xxx.exposed = True

def batch_esn_acc(*k, **kw):
	'''手机串码反查号码'''

	t1 = time.time()
	yield ''.join(header(url='batch_esn_acc', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''select * from dm_evt_termination_info_add_all where imei in (%s)order by imei, register_time desc; '''
        sql = '''select * from wid_zd_termination_info_MON where imei in (%s) order by imei, register_time desc;'''
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	tbl_name = 'DS_EVT_PS_AREA'
	fee_month = cherrypy.session.get('feemonth','')
	fengs_id = cherrypy.session.get('fengongshi','33')
	#print ymd, fee_month
	if 0: #fee_month and not ymd[1:].startswith(fee_month): #不是查询当前月
		tbl_name += '_'
		tbl_name += fengs_id
		tbl_name += '_'
		tbl_name += fee_month
	#tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ( tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(lambda x:x, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and 1: #kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (','.join(acc_nbr))
		#print sql.replace('\n','<br />')
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print len(recs)
		dis_serial = map(lambda x: x not in recs.imei and -1 or recs.imei.index(x), acc_nbr_query)
		#print dis_serial
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: '\t'.join(map(str,x._data)), recs)))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = []
	cols_name = ''.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_esn_acc.exposed = True

def batch_esn_acc_first(*k, **kw):
	'''手机串码反查号码_最早'''

	t1 = time.time()
	yield ''.join(header(url='batch_esn_acc_first', **kw))
	kw_n = my_tools.query_dict(**kw)

	sql = """
drop table if exists tmp_esc1;
create temp table tmp_esc1 as select distinct imei, acc_nbr, sequence_id, factory, type, version, register_time, net_system, os, serv_id, area_name1 
from wid_zd_termination_info_MON where imei in (%s) order by imei, register_time desc; 

create index tmp_esc1_x_ir on tmp_esc1(imei, register_time);

	select * from tmp_esc1  a
	where not exists (select * from tmp_esc1 b where a.imei=b.imei and b.register_time>a.register_time)
        """
       	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	tbl_name = 'DS_EVT_PS_AREA'
	fee_month = cherrypy.session.get('feemonth','')
	fengs_id = cherrypy.session.get('fengongshi','33')
	#print ymd, fee_month
	if 0: #fee_month and not ymd[1:].startswith(fee_month): #不是查询当前月
		tbl_name += '_'
		tbl_name += fengs_id
		tbl_name += '_'
		tbl_name += fee_month
	#tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ( tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(lambda x:x, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and 1: #kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (','.join(acc_nbr))
		#print sql.replace('\n','<br />')
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print len(recs)
		dis_serial = map(lambda x: x not in recs.imei and -1 or recs.imei.index(x), acc_nbr_query)
		#print dis_serial
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: '\t'.join(map(str,x._data)), recs)))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = []
	cols_name = ''.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_esn_acc_first.exposed = True

def batch_zk1(*k, **kw):
	'''展开连续号码'''

	t1 = time.time()
	yield ''.join(header(url='batch_zk1', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''-- 应张可要求,展开左边用"-"间隔的连续号码
	select * from dm_evt_termination_info_add_all where esn in (%s)order by esn, register_time desc; '''
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	tbl_name = 'DS_EVT_PS_AREA'
	fee_month = cherrypy.session.get('feemonth','')
	fengs_id = cherrypy.session.get('fengongshi','33')
	#print ymd, fee_month
	if 0: #fee_month and not ymd[1:].startswith(fee_month): #不是查询当前月
		tbl_name += '_'
		tbl_name += fengs_id
		tbl_name += '_'
		tbl_name += fee_month
	#tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ( tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(lambda x:x, kw_n['acc_nbr'].splitlines())
	result = []
	for i in acc_nbr:
		i = i.strip()
		i = i.replace(' ','-').replace('\t','-')
		if not i.count('-'):
			result.append(i)
		else:
			try:
				start, end = map(int,i.split('-'))
				assert end>=start
				result.extend(map(str,range(start,end+1)))
			except:
				result.append(i)
	kw_n['right'] = cgi.escape('\n'.join(result))
	#acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if 0: #len(acc_nbr) and 1: #kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (','.join(acc_nbr))
		#print sql.replace('\n','<br />')
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print len(recs)
		dis_serial = map(lambda x: x not in recs.esn and -1 or recs.esn.index(x), acc_nbr_query)
		#print dis_serial
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: '\t'.join(map(str,x._data)), recs)))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = []
	cols_name = ''.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_zk1.exposed = True

def batch_ht(*k, **kw):
	'''批查合同号销帐'''

	t1 = time.time()
	yield ''.join(header(url='batch_ht', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''

select acc_nbr, a.payment_method,a.acct_month,sum(a.amount) amount, sum(late_fee) late_fee, sum(c.amount) amount2, min(min) min, max(max) max from (
select a.acct_code acc_nbr,payment_id, b.acct_month, b.payment_method , min(billing_cycle_id) min, max(billing_cycle_id) max, sum(bill_amount) amount
, sum(late_fee) late_fee
--, sum(c.amount)/count(distinct a.payment_id) amount 
from (
select distinct acct_id, acct_code from latn_33_serv where acct_code in (%s)
) a left join latn_33_MID_BILL_FINANCE_MON b on a.acct_id=b.acct_id and b.receipt_staff<>1015 --排除计算机中心1015工号批量抵扣
 group by 1, 2 , 3, 4 
 ) a 
left join MID_PAYMENT_FINANCE_MON c on a.payment_id=c.payment_id
group by 1, 2, 3;
        --  结果字段为: 合同号, 付款方式,付费月, 销帐金额, 滞纳金, 付款金额, 最早帐期,最晚帐期
        
	''' 
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	fee_month = '_'+cherrypy.session.get('feemonth',ymd[1:7])
	# 如果不是选取的当前月份,则采用月表,否则采取最近的日表数据
	#print '--', fee_month, ymd[:7]
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi','33'))
	sql = sql.replace('{yyyymm}', cherrypy.session.get('feemonth', ymd[1:7]))
	if fee_month == ymd[:7]:
		tbl_name += ymd
		tbl_cust += ymd
		tbl_cust_code += ymd
	else:
		tbl_name += fee_month
		tbl_cust += fee_month
		tbl_cust_code += fee_month
	#sql = sql % ('%s', tbl_name, tbl_cust, tbl_cust_code, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = acc_nbr_query = map(lambda x:x.strip(), kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	sql = sql % ','.join(acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if len(acc_nbr): # and kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		#sql = sql % (kw_n['dis_cols'], ','.join(acc_nbr))
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = ['acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'fxh_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "user_grp_type", "contact_tel", "deputy_acc_nbr", "a.state", 'a.serv_state', 'a.serv_num', 'a.completed_date', 'a.remove_date', 'billing_mode_id', 'cust.cust_name', 'cust.cust_address', 'billing_flag_id']
	cols_name = '用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 分线盒 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 用户战略分群 客户_联系电话 客户_代表号码 用户状态 设备状态 到达标志 竣工时间 拆机日期 计费模式 产权客户姓名 产权客户地址 公免标志'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	td2 = ''
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若选取的月份不是当前月,则用该月的月表.若是当前月,则采取最新的日表.
	6.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_ht.exposed = True

def batch_owe(*k, **kw):
	'''号码欠费情况'''

	sql = ''' 
	--如果不存在dm_act_owe_item_{area}_FEEMONTH_gb, 则自动先生成该表；
	--所以,当月结束后,一定要重跑该表. 方法是手工drop掉即可.
	select acc_nbr,fee_month, s_month,e_month, count, amount
	from latn_33_owe_day
	where acc_nbr in (%s)
	;
	'''
	t1 = time.time()
	yield ''.join(header(url='batch_owe', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	#ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	sql = sql.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{yyyymm}', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi',''))
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	#acc_nbr = acc_nbr_query = map(lambda x: x.strip(), kw_n['acc_nbr'].splitlines())
	#acc_nbr = map(lambda x:repr(x), acc_nbr)
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	#print ','.join(acc_nbr)
	#print map(len, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		# recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
                recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		#print recs._columns, 'COLUMN', len(recs)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_owe.exposed = True

def batch_staff(*k, **kw):
	'''反查工号和姓名'''

	t1 = time.time()
	yield ''.join(header(url='batch_staff', **kw))
	kw_n = my_tools.query_dict(**kw)
	sql = '''--用途: 根据收入预估处的员工标识,批查工号和姓名

	select party_role_id,staff_code,staff_desc from DIM_CRM_STAFF where party_role_id  in (%s) ; '''
        # 重新编写工号查询
        sql = """ -- 根据staff_id , 查询工号, 工号姓名, 所属组织名称.
        select staff_id, staff_code, staff_name, a.status_cd, org_name from dim_crm_staff a
        left join DIM_CRM_ORGANIZATION b on a.org_id=b.party_id
        where a.staff_id in (%s);
        """
	tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	tbl_cust = 'DS_CHN_PRD_CUST_'+cherrypy.session.get('fengongshi','33')
	tbl_cust_code = 'DS_PTY_CUST'
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('_%Y%m%d')
	tbl_name = 'DS_EVT_PS_AREA'
	fee_month = cherrypy.session.get('feemonth','')
	fengs_id = cherrypy.session.get('fengongshi','33')
	#print ymd, fee_month
	if 0: #fee_month and not ymd[1:].startswith(fee_month): #不是查询当前月
		tbl_name += '_'
		tbl_name += fengs_id
		tbl_name += '_'
		tbl_name += fee_month
	#tbl_name += ymd
	tbl_cust += ymd
	tbl_cust_code += ymd
	#sql = sql % ( tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	acc_nbr = acc_nbr_query = map(lambda x:x, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(repr, acc_nbr)
	if type(kw_n['dis_cols'])<>type([]):
		kw_n['dis_cols'] = [kw_n['dis_cols']]
	if 'rule_type' in kw_n['dis_cols']:
		renling = u"000 非链路规则;001 交接箱;002 配线架;003 分线盒;004 CRM母局;005 GIS局站;006 小区编码;007 链路用户号段规则;008 CRM局站;009 受理工号;010 综合配线箱"
		str_tmp = ' '.join([" when rule_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('rule_type')] = "case %s end" % str_tmp 
	if 'user_grp_type' in kw_n['dis_cols']:
		renling = u"10 政企客户;20 家庭客户;30 个人客户;-99 战略客户类别不详"
		str_tmp = ' '.join([" when user_grp_type='%s' then '%s'" % tuple(i.split()) for i in renling.split(';')])
		kw_n['dis_cols'][kw_n['dis_cols'].index('user_grp_type')] = "case %s end" % str_tmp 
	if len(acc_nbr) and 1: #kw_n['dis_cols']<>['']:
		kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % (','.join(acc_nbr))
		#print sql.replace('\n','<br />')
		recs = dbapi.Table(_table=tbl_name, _sqlment = sql, _sqlment_values=[], _values_1=False)
		#print len(recs)
		dis_serial = map(lambda x: int(x) not in recs.staff_id  and -1 or recs.staff_id.index(int(x)), acc_nbr_query)
		#print dis_serial, len(recs), ' '.join(acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial)))
		#kw_n['right'] = cgi.escape('\n'.join(map(lambda x: '\t'.join(map(str,x._data)), recs)))
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = []
	cols_name = ''.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>'''
	query_notice = '''查询说明:
	1.输入号码格式问题, 如是8位固定电话或无号宽带,则自动加"023-", 若是"2370708080"这种宽带(在电子表格中前置0被省掉,则自动加"023-0",以符合营维系统的号码规则.
	2.可以选择多个字段,用鼠标拖动选择,或者CTRL+鼠标点击单个选择,或者SHIFT+鼠标选择连续多个字段.
	3.输入区域的号码必须每行一个.结果区域中的顺序与输入区域中的一致,若某号码没有结果结果,则显示为空行.查询完成后,右侧区域的字段是以TAB分隔,并已经自动复制到剪贴表(相当于全选并按了CTRL+C), 此时直接在电子表格中粘贴,即可为电子表格追加字段.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_staff.exposed = True

def batch_balance(*k, **kw):
	'''查号码余额'''

	sql = ''' 
        --根据号码查余额, 目前指定查两种余额: 通用余额账本和翼校通学生套餐账本
        --结果为: 号码, 通用账本, 翼校通账本
        select a.acc_nbr, b.day_id, b.acct_id, b.balance tongyong, c.balance yixiaotong from latn_33_serv a left join latn_33_acct_balance b on a.acct_id=b.acct_id and b.balance_type_id=1 left join latn_33_acct_balance c on a.acct_id=c.acct_id and c.balance_type_id=103234 where a.acc_nbr in (%s); '''

	t1 = time.time()
	yield ''.join(header(url='batch_balance', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-8)).strftime('%Y%m%d')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	sql = sql.replace('FEEMONTH', cherrypy.session.get('feemonth',''))
	sql = sql.replace('{area}', cherrypy.session.get('fengongshi',''))
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
	acc_nbr = acc_nbr_query = map(lambda x: x.strip(), kw_n['acc_nbr'].splitlines())
	acc_nbr = acc_nbr_query = map(add_pro, kw_n['acc_nbr'].splitlines())
	acc_nbr = map(lambda x:repr(x), acc_nbr)
	#print ','.join(acc_nbr)
	#print map(len, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		# recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		try:
			recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		except:
			# 如果是当月,则去掉表的后缀(日累积表没有后缀), 否则替换月份和区域
			recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		dis_serial = map(lambda x: x not in recs.acc_nbr and -1 or recs.acc_nbr.index(x), acc_nbr_query)
		kw_n['right'] = cgi.escape('\n'.join(map(lambda x: x<>-1 and '\t'.join(map(str,recs[x]._data[1:])) or ' ',dis_serial))).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_balance.exposed = True

def batch_imp(*k, **kw):
	'''导入号码到临时表'''

	sql = ''' drop table if exists temp_33_acc;
        create table temp_33_acc ( acc varchar(120));
        insert into temp_33_acc values %s ;
        select * from temp_33_acc;
        '''

	t1 = time.time()
	yield ''.join(header(url='batch_imp', *k, **kw))
	kw_n = my_tools.query_dict(**kw)
	#tbl_name = 'DS_CHN_PRD_SERV_'+cherrypy.session.get('fengongshi','33')
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-8)).strftime('%Y%m%d')
	#tbl_name += ymd
	#sql = sql % (tbl_name, '%s')
	yield '<table border=2 width=100%%><tr><td colspan=3>sql语句模板:%s</td>' % sql.replace('\n','<br />')
	#acc_nbr = acc_nbr_query = kw_n['acc_nbr'].splitlines()
        acc_nbr = kw_n['acc_nbr'].splitlines()
        acc_nbr = ["('%s')" % x.strip() for x in acc_nbr]
	#print map(len, acc_nbr)
	if len(acc_nbr) and kw_n['dis_cols']<>['']:
		#kw_n['dis_cols'] = ','.join(['acc_nbr']+kw_n['dis_cols'])
		sql = sql % ','.join(acc_nbr)
		# recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		try:
			recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		except:
			# 如果是当月,则去掉表的后缀(日累积表没有后缀), 否则替换月份和区域
			recs = dbapi.Table(_sqlment = sql, _sqlment_values=[], _values_1=False)
		kw_n['right'] = cgi.escape('\n'.join(recs.acc)).decode('utf-8')
	yield '''<tr><td width="15%%" align="center"><form method="post" name=form2 >输入区域<br /><textarea name="acc_nbr" style="BBfloat:left;BBwidth:100%%;border:solid 3;margin:3;display:inline"" onfocus="document.form2.acc_nbr.select()">\n%(acc_nbr)s</textarea></td>''' % kw_n
	dis_cols = [] #'acc_nbr', 'user_name', 'prod_addr', 'mkt_channel_name', 'mkt_grid_name', 'com_channel_name', 'com_grid_name', 'rule_type', 'jjx_code', 'sub_exch_id', 'product_name', 'down_velocity', 'a.resid_flag', 'a.mkt_cust_code', "cust_grp_type", "contact_tel", "deputy_acc_nbr"]
	cols_name = ''.split() #'用户电话号码 用户名称 用户地址 营销线_营维部名称 营销线_网格名称 维护线_营维部名称 维护线_网格名称 维护线_链路认领规则名称 交接箱编码 母局名称 产品四级名称 带宽速率_下行 政企属性 营销客户编码 客户战略分群 客户_联系电话 客户_代表号码'.split()
	td2 = SELECT(OPTION(cols_name,value=dis_cols,selected=kw.get('dis_cols','')),name="dis_cols", size=len(dis_cols), multiple=[True], style="display:block")
	yield '<td width="15%%" align="center">选择输出字段<br />%s%s</td>' % (td2,INPUT(type="submit", value="提取"))
	yield '''<td with="70%%" align="center">结果区域<br /><textarea name=right style="border:solid 3px;BBwidth:45%%;margin:3" readonly onblur="selectAll()">%(right)s</textarea></td>''' % kw_n
	if kw_n['right'].strip():
		yield '''<script language="javascript">document.form2.right.select(); document.form2.right.focus();var d = document.form2.right.value; window.clipboardData.setData("text", d);</script>''' % kw_n
	query_notice = '''查询说明:
	1.左边输入的是电话号码,
	2.右边出来的是费用, 一一对应.
	4.查询速度:单个号码在5秒左右,因重庆未对postgresql进行适当的索引,本来应该是毫秒级；对多个号码,经测试,在一次查询3600个号码时,费时59秒.不建议一次查询上万个号码.
	5.若对查询字段有增加需求,或对此页面有其他建议,欢迎通过邮箱或电话提出.电话:707019430, 邮箱:yaoguangming@cq.chinatelecom.com.cn'''.replace('\n', '<br />')
	yield '%s' % TR(TD(query_notice, colspan=3))
	yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())
batch_imp.exposed = True

def default(*k, **kw):
	'''默认处理方法'''

	if len(k) >= 1 and k[0].decode('utf-8') in __all__:
            try:
		yield ''.join(dis_sub(*k, **kw))
            except:
                traceback.print_exc()
                yield 'error'
	else:
		yield '路径不存在!'
		yield '%s' % str(k)
		yield '%s' % chardet.detect(k[0]) #.decode('gb2312')
default.exposed = True

if __name__ == '__main__':
	'''使本目录可以作为一个单独的cherrypy应用进行运行
	需要注意的是,要做到此点,比如论坛中的交互url,全部要使用相对url'''
	conf = os.path.join(os.path.dirname(__file__),  '__init__.conf')
	Root = __import__(__file__[:-3])
	cherrypy.quickstart(Root, config=conf)

# $Log: __init__.py,v $
# Revision 1.0  2011-10-08 22:54:04+08  administrator
# Initial revision
#
