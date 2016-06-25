#!/usr/bin/perl

#
# Configuration file
#

%config = 
(

#Your Network Information
'NetName' => 'Powerful Grant Access',
'NetEmail' => 'youremail@domain.com',

#Mysql config for storing data
'MysqlHost' => 'localhost',
'MysqlDB' => 'ezic_v2',
'MysqlUser' => 'root',
'MysqlPass' => '',

#Scan4you.biz Information
'Scanid' => '',
'Scantoken' => '',

#The complete path of where you uploaded files (xpl folder)
'UrlToFolder' => 'http://192.168.1.1/xpl/',

#Configuration for the default exe without aff parameter
'Exe_default' => 'default.exe',
);

1;
