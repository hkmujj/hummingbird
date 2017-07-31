# -*- coding: utf-8 -*-
# $Header: D:\\RCS\\D\\python_study\\cherrypy\\dragonfly.py,v 1.2 2011-10-06 23:17:31+08 administrator Exp administrator $

if __name__ == '__main__':
    import os, my_tools
    print(os.path.abspath(__file__))
    conf = os.path.abspath(__file__)[:-2]+'conf'
    Root = my_tools.Import_dir(os.path.dirname(os.path.abspath(__file__)))
    print(conf)
    import cherrypy, sys
    cherrypy.quickstart(Root, config=conf)
    #sys.exit()

import os, sys, cgi, time, cherrypy, config, traceback, datetime
from HTMLTags import OPTION, TD, TABLE, TR, TH

name = '云飞信息管理系统'

def index():

    return open(os.path.join(os.path.dirname(__file__),'index.html'))
index.exposed = True

def top():
    return open(os.path.join(os.path.dirname(__file__),'top.html'))
top.exposed = True

def left():
    fast_a = '''<script type="text/javascript">function open_new(a,b,c){window.open(a,b,c);}</script><form name="myform"  style="display:inline"><select name="select" size= "1" onchange="open_new(this.options[this.selectedIndex].value, '_blank','');this .selectedIndex=0" style="background-colr: rgb(255,255,255); color:rgb(0,0,0);">%s </select></form>'''
    link = config.fast_a
    link = [i.split() for i in link.splitlines() if len(i.split()) in (2,3)]
    yield fast_a % OPTION([i[0] for i in link], value=[i[1] for i in link])
    for root, dirs, files in os.walk(os.path.basename(os.path.dirname(__file__)), top):
        if root == os.path.basename(os.path.dirname(__file__)):
            yield '<a href="/desktop" target="table_index">%s</a> <br />' % name
            continue
        root_n = '/'.join(root.split(os.path.sep)[1:])
        packge = '.'.join(root.split(os.path.sep))
        try:
            packge_name = sys.modules[packge]
        except:
            continue
        menu_name = getattr(packge_name, 'name', packge)
        yield '%s<a href="%s" target="table_index">%s </a><br />' % ( '&nbsp;'*root_n.count('/')*4, root_n, menu_name)
left.exposed = True

def left_hidden():
    return open(os.path.join(os.path.dirname(__file__),'left_hidden.html'))
left_hidden.exposed = True

def desktop():
    yield '<center><div style="color:red">本站不日将关闭, 请大家注意收藏需要的链接<br />'
    yield '本人将视情况推出新版本, 如果有, 新版本将严格身份认证, 并将用户名关联IP地址, MAC地址, 电脑的DNS名称, 并将数据集市的分公司权限按各分公司IP段隔离, 数据集市工号密码也将现场输入或保存在访问者客户端.<br />'
    yield '由此带来不便, 略表遗憾.<br /><br /><br /></div></center>'
    yield 'desktop'
    yield cherrypy.url()
    yield '<a href="/static_files/RVS_free.exe">RVS_free</a><br />'
    yield '<a href="/static_files/IE8-WindowsXP-x86-CHS.exe">IE8离线升级文件</a><br />'
    yield '<a href="/static_files/MingWebReport2.3Trial.zip">如意报表安装文件</a><br />'
    yield '<a href="/static_files/desktop.reg">将桌面和我的文档移到D:\system目录下的desktop和mydocs目录的注册表文件</a><br />'
    yield '<a href="/static_files/card_remote_write.rar">CRM远程写卡驱动和手册</a><br />'
    ip = cherrypy.request.remote.ip
    try:
        from fly_users import user
        user_cur = user(ip)
        if not len(user_cur) and ip:
            user_cur._insert()
        del user_cur
    except:
        print('IP error:', ip)
        print(traceback.print_exc())
    yield '曾经访问本站的IP列表:'
    users = user('%', _order='id', _values_1=False)
    yield '%s <br />' % len(users)
    for user_c in users:
        yield '%s<br />' % user_c.id
    import threading
    yield threading.currentThread().getName()
    for thread in threading.enumerate():
        yield '%s ' % thread.isAlive()
        yield '%s ' % thread.isDaemon()
        yield thread.getName()
        yield '<br />'
        if thread.getName()=='MainThread':
            yield 'haha'
            yield '%s' % dir(thread)
    yield '%s' % dir(thread)
    #yield '%s' % thread.requests_seen
    '''for key in ('stats','server'):
        yield key
        yield str(getattr(thread, key))
        yield '<br />'
    '''
desktop.exposed = True

def bottom():
    yield 'bottom'
    yield cherrypy.url()
bottom.exposed = True

def _debug():
    yield 'debug'
    import cgi, os
    #yield cgi.print_environ().decode()
    yield 'REQUEST: %s<br />' % cherrypy.request.headers
    yield 'RESPONSE: %s<br />' % cherrypy.response.headers
    yield '<table border="1"><tr><th>name</th><th>value</th></tr>'
    for k in os.environ:
        yield '<tr><td>%s</td><td>%s</td></tr>' % (k,os.environ[k])
    yield '</table>'
_debug.exposed = True

def login(username='', password='', ckum='off', ckmm='off'):
    '''登录入口
    基本功能: 首次登录自动注册,登录后跳转到发生登录的页面(用session记录),并同时刷新top帧的内容.'''

    # 从网页上接受的字符串,默认是unicode编码的
    username = username.encode('utf-8')
    password = password.encode('utf-8')
    yield 'locals: %s' % str(locals())
    yield 'username: %s' % username
    yield 'password: %s' % password
    yield '%s' % str(cherrypy.request.remote)

    kw = locals()
    kw['id'] = username
    del kw['username']
    from fly_users import user
    user_cur = user(username)
    yield str(len(user_cur))
    if not len(user_cur):
        user_cur._insert(**kw)
        yield '[%s]自动注册成功！' % username
        raise cherrypy.HTTPRedirect('/')
        return
    if user_cur.password != password:
        yield '密码不正确'
    else:
        #print 'kw', '%s' % str(kw)
        user_cur.ckum = ckum
        user_cur.ckmm = ckmm
        yield '登录成功，更新密码和用户名保存设置, 以及最后登录IP等信息'
        user_cur.last_login_time = time.strftime('%Y-%m-%d %H:%M:%S')
        user_cur._address = cherrypy.request.remote.ip
        #raise cherrypy.HTTPRedirect('/')
        return
    yield open(os.path.join(os.path.dirname(__file__),'login.html')).read()

login.exposed = True

def block():
    time.sleep(5)
    yield 'block'
block.exposed = True

def hello():
    yield 'hello'
hello.exposed = True

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
