#!/usr/bin/perl

# Check the browser and redirect
use CGI;
use Geo::IP;
use DBI;
require "config.pl";
require "lib/Xploit.pm";

#Connect to database
$db_name = 'DBI:mysql:' . $config{MysqlDB};
$dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";

$ip_number = '3237235798';
$country = 'CA';

$doubleip = '';

  #Insert the system stats and check if the IP already exist
  $sql = "INSERT hosts (ip, browser, browser_version, os, os_flavor, service_pack, os_lang, country, arch, referer, aff) VALUES ('$ip_number', 'HoneyPot', 'HoneyPot', 'HoneyPot', 'HoneyPot', 'HoneyPot', 'HoneyPot', '$country', 'HoneyPot', 'ai.pl', 'HoneyPot')";
  $statement = $dbh->prepare($sql);
  $statement->execute() or $doubleip = 1;



print "$doubleip\n";
