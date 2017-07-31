#!python
# -*- coding: utf-8 -*-
# The first wsgi server, to be upgrade
#

from wsgiref.simple_server import make_server
#from stackless import channel, tasklet
#import stackless
import time

#print ('中国人')
def app(env, start_response):
	'''app'''

	write = start_response('200 OK', [('Content-Type','text/html; charset=utf-8')])
	write('output by write'.encode('utf-8'))
	#write('国国要'.encode('utf-8'))
	#print 'Some thing...', time.time()
	#time.sleep(5)
	return ['hello, world'.encode('utf-8')]
import stackless
from stackless import tasklet, run
def tasklet_wrap(func):
	def wrap(env, start):
		t = tasklet(func)(env, start)
		t.run()
		return t.tempval
	return wrap
#app = tasklet_wrap(app)

from eurasia import WSGIServer
if __name__ == '__main__':
	#stackless.run()
	httpd = make_server("",8000,app)
	#sa = httpd.socket.getsockname()
	#print("Serving HTTP on ", sa[0], "port", sa[1], "...")
	# httpd.handle_request()
	#while True:
	#	httpd.handle_request()
	#	schedule()
	httpd.serve_forever()
	#server = WSGIServer(app, bindAddress=('0.0.0.0', 8088))
	#server.run()

