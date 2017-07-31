# -*- coding: utf-8 -*-
# $Header: D:\\RCS\\D\\python_study\\cherrypy\\forum\\__init__.py,v 1.0 2011-10-08 22:54:04+08 administrator Exp administrator $
import sqlite3, os, chardet, MySQL, cherrypy, cgi, sys, xlrd, time, datetime, traceback, dbapi, threading, time, config
from HTMLTags import TR, TD, INPUT, SELECT, OPTION
exposed = True
name = '稽核专题'
__all__ = 'elong1 elong2 elong3 elong4 elong5 elong6 elong8 elong9 elong10 el_3g_new el_3g_new_check el_3g_all jh_single_c'.split()
__all_name = '翼龙清单 翼龙稽核 e9清单 e9稽核 裸手机清单 天翼龙卡 非活跃手机 提速清单 丰都E8-58 手机节_新增手机 手机节新增稽核 手机节打标清单 稽核_单C后付费'.split()
__all_script = u'elong1.sql elong2.sql elong3.sql elong4.sql elong5.sql elong6.sql elong8.sql elong9.sql elong10.sql el_3g_new.sql el_3g_new_check.sql el_3g_all.sql jh_single_c.sql'.split()

def header(forum_url=".", url='', **kw):
	'''论坛页眉,公用先调用的函数, 可以只在此处检查是否登录,而不用对每一个需要发布的函数都检查登录情况'''

	if 'fengongshi' in kw or cherrypy.session.get('fengongshi','')=='':
		cherrypy.session['fengongshi'] = str(kw.get('fengongshi','33')) or '33'
		#print cherrypy.url()
		#print 'en', cherrypy.url().decode('utf-8')
		raise cherrypy.HTTPRedirect(cherrypy.url().decode('utf-8'))
	init_days = 2	# 此处设置次月几日才出帐
	fee_month = int((datetime.datetime.now()+datetime.timedelta(days=-init_days)).strftime('%Y%m'))-1
	fee_month = fee_month % 100 and str(fee_month) or str(fee_month-88)
	if 'feemonth' in kw or cherrypy.session.get('feemonth','')=='':
		cherrypy.session['feemonth'] = str(kw.get('feemonth',fee_month)) or fee_month
		raise cherrypy.HTTPRedirect(cherrypy.url().decode('utf-8'))
	yield '<html><head><title>套餐分析</title><script language="JavaScript" src="/static_files/calendar.js"></script><link rel="Stylesheet" href="/static_files/k_base.css"></link></head><body>\n'
	yield '<form style="display:inline" name="form0" ><select name=fengongshi onchange="document.form0.submit()">'
	s_name, s_id = config.dict_name.values(), config.dict_name.keys()
	yield '%s' % OPTION(s_name, value=s_id, selected=cherrypy.session.setdefault('fengongshi',''))
	yield '</select></form>'
	#yield str(threading.currentThread().getName())
	yield '<form style="display:inline" name="form1" ><select name=feemonth onchange="document.form1.submit()">'
	months = [fee_month]
	s_name, s_id = months,months
	yield '%s' % OPTION(s_name, value=s_id, selected=cherrypy.session.setdefault('feemonth',fee_month))
	yield '</select></form>'
	yield '<a href="%s/..">上级</a> | <a href="%s">返回首页</a>' % (forum_url, forum_url)
	for col in globals()['__all__']:
		yield url==col and ' | %s' % __all_name[__all__.index(col)] or ' | <a href="%s/%s">%s</a>' % (forum_url, col, __all_name[__all__.index(col)])
	yield '<hr />'

def footer():
	'''论坛页脚'''

	yield '\n</body></html>'

def index(**kw):
	'''论坛首页'''

	yield ''.join(header(**kw))
	yield '''
	本页为翼龙计划手机清单提取和稽核界面,可发现翼龙计划常见录入错误.
	步骤:1.先在"全清单表"里redo一次,重提全清单表
	2.在"简单统计"里redo一次,然后show可以查看一些统计数据,和错误列表.
	两个都均可以通过"download"下载清单数据.
	'''.replace('\n', '<br />\n')
	yield ''.join(footer())
index.exposed = True

def packge_comm(name, *k, **kw):
	'''通用套餐分析查询函数, name为页面标识,据此根本全局数组找出脚本名称,临时表名称,结果名称'''

	area_id = cherrypy.session.get('fengongshi', '33')
	deal_id = config.dict_id[area_id] #'1022'
	area_id3 = config.dict_id3[area_id]
	name = str(name)
	t1 = time.time()
	fee_month = cherrypy.session.get('feemonth','')
	table_name = 'tmp_%s_%s_%s' % (name, area_id, fee_month)
	index = __all__.index(name)
	if len(k)==1 and k[0]=='download':
		recs = dbapi.Table(_table=table_name, _page_size=-1, _order="1")
		cherrypy.response.headers['Content-Type'] = 'application/octet-stream'
		cherrypy.response.headers['Content-Disposition'] = 'attachment;filename=%s.csv' % table_name
		yield ','.join(map(lambda x: '"%s"' % x.decode('utf-8').encode('gb2312'),recs._columns))+'\n'
		for rec in recs:
			yield ','.join(map(lambda x:x is not None and '"%s"' % str(x).decode('utf-8').encode('gb2312', 'ignore') or '',rec._data))+'\n'
		return
	yield ''.join(header('.'*(len(k)+1), url=name, **kw))
	yield '<br />'.join(['<a href="%s/%s/%s">%s</a>' % (cherrypy.url(), "."*(len(k)+1),x,x) for x in 'show redo download'.split()])
	yield '<div>分公司id: %s, 分公司局向id: %s, 月份: %s, 结果表名: tmp_%s_%s_%s </div>' % (area_id, deal_id, fee_month, name , area_id, fee_month)
	filename = os.path.join(os.path.dirname(os.path.abspath(__file__)), u'elong_sql',__all_script[index])
	last_feemonth = str(int(fee_month)- (fee_month[:-2]=='01' and 89 or 1))
	#sql = open(filename).read().replace('\xef\xbb\xbf','').replace('AREA_ID', deal_id).replace('AREA', area_id).replace('FEEMONTH', fee_month).replace('PACKGE_NAME', name).replace('LAST_MONTH', last_feemonth)
	sql = open(filename).read().replace('\xef\xbb\xbf','').replace('AREA_ID3',area_id3).replace('AREA_ID', deal_id).replace('AREA', area_id).replace('FEEMONTH', fee_month).replace('PACKGE_NAME', name).replace('LAST_MONTH', last_feemonth)
	next_month_time = str(int(fee_month)+(fee_month[:-2]=='12' and 89 or 1))
	next_month_time = next_month_time[:4]+'-'+next_month_time[4:]+'-01 00:00:00'
	sql = sql.replace('NEXT_MONTH_TIME', next_month_time)
	if time.localtime()[3]>9:	# 12点以后更新昨天的数据, 上午取前天的
		late_days = 2
	else:	late_days = 3
	ymd = (datetime.datetime.now()+datetime.timedelta(days=-late_days)).strftime('%Y%m%d')
	sql = sql.replace('LAST_DAY',ymd)
	sql = sql.decode(chardet.detect(sql)['encoding'], 'ignore').encode('utf-8', 'ignore')
	yield '<textarea style="width:95%%; height:300px; display:block">%s</textarea>' % sql
	if len(k)==1 and k[0] == 'redo':
		dbapi.Table(_sqlment=sql, _sqlment_values=[])
		count = dbapi.Table(_table=table_name)._count() 
		yield '重新执行成功, 结果%s笔' % count
		del count
	if len(k)==1 and k[0] == 'show':
		try:
			count = dbapi.Table(_table=table_name)._count()
		except dbapi.psycopg2.ProgrammingError, e:
			dbapi.Table(_sqlment=sql, _sqlment_values=[])
			count = dbapi.Table(_table=table_name)._count() 
		except Exception, e:
			yield e
		yield '查看执行结果'
		yield '<ul>结果表%s, 共有记录:%s</ul>' % (table_name, count)
		recs = dbapi.Table(_table=table_name, _page_size=20, _order="1")
		yield str(len(recs))
		yield '<table border=1>'
		yield '%s' % TR(TD(recs._columns))
		for rec in recs:
			yield '%s' % TR(TD(rec._data))
		yield '</table>'
		try:
			del count, recs, rec
		except: pass
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
