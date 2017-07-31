﻿# -*- coding: utf-8 -*-
# $Header: D:\\RCS\\D\\python_study\\cherrypy\\forum\\__init__.py,v 1.0 2011-10-08 22:54:04+08 administrator Exp administrator $
import sqlite3, os, chardet, MySQL, cherrypy, cgi, sys, xlrd, time, datetime, traceback, dbapi, threading, time, config
from HTMLTags import TR, TD, INPUT, SELECT, OPTION
exposed = True
name = '套餐分析'
__all__ = 'jg 1_1 1_2 2_1 2_2 3_1 3_2 5_1 5_2 7 10_1 10_2 11'.split()
__all_name = '生成竣工报表 PPT1_1 PPT1_2 PPT2_1 PPT2_2 PPT3_1 PPT3_2 PPT5_1 PPT5_2 PPT7 PPT10_1 PPT10_2 PPT11'.split()
__all_script = u'1.0.竣工报表.sql 1.1.sql 1.2.sql 2.1.sql 2.2.sql 3.1.sql 3.2.sql 5.1.sql 5.2.sql 7.sql 10.1.sql 10.2.sql 11.sql'.split()

def header(forum_url=".", **kw):
	'''论坛页眉,公用先调用的函数, 可以只在此处检查是否登录,而不用对每一个需要发布的函数都检查登录情况'''

	init_days = 2	# 此处设置次月几日才出帐
	fee_month = int((datetime.datetime.now()+datetime.timedelta(days=-init_days)).strftime('%Y%m'))-1
	fee_month = fee_month % 100 and str(fee_month) or str(fee_month-88)
	if 'feemonth' in kw or cherrypy.session.get('feemonth','')=='':
		cherrypy.session['feemonth'] = str(kw.get('feemonth',fee_month)) or fee_month
		raise cherrypy.HTTPRedirect(cherrypy.url())
	yield '<html><head><title>套餐分析</title><script language="JavaScript" src="/static_files/calendar.js"></script><link rel="Stylesheet" href="/static_files/k_base.css"></link></head><body>\n'
	#yield str(threading.currentThread().getName())
	yield '<form style="display:inline" name="form0" ><select name=feemonth onchange="document.form0.submit()">'
	months = ['201107', '201108','201109','201110','201111','201112']
	s_name, s_id = months,months
	yield '%s' % OPTION(s_name, value=s_id, selected=cherrypy.session.setdefault('feemonth',fee_month))
	yield '</select></form>'
	yield '<a href="%s/..">上级</a> | <a href="%s">返回首页</a>' % (forum_url, forum_url)
	for col in globals()['__all__']:
		yield ' | <a href="%s/%s">%s</a>' % (forum_url, col, __all_name[__all__.index(col)])
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
	yield ''.join(footer())
index.exposed = True


def packge_comm(name, *k, **kw):
	'''通用套餐分析查询函数, name为页面标识,据此根本全局数组找出脚本名称,临时表名称,结果名称'''

	area_id = cherrypy.session.get('fengongshi', '33')
	deal_id = config.dict_id[area_id] #'1022'
	name = str(name)
	t1 = time.time()
	fee_month = cherrypy.session.get('feemonth','')
	table_name = 'tmp_%s_%s_%s' % (name, area_id, fee_month)
	index = __all__.index(name)
	if len(k)==1 and k[0]=='导出结果':
		recs = dbapi.Table(_table=table_name, _page_size=-1)
		cherrypy.response.headers['Content-Type'] = 'application/octet-stream'
		cherrypy.response.headers['Content-Disposition'] = 'attachment;filename=%s.csv' % table_name
		yield ','.join(map(lambda x: '"%s"' % x.decode('utf-8').encode('gb2312'),recs._columns))+'\n'
		for rec in recs:
			yield ','.join(map(lambda x:'"%s"' % str(x).decode('utf-8').encode('gb2312', 'ignore'),rec._data))+'\n'
		return
	yield ''.join(header('.'*(len(k)+1), **kw))
	yield '<br />'.join(['<a href="%s/%s/%s">%s</a>' % (cherrypy.url(), "."*(len(k)+1),x,x) for x in '执行 重新执行 查看结果 导出结果'.split()])
	yield '<div>分公司id: %s, 分公司局向id: %s, 月份: %s, 结果表名: tmp_%s_%s_%s </div>' % (area_id, deal_id, fee_month, name , area_id, fee_month)
	print __name__, os.path.join(__name__, 'package_sql','1.sql')
	print __file__, os.path.abspath(__file__), os.path.join(os.path.dirname(__file__), '1.sql')
	filename = os.path.join(os.path.dirname(os.path.abspath(__file__)), u'package_sql',__all_script[index])
	print filename
	sql = open(filename).read().replace('\xef\xbb\xbf','').replace('AREA_ID', deal_id).replace('AREA', area_id).replace('FEEMONTH', fee_month).replace('PACKGE_NAME', name)
	sql = sql.decode(chardet.detect(sql)['encoding'], 'ignore').encode('utf-8', 'ignore')
	yield '<textarea style="width:95%%; height:300px; display:block">%s</textarea>' % sql
	if len(k)==1:
		if k[0] == '执行':
			rec = dbapi.Table(_sqlment=sql, _sqlment_values=[])
			yield '执行成功!'
		elif k[0] == '重新执行':
			sql = sql.replace('--drop', 'drop')
			rec = dbapi.Table(_sqlment=sql, _sqlment_values=[])
			yield '重新执行成功'
		elif k[0] == '查看结果':
			count = dbapi.Table(_table=table_name)._count()
			yield '查看执行结果'
			yield '<ul>结果表%s, 共有记录:%s</ul>' % (table_name, count)
			recs = dbapi.Table(_table=table_name, _page_size=20, _order="1")
			yield str(len(recs))
			yield '<table border=1>'
			yield '%s' % TR(TD(recs._columns))
			for rec in recs:
				yield '%s' % TR(TD(rec._data))
			yield '</table>'
	yield '查询费时:%s' % (time.time()-t1)
	yield ''.join(footer())

def default(*k, **kw):
	'''默认处理方法'''

	if len(k)>=1 and k[0] in __all__:
		yield ''.join(packge_comm(k[0], *k[1:], **kw))
		#yield ''.join(globals()[k[0]](*k[1:], **kw))
	else:
		yield '路径不存在!'
		yield '%s' % str(k)
		yield '%s' % chardet.detect(k[0]) #.decode('gb2312')
default.exposed = True

# $Log: __init__.py,v $
# Revision 1.0  2011-10-08 22:54:04+08  administrator
# Initial revision
#
