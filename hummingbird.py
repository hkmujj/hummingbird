# -*- coding: utf-8 -*-
# $Header: D:\\RCS\\D\\python_study\\cherrypy\\dragonfly.py,v 1.2 2011-10-06 23:17:31+08 administrator Exp administrator $

# 用cherrypy驱动一个目录的启动脚本

if __name__ == '__main__':
	import cherrypy, os, my_tools
	conf = os.path.abspath(__file__)[:-2]+'conf'
	Root = my_tools.Import_dir(os.path.dirname(os.path.abspath(__file__)))
	cherrypy.quickstart(Root, config=conf)

# $Log$
