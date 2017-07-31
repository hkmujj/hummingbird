# -*- coding: utf-8 -*-
# $Header: D:\\RCS\\D\\python_study\\cherrypy\\dragonfly.py,v 1.2 2011-10-06 23:17:31+08 administrator Exp administrator $

import os, sys, cgi, time, cherrypy, config, traceback
from HTMLTags import OPTION, TD, TABLE, TR, TH

name = 'easyui crud demo'

def index():

    return open(os.path.join(os.path.dirname(__file__),'index.html'))

index.exposed = True

def save_user(**kw):
    yield 'test'
save_user.exposed = True

def get_users():

    yield """{"total":"2","rows":[{"firstname":"a","lastname":"b","phone":"1234","email":"ab@com.co"},{"id":"144790","firstname":"b","lastname":"c","phone":"999","email":"a@b.com"}]}"""

get_users.exposed = True

def save_user():
    yield '{"OK"}'
save_user.exposed = True
# 注意要点
# 注意,修改一个py文件,或者子目录更名,会导致主引擎重启.但新增加一个子目录,则不会发生.
# 修改文件后,文件中的未被捕捉的异常,会导致重启失败,主引擎退出,而不是运行时才通过网页表现出来.

# $Log: dragonfly.py,v $
# Revision 1.2  2011-10-06 23:17:31+08  administrator
# 验证了可以通过自动搜索目录,将能import的目录暴露出来.
#
# Revision 1.1  2011-10-06 15:27:46+08  administrator
# 增加__init__方法,以供修改.
#
# Revision 1.0  2011-10-06 14:58:07+08  administrator
# Initial revision
#
