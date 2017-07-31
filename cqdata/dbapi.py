# -*- coding: utf-8 -*-
# $Header: D:\\RCS\\D\\python_study\\cherrypy\\forum\\Table.py,v 1.0 2011-10-08 22:53:55+08 administrator Exp administrator $

import os, sqlite3, MySQL, threading, psycopg2, cherrypy, config
#dbfile = os.path.sep.join([os.path.dirname(os.path.abspath(__file__)),"Table.db"])
conn_p_w = {}
for x,v in config.dict_pwd.items():
	conn_p_w[x] = (x+(x=='44' and '0002' or '0001'), v)
	#--偏长寿的工号是440002
connect_str = "host=136.6.246.132 user=%s password=%s dbname=cqdmkt"
connect_str = "host=136.6.160.196 user=%s password=%s dbname=cqdmkt"
connect_str = "host=136.6.160.222 user=%s password=%s dbname=cqdmkt_new"
# 使用了堡垒机以后的连接地址, 端口是每次变化的.
#connect_str = "host=136.21.225.176 user=330001 dbname=cqdmkt_new port=2479"
#print 'dbfile:', dbfile
# 线程池改造, 使每个对象在创建时,使用本线程创建的连接,并对本线程连接所产生的对象实例进行计数,以进行commit.
# 再次改造,以使每个分公司可以用自己的连接.
connect_pool = {}
class_count = {}

class Table(MySQL.MyTable):
	"""用户表驱动接口类,一个数据库文件单设一个
	属性命名建议:为尽量不与数据库表的字段名称相冲突,属性命名都以_开头"""
	#_class_count = 0
	_error = 0
	_primary_key = 'id'
	def __init__(self, *k, **kw):
		"""the class to call when connect to Table"""

		class_count.setdefault(threading.currentThread().getName(), 0)
		fengongshi = cherrypy.session.get('fengongshi','33')
		connect_s = connect_str  % tuple(conn_p_w[fengongshi])
		# 每个线程都打开新连接
		try:
			connect = self.__dict__['_conn']
			if connect.closed == 1:
				self.__dict__['_conn'] = connect_pool[threading.currentThread().getName()] = psycopg2.connect(connect_s)
                                #self.__dict__['_conn'].text_factory = str
                                self.__dict__['_conn'].set_client_encoding('utf8')  # 加上此句,可以使返回的编码转换为目标编码.
				class_count[threading.currentThread().getName()] = 0
			elif class_count[threading.currentThread().getName()]<>0:
				print '出错，连接已经打开，但类数量为0,即，上次类删完毕或出错时，没有执行关闭操作'
				raise
			else:
				self.__dict__['_conn'] = connect_pool[threading.currentThread().getName()]
		except:
			self.__dict__['_conn'] = connect_pool[threading.currentThread().getName()] = psycopg2.connect(connect_s)
                        #self.__dict__['_conn'].text_factory = str
                        self.__dict__['_conn'].set_client_encoding('utf8')
			class_count[threading.currentThread().getName()] = 0
		#self.__dict__['_conn'] = connect_pool.setdefault(threading.currentThread().getName(), psycopg2.connect(connect_s))
		#self.__dict__['_conn'] = conn_pool.setdefault(fengongshi, psycopg2.connect(connect_s))
		#self.__dict__['_conn'] = connect_pool.setdefault(threading.currentThread().getName(), psycopg2.connect(connect_str))
		#Table.conn.isolation_level = None     # 事务隔离等级，置为None则会每次执行自动提交。
		# 此设置非常影响速度,可以考虑此处设为事务,在每页最后调用一次conn.commit()
##			conn.row_factory = sqlite3.Row   # 加上这句才能使用列名来返回，但为了保持与Mysql的通用性，关掉此性能，使用MySQLdb开发模块MySQL
		#self.__dict__['_conn'].text_factory = lambda x:x.decode('gb2312','ignore').encode('utf-8','ignore')
		#Table.conn.text_factory = str	 # 加上这一句，否则出现“could not decode to UTF-8 column"错误
		self.__dict__['_cursor'] = self.__dict__['_conn'].cursor()
		if len(k) == 1:
			kw[self.__class__._primary_key] = k[0]
		elif len(k) > 1:
			raise KeyError, 'wrong of arguments number.'
		try:
			MySQL.MyTable.__init__(self, _cursor=self._cursor, **kw)
		except:
			class_count.setdefault(threading.currentThread().getName(), 0)
			class_count[threading.currentThread().getName()] = 0 
			del connect_pool[threading.currentThread().getName()]
			raise
		class_count[threading.currentThread().getName()] += 1
	
	def __del__(self):
		"""when all the class is delete, close the cursor."""

		class_count[threading.currentThread().getName()] -= 1
		if class_count[threading.currentThread().getName()] == 0:
			if 1: #self.__dict__['_conn'].total_changes > 0:	# 有改变动生,正处于一个事务中
				if Table._error: 
					#print '事务回滚'
					self.__dict__['_conn'].rollback()
				else: 
					#print '执行事务%s...' % Table.conn.total_changes
					self.__dict__['_conn'].commit()
				self.__dict__['_cursor'].close()
				self.__dict__['_conn'].close()
				del connect_pool[threading.currentThread().getName()]
		#self.__dict__['_cursor'].close()
			#Table._conn.close()

__all__ = ['ds_chn_prd_serv_33_201109']
#for _table in Table(_table='sqlite_master', tbl_name='%', _values_1=False).tbl_name:
#	exec("class %s(Table):pass" % _table)
for _table in __all__:
	exec("class %s(Table): pass" % _table)

# $Log: Table.py,v $
# Revision 1.0  2011-10-08 22:53:55+08  administrator
# Initial revision
#
