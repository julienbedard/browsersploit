#!/usr/bin/perl

#
# HoneyPot to get malware database etc away
#

use CGI;
use Geo::IP;
use DBI;
require "config.pl";

$q = new CGI;

$theip = $ENV{REMOTE_ADDR};
$referer = $q->param('refpag');
$querystring = $ENV{QUERY_STRING};
$referer = 'BLANK' if($referer eq "");

#connect to database
$db_name = 'DBI:mysql:' . $config{MysqlDB};
$dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";

#IP to Country
$gi = Geo::IP->open( 'dep/GeoIP.dat' );
my $country = $gi->country_code_by_addr($theip);

#Convert IP for database
my (@octets,$octet,$ip_number,$number_convert,$ip_address);
$ip_address = $theip;
chomp ($ip_address);
@octets = split(/\./, $ip_address);
$ip_number = 0;
foreach $octet (@octets) {
$ip_number <<= 8;
$ip_number |= $octet;
}

$verifdoubleipch = $dbh->selectrow_array("SELECT os FROM hosts WHERE ip='$ip_number'");
if($verifdoubleipch eq "")
{
  #Insert the system stats and check if the IP already exist
  $sql = "INSERT hosts (ip, browser, browser_version, os, os_flavor, service_pack, os_lang, country, arch, referer, aff) VALUES ('$ip_number', 'HoneyPot', 'HoneyPot', 'HoneyPot', 'HoneyPot', 'HoneyPot', 'HoneyPot', '$country', 'HoneyPot', '$referer', 'HoneyPot')";
  $statement = $dbh->prepare($sql);
  $statement->execute() or $doubleip = 1;
}

#print the html;
print "Status: 301 Moved\nLocation: /nonexist.html\n\n";


$dbh->disconnect();

1;
