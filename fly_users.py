# -*- coding: utf-8 -*-
# $Header: D:\\RCS\\D\\python_study\\cherrypy\\forum\\Table.py,v 1.0 2011-10-08 22:53:55+08 administrator Exp administrator $

import os, sqlite3, MySQL
dbfile = os.path.sep.join([os.path.dirname(os.path.abspath(__file__)),"flying_users.sqlite3"])

class Table(MySQL.MyTable):
	"""用户表驱动接口类,一个数据库文件单设一个
	属性命名建议:为尽量不与数据库表的字段名称相冲突,属性命名都以_开头"""
	_class_count = 0
	_error = 0
	_primary_key = 'id'
	def __init__(self, *k, **kw):
		"""the class to call when connect to Table"""

		#if Table._class_count == 0:
		#import sqlite3 as sqlite
		#import apsw as sqlite
		#sqlite.connect = sqlite.Connection
		Table.conn = sqlite3.connect(dbfile)
		#Table.conn.isolation_level = None     # 事务隔离等级，置为None则会每次执行自动提交。
		# 此设置非常影响速度,可以考虑此处设为事务,在每页最后调用一次conn.commit()
##			conn.row_factory = sqlite3.Row   # 加上这句才能使用列名来返回，但为了保持与Mysql的通用性，关掉此性能，使用MySQLdb开发模块MySQL
		Table.conn.text_factory = lambda x:x.decode('gb2312','ignore').encode('utf-8','ignore')
		#Table.conn.text_factory = str	 # 加上这一句，否则出现“could not decode to UTF-8 column"错误
		# 一个原则是:python程序内部用unicode字符串,但输入输入以及保存,都转为utf-8编码.
		# 但对于sqlite3数据库, 如果想要使用sqlite3命令行工具,则需要保存时编码转为gb2312, 而text_factory的设置,就使用如上的lambda 函数.
		Table._cursor = Table.conn.cursor()
		if len(k) == 1:
			kw[self.__class__._primary_key] = k[0]
		elif len(k) > 1:
			raise KeyError, 'wrong of arguments number.'
		MySQL.MyTable.__init__(self, _cursor=Table._cursor, **kw)
		Table._class_count += 1
	
	def __del__(self):
		"""when all the class is delete, close the cursor."""

		Table._class_count -= 1
		if Table._class_count == 0:
			if Table.conn.total_changes > 0:	# 有改变动生,正处于一个事务中
				if Table._error: 
					#print '事务回滚'
					Table.conn.rollback()
				else: 
					#print '执行事务%s...' % Table.conn.total_changes
					Table.conn.commit()
					Table.conn.close()
			Table._cursor.close()
			#Table.conn.close()

for _table in Table(_table='sqlite_master', tbl_name='%', _values_1=False).tbl_name:
	exec("class %s(Table):pass" % _table)
del _table

# $Log: Table.py,v $
# Revision 1.0  2011-10-08 22:53:55+08  administrator
# Initial revision
#
