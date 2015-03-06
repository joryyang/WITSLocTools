#!/usr/bin/env python
#coding=utf-8

from socket import *
import time, sys, re, os

def client(locenv, text):
    platform = 'null'; xcodeVersion = 'null'
    if os.path.isfile('/System/Library/CoreServices/SystemVersion.plist'):
        platform = re.findall('[0-9]+[A-Z][0-9a-z]+', open('/System/Library/CoreServices/SystemVersion.plist').read())[0]
    if os.path.isfile('/Applications/Xcode.app/Contents/version.plist'):
        xcodeVersion = re.findall('CFBundleVersion[\s\S]*?([.0-9z]+)[\s\S]*?ProductBuildVersion', open('/Applications/Xcode.app/Contents/version.plist').read())[0]
    try:
        s = socket(AF_INET, SOCK_STREAM)
        s.connect(('10.4.2.6', 8888))
        s.send('%s process %s at %s %s %s'%(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), text, locenv[29:], platform, xcodeVersion))
        #   tm = s.recv(1024)
        #   print tm
        s.close()
    except error:
        pass

client(sys.argv[1], sys.argv[2]) # path, Envtester | BugFixComment | AutoFtp

def client1():
    try:
        s = socket(AF_INET, SOCK_STREAM)
        s.connect(('10.4.2.31', 8889))
        tm = s.recv(1024)
        return tm
        s.close()
    except error:
        return '''
1. 执行 Envtester ---------- 备份相关 Folder, 删除 .marking, 环境检查

2. 写入 BugFixComment ------ 根据环境以及后续输入的 bug ID 生成此份文件

3. 生成 autoFtp ------------ 同时会还原 Info & Project, 获取 01_1 tar

4. 指定 Plugin 带翻译 ------ 原理同 xliffdiffer (beta 版, 请谨慎使用)

5. 比对 xliffdiffer -------- 核对带翻结果, 请仔细查阅稍后生成的 report

6. 执行 iTunes_itxib_tool -- iTunes 专用, 生成某些 nib 对应的 itxib

7. 检测 xliff 中的变量 ----- 指定 xliff 文件或目录, 分离自 Envtester

0. 退出 LocTools ----------- Command + W 其实可以更快退出

请选择需要执行的操作: '''