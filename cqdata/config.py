# -*- coding: utf-8 -*-
# 数据集市公共配置文件, 将其他文件中都会用到的配置参数全部写在此文件中以备导入
# 可以考虑将公用的函数敢写在此文件中

ss1 = '39 35 57 50 44 52 48 53 33 25 34 16 41 40 23 51 43 15 30 45 28 49 13 12 29 37 47 46 36 21 26 27 54 32 14 42 31 38 24 60 22'
ss2 = '1005 1004 1040 1001 1011 1021 1012 1032 1022 1019 1009 1036 1003 1002 1008 1030 1023 1034 1026 1027 1033 1015 1037 1035 1010 1013 1029 1014 1028 1007 1020 1016 1031 1025 1038 1006 1024 1000 1018 1077 1017'
ss3 = '巴南 北碚 北部新区 璧山 长寿 城口 大足 垫江 丰都 奉节 涪陵 观音桥 合川 江津 开县 梁平 南川 南坪 彭水 綦江 黔江 荣昌 沙坪坝 上清寺 石柱 双桥 铜梁 潼南 万盛 万州 巫山 巫溪 武隆 秀山 杨家坪 永川 酉阳 渝北 云阳 政企客户部 忠县'
ss4 = 'yb bs jj hc bb bn yc wz kx fl sz cs dz sq tn yc wq zx yy fj ws ck fd nc yy xs ps qj ws tl lp wl dj qj np sqs gyq spb yjp bbxq zqkhb'
ss5 = '307 306 301 303 313 323 314 334 324 321 311 301 305 304 310 332 325 301 328 329 335 317 301 301 312 #N/A 331 316 #N/A 309 322 318 333 327 301 308 326 302 320 #N/A 319'
s1 = '33 53 51 54 25 43 49 16 44 37 34 48 30 26 45 29'
s2 = ' '.join(map(lambda x:ss2.split()[ss1.split().index(x)], s1.split()))
s3 = ' '.join(map(lambda x:ss3.split()[ss1.split().index(x)], s1.split()))
s5 = ' '.join(map(lambda x:ss5.split()[ss1.split().index(x)], s1.split()))
s4 = 'fdsjjszh xiangni11 lpdx 540001 mfl659659 00110816 234567 12345 123456 370001 yzbyzb 480001 q000000 260001 123456wcl 122316'
dict_id = dict(zip(s1.split(), s2.split()))
dict_name = dict(zip(s1.split(), s3.split()))
dict_pwd = dict(zip(s1.split(), s4.split()))
dict_id3 = dict(zip(s1.split(),s5.split()))
del s1, s2, s3, s4
