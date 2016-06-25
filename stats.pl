#!/usr/bin/perl
  
  # index.pl
  use CGI;
  use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
  use CGI::Session ( '-ip_match' );
  use DBI;
  require "xpl/config.pl";
  
  $session = CGI::Session->load();
  $q = new CGI;
  
  $cook = $q->param('cook');
  $stats = $q->param('q');

  $db_name = 'DBI:mysql:' . $config{MysqlDB};
  $dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";
  
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
    $sth = $dbh->prepare( "SELECT * FROM affiliates WHERE cook = ?" );
    $sth->execute( $cook );
    $sth->bind_columns( \$id, \$name, \$password, \$affid, \$email, \$cook, \$cook12, \$cook13, \$cook14, \$cook15, \$cook16, \$cook17, \$cook18, \$cook19, \$cook20, \$cook21, \$cook22, \$cook23 );
    $sth->fetch();
	#$dbh->disconnect();
    
	if($stats eq 'loads' or $stats eq "")
	{
      #Loads
      $req = "select sum(loads)as totloads,count(id) as totview from hosts where aff='$affid'";
      $sth = $dbh->prepare($req);
      $sth->execute();
      while(my @row = $sth->fetchrow_array)
      {
        $loads = $row['0'];
        $hosts = $row['1'];
      }
      $sth -> finish;
	  $percent = 0;
	  $percent = $loads * 100 / $hosts if($hosts ne "0" and $loads ne "0");
	  $arrondi = sprintf("%.0f", $percent);
	  $texttoprint = "
	  Loads  | <a href=\"stats.pl?cook=$cook&q=ctry\">Countries</a><br>
     <DIV id=\"main\">
     <DIV class=\"content\">
     <DIV id=\"pages\">
     <DIV id=\"home\">
     <DIV>
     </DIV>
     <center>
     <table COLS=2 WIDTH=\"800\" >
     <tr VALIGN=TOP>
     <td>
     <b>Unique View</b>
     <br>
     </td>
     <td>
     <b>Loads</b>
     <br>
     </td>
     <td>
     <b>%</b>
     <br>
     </td>
     </tr>
     <tr>
     <center>
     <img src=\"images/gotop.png\"></img>
     </center>
     </tr>
     <td>
     $hosts <br>
     </td>
     <td>
     $loads <br>
     </td>
	 <td>
     $arrondi <br>
     </td>
     </table>"
	}
	
	if($stats eq 'ctry')
	{
	  #Country
          $req = "select country,sum(loads)as totloads,count(id) as totview from hosts where aff='$affid' group by country ASC";
          $sth = $dbh->prepare($req);
          $sth->execute();
          while(my @row = $sth->fetchrow_array)
          {
            $country = $row['0'];
            $rowsloads = $row['1'];
            $rows = $row['2'];
            $country = 'UNKNOW' if($country eq "");
            $lccountry = lc($referer);
            $lccountry = 'other' if(!-e "images/country/$lccountry\.png");

            $real_ref .=  '<img src="images/country/' . $lccountry . '.png"></img> ' . $referer . '<br>' . "\n";
            $ref_total .= $rows  . '<br>' . "\n";
            $ref_loads .= $rowsloads  . '<br>' . "\n";

          }
          $sth -> finish;
	  
	  $texttoprint = "
	  <a href=\"stats.pl?cook=$cook\">Loads</a> | Countries <br>
     <DIV id=\"main\">
     <DIV class=\"content\">
     <DIV id=\"pages\">
     <DIV id=\"home\">
     <DIV>
     </DIV>
     <center>
     <table COLS=2 WIDTH=\"800\" >
     <tr VALIGN=TOP>
     <td>
     <b>Country code</b>
     <br>
     </td>
     <td>
     <b>Total</b>
     <br>
     </td>
	 <td>
     <b>Loads</b>
     <br>
     </td>
     </tr>
     <tr>
     <center>
     <img src=\"images/gotop.png\"></img>
     </center>
     </tr>
     <td>
     $real_ref <br>
     </td>
     <td>
     $ref_total <br>
     </td>
	 <td>
     $ref_loads <br>
     </td>
     </table>"
	}
	

	
    print $q->header(-cache_control=>"no-cache, no-store, must-revalidate");
	indexalltab();
  }
  
sub indexalltab
{
 print <<THEHTMLINDEX;
 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<HTML xmlns="http://www.w3.org/1999/xhtml" lang="fr"><HEAD><META http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<TITLE>$config{NetName} - Report</TITLE>
    <LINK rel="stylesheet" type="text/css" href="style/style3.css" media="all">
    
</HEAD><BODY>
<DIV id="top_nav">
	<DIV class="content">
    
        <UL>
            <LI><A href="index.pl?cook=$cook" title="Home" class="Home">Home</A></LI>
            <LI><A href="tools.pl?cook=$cook" title="tools">Tools</A></LI>
            <LI><A href="stats.pl?cook=$cook" title="Report">Report</A></LI>
            <LI><A href="programs.pl?cook=$cook" title="Account">Account</A></LI>
            <LI><A href="help.pl?cook=$cook" title="Support">Support</A></LI>
            <LI><A href="#" title=""></A></LI>
            <LI><A href="login.pl?action=logout" title="Log Out">Log Out</A></LI>
        </UL>
        
    </DIV>
</DIV>
<p align=right><font size=3><font color=red>*</font> $name stats  </font></p>
<center>
<br>
<h2>[ Reports ]</h2><br><br>
$texttoprint
</center>
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
