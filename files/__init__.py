# -*- coding: utf-8 -*-

"""
import sys
upMod = sys.modules['.'.join(__name__.split('.')[:-1])]
for k, v in upMod.__dict__.items():
    if not k.startswith('_'):
        globals()[k] = v
del upMod, k, v

name = '文件共享'

FileType = {'py':'Python File', 'pyc':'Compiled Python File', 
        'gif':'GIF 图象', 'zip':'WinRAR ZIP 压缩文件',
        'swf':'Shockwave Flash Object', 'js':'JScript Script File',
        'reg':'注册表项', 'css':'层叠样式表文档', 
        'html':'HTML 文档', 'htm': 'HTML 文档', 
        'msi':'Windows Installer 软件包',
        'exe':'应用程序', 'com':'应用程序', 
        'jpg':'JPEG 图像', 'jpeg':'JPEG 图像',
        'xlsx':'Excel 2007 工作表', 'xls':'Excel 2003 工作表',
        'docx':'Word 2007 文档', 'doc':'Word 2003 文档'}

class index(globals().get('index',object)):
    '''class for a wsgi app'''

    def __iter__(self):
        '''如果url是目录, 就显示目录中的文件内容；
        如果是文件, 就根据扩展名, 返回文件内容'''

        sys_file = ['__init__.py', '__init__.pyc', '.__init__.py.swp', 'Thumbs.db', '.readme.txt', '.log.txt']  # 不在文件下载界面显示和管理的文件. 
        fullpath = self._root + self.env['PATH_INFO'].replace('/',os.path.sep)
        fullpath = fullpath.decode('utf8').encode('gb2312')
        if os.path.isdir(fullpath):
            w = self.start('200 OK', [('Content-Type', self.Content_Type)])
            yield '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
            yield '<html xmlns="http://www.w3.org/1999/xhtml">'
            yield '<head><title></title></head><body>'
            #yield '显示目录下面的文件内容, 包括文件名, 上传日期, 大小, 提供排序功能'
            #print self._root, fullpath
            #yield 'fullpath: %s' % fullpath
            #yield self.__class__._root
            # 为便于排序, 应先将各种数据先取到一个列表中.
            # 文件名 选择框 下载链接 大小 类型(确保目录始终在前面) 日期 上传者  描述 ..
            result = []
            for f in [i for i in os.listdir(fullpath) if i not in sys_file]:
                rec = [i]
                f_utf8 = f.decode('gb2312').encode('utf8')  # 页面中输出时, 要转码为utf8
                rec.append('<input type=checkbox name="files" value="%s">' % f_utf8)
                rec.append('<a href=%s/%s>%s</a>' % (self.env['PATH_INFO'],f_utf8,f_utf8))
                size = os.path.getsize(os.sep.join([fullpath,f]))
                if size>1024*10240:
                    size = '%d MB' % (size/1024/1024)
                elif size>10240:
                    size = '%d KB' % (size/1024)
                rec.append(size)
                ext = f.split('.')[-1].decode('gb2312').encode('utf8')
                if os.path.isdir(os.sep.join([fullpath, f])):
                    rec.append('文件夹')
                else:
                    rec.append(FileType.get(ext, ext))
                rec.append(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(os.path.getmtime(os.sep.join([fullpath,f])))))
                result.append(rec)
            yield '<table frame="below" cellspacing="0" width="100%%" style="border: 0px solid #000000; border-width:1 1 1 1" >'
            yield '%s' % TH(['<input type="checkbox" name="all">']+'名称 大小 类型 日期 上传者 描述'.split(), align="center")
            for rec in result:
                yield '%s' % TR(TD(rec[1:]))
            yield '</table>'
            yield '<br />'  # 空一行以便最后给浮动菜单留位置
            yield '</html>'
            yield '<div align="center" valign="center" style="background-color:#096; left:0; bottom:0; POSITION:fixed; _position:absolute; width:100%; height:20px; z-index:999;"> 改名 | 改描述 | 查找 | 上传新文件</div>'
            #yield '<div style="background-color:#096; z-index:999; position:fixed; bottom:0; left:0; width:100%; _position:absolute; /* for IE6 */_top: expression(documentElement.scrollTop + documentElement.clientHeight-this.offsetHeight); /* for IE6 */ overflow:visible;">固定2</div>'
        elif not os.path.exists(fullpath):
            # 注意, 中文winXP的文件结构是gb2312编码的.
            self.start('404 Not Found', [('Content-Type', 'text/html')])
            #self.start('404 Not Found', [])
            print ('Not Found ')
        else:   # 根据扩展名, 返回正确的HTTP头信息, 然后发送文件内容
            if fullpath.split('.')[-1].lower() not in ('htm', 'html', 'gif', 'jpg', 'css', 'js', 'png', 'swf'):
                self.start('200 OK',[('Content-Type','application/octet-stream'),('Content-Disposition','attachment; filename=%s' % os.path.basename(fullpath))])
            else:
                self.start('200 OK',[('Content-Type', 'application/auto'),('Content-Disposition','auto'),('Cache-Control','max-age=7300')])
            yield open(fullpath, 'rb').read()

"""

import sqlite3, os, chardet, MySQL, cherrypy, cgi, sys, xlrd, time, datetime, traceback, cherrypy
from HTMLTags import TR, TD, INPUT, SELECT, OPTION
#from . import config, dbapi

@cherrypy.expose
def index(**kw):
    '''文件着页'''

    yield 'test'

