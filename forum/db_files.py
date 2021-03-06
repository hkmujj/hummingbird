﻿# -*- coding: utf-8 -*-
# $Header: D:\\RCS\\D\\python_study\\cherrypy\\forum\\table.py,v 1.0 2011-10-08 22:53:55+08 administrator Exp administrator $

import os, sqlite3, MySQL, threading
dbfile = os.path.sep.join([os.path.dirname(os.path.abspath(__file__)),"moon.files"])
#print 'dbfile:', dbfile
# 线程池改造, 使每个对象在创建时,使用本线程创建的连接,并对本线程连接所产生的对象实例进行计数,以进行commit.
connect_pool = {}
class_count = {}

class table(MySQL.MyTable):
	"""用户表驱动接口类,一个数据库文件单设一个
	属性命名建议:为尽量不与数据库表的字段名称相冲突,属性命名都以_开头"""
	#_class_count = 0
	_error = 0
	_primary_key = 'id'
	def __init__(self, *k, **kw):
		"""the class to call when connect to table"""

		self.__dict__['_conn'] = connect_pool.setdefault(threading.currentThread().getName(), sqlite3.connect(dbfile))
		#table.conn.isolation_level = None     # 事务隔离等级，置为None则会每次执行自动提交。
		# 此设置非常影响速度,可以考虑此处设为事务,在每页最后调用一次conn.commit()
		##conn.row_factory = sqlite3.Row   # 加上这句才能使用列名来返回，但为了保持与Mysql的通用性，关掉此性能，使用MySQLdb开发模块MySQL
		self.__dict__['_conn'].text_factory = lambda x:x.decode('gb2312','ignore').encode('utf-8','ignore')
		#table.conn.text_factory = str	 # 加上这一句，否则出现“could not decode to UTF-8 column"错误
		self.__dict__['_cursor'] = self.__dict__['_conn'].cursor()
		if len(k) == 1:
			kw[self.__class__._primary_key] = k[0]
		elif len(k) > 1:
			raise KeyError, 'wrong of arguments number.'
		MySQL.MyTable.__init__(self, _cursor=self._cursor, **kw)
		class_count.setdefault(threading.currentThread().getName(), 0)
		class_count[threading.currentThread().getName()] += 1
	
	def __del__(self):
		"""when all the class is delete, close the cursor."""

		return
		class_count[threading.currentThread().getName()] -= 1
		if class_count[threading.currentThread().getName()] == 0:
			if self.__dict__['_conn'].total_changes > 0:	# 有改变动生,正处于一个事务中
				if table._error: 
					#print '事务回滚'
					self.__dict__['_conn'].rollback()
				else: 
					#print '执行事务%s...' % table.conn.total_changes
					self.__dict__['_conn'].commit()
			self.__dict__['_cursor'].close()
			#table._conn.close()

for _table in table(_table='sqlite_master', tbl_name='%', _values_1=False).tbl_name:
	exec("class %s(table):pass" % _table)

# $Log: table.py,v $
# Revision 1.0  2011-10-08 22:53:55+08  administrator
# Initial revision
#
