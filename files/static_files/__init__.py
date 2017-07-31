# -*- coding: utf-8 -*-

import sys
upMod = sys.modules['.'.join(__name__.split('.')[:-1])]
for k, v in upMod.__dict__.items():
    if not k.startswith('_'):
        globals()[k] = v
del upMod, k, v

name = '脚本文件'
