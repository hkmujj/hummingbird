# -*- coding: utf-8 -*-
# $Header: D:\\hummingbird\\RCS\\test_session.py,v 1.0 2013-03-13 17:14:24+08 administrator Exp administrator $

import cherrypy, os, sys, cgi, time

class Root(object):
	'''test'''

	def index(self):

		yield 'index'
	index.exposed = True

	def block(self):
		yield 'bl'
		time.sleep(5)
		yield 'ock'
	block.exposed = True

	def set_sess(self):
		cherrypy.session['tmp'] = 'tmp'
		yield 'set session '
	set_sess.exposed = True

if __name__ == '__main__':
	conf = os.path.join(os.path.dirname(__file__),  '__init__.conf')
	cherrypy.quickstart(Root(), config=conf)
else:
	pass
	#cherrypy.tree.mount(Event(), config=conf)

# 注意要点
# 注意,修改一个py文件,或者子目录更名,会导致主引擎重启.但新增加一个子目录,则不会发生.
# 修改文件后,文件中的未被捕捉的异常,会导致重启失败,主引擎退出,而不是运行时才通过网页表现出来.

# $Log: test_session.py,v $
# Revision 1.0  2013-03-13 17:14:24+08  administrator
# Initial revision
#
# Revision 1.2  2011-10-06 23:17:31+08  administrator
# 验证了可以通过自动搜索目录,将能import的目录暴露出来.
#
# Revision 1.1  2011-10-06 15:27:46+08  administrator
# 增加__init__方法,以供修改.
#
# Revision 1.0  2011-10-06 14:58:07+08  administrator
# Initial revision
#
