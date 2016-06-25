#!/usr/bin/perl
  
  # login.pl
  use CGI;
  use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
  use CGI::Session ( '-ip_match' );
  use DBI;

  require "xpl/config.pl";
  
  $q = new CGI;

$real_ipadd = $ENV{REMOTE_ADDR};
  
  $db_name = 'DBI:mysql:' . $config{MysqlDB};
  $dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";

  $usr = $q->param('usr');
  $pwd = $q->param('pwd');
  
  if($usr ne '' and $pwd ne '')
  {
      $cryptpwd = substr(crypt($pwd,substr($pwd,0,2)),2); # Encrypt the password$cryptpwd = substr(crypt($pwd,substr($pwd,0,2)),2);
      # process the form

      $req = "SELECT cook,affid FROM affiliates WHERE username='$usr' and password='$cryptpwd'";
      $sth = $dbh->prepare($req);
      $sth->execute();
      while(my @row = $sth->fetchrow_array)
      {
        $cook = $row['0'];
        $affid = $row['1'];
      }
      $sth -> finish;

	  if($cook ne "")
	  {
	    if($affid eq "admin")
		{
		  $session = new CGI::Session();
		  #$session->expire("30m"); #wasn't working on expiry
          print $session->header(-location=>"xplindex.pl?cook=$cook&vfy=xplad",
								 -status=>301);
		}
		else
		{
	      $session = new CGI::Session();
		  #$session->expire("30m"); #wasn't working on expiry
          print $session->header(-location=>"index.pl?cook=$cook",
								 -status=>301);
		}
      }
	  else
	  {
	    print $q->header(-type=>"text/html",-location=>"login.pl",
								            -status=>301);
	  }
  }
  elsif($q->param('action') eq 'logout')
  {
      $session = CGI::Session->load() or die CGI::Session->errstr;
      $session->delete();
      print $session->header(-location=>'login.pl',
							 -status=>301);
  }
  
  else
  {
      print $q->header;
	  print <<HTMLTAG;
<html> 
  <head> 
	<title>$config{NetName} - Login</title> 
	<link rel="STYLESHEET" href="style/stylesheet.css" type="TEXT/CSS" /> 
  </head> 
    <form method="post"> 
    <div class="container"> 
    <div class="announce"> 
	<table> 
	  <tr> 
	    <td> 
			<center><font size="5">$config{NetName} - $real_ipadd -</font></center><br>
			<table align="center" border="0" cellspacing="0" cellpadding="0">  
		      <tr> 
			    <td> 
			      <table cellpadding="0" cellspacing="0" border="0" width="100%"> 
		            <tr> 
					</tr> 
					<tr height="26"> 
			          <td bgcolor="#000000" class="WhiteBold">Login System&nbsp;&nbsp;</td> 
			          <td width="250" background="images/bar_webhosting.gif"></td> 
                    </tr> 
                  </table> 
			    </td> 
			  </tr> 
			  <tr> 
			    <td class="loginbox_long"> 
				<br> 
				  <table align="center"> 
				    <tr> 
					  <td><b>Username:</b></td> 
					  <td><input type="text" name="usr"></td> 
                    </tr> 
					<tr> 
					  <td><b>Password:</b></td> 
					  <td><input type="password" name="pwd"></td> 
                    </tr> 
					<input type="hidden" name="cook" value="$cook" /> 
					<tr> 
					  <td>&nbsp;</td> 
					  <td align="right"><input type="image" src="images/button_smlogin_blue.gif" value="Submit" name="button" tabindex="4"></td> 
				    </tr> 
				  </table> 
				
				</td> 
              </tr> 
			</table> 
			<br> 
			
	    </td>	  
	  </tr>	    
	</table>			  
	</div> 
	</div> 
    </form> 
  </body> 
</html> 
	  
     
HTMLTAG

  }
  
1;
