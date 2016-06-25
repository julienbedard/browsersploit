#!/usr/bin/perl

#  
# Check the client plugin versions and send to check.pl
#

use CGI();

$q = new CGI;

$aff = $q->param('aff');

$referer = $ENV{HTTP_REFERER};
$referer =~ s/'/-/g;

#print script for getting versions of plugins
print $q->header();
print <<EOF;

<html>
<head>
<script type="text/javascript" src="dep/PluginDetect.js"></script>
</head>
<body>

<script>
window.onload = function()
{
  var outputNode = 'javaresult';
  var JavaInstalled;
  var JavaVersion;
  var jarfile = 'dep/getJavaInfo.jar';
  var verifyTags = null;

  PluginDetect.getVersion("."); 
  var javaversion = PluginDetect.getVersion("Java", jarfile, verifyTags);
  var adobeversion = PluginDetect.getVersion('AdobeReader');
  var QTVersion = PluginDetect.getVersion('QuickTime');
  var flashversion = PluginDetect.getVersion('Flash');
  var shockversion = PluginDetect.getVersion('Shockwave');
  var vlcversion = PluginDetect.getVersion('VLC');
  var realplayerversion = PluginDetect.getVersion('RealPlayer');

  location.href = 'check.pl?' + "&aff=$aff" + "&java=" + javaversion + "&adobe=" + adobeversion + "&quicktime=" + QTVersion + "&flash=" + flashversion + "&shockwave=" + shockversion + "&vlc=" + vlcversion + "&realversion=" + realplayerversion + "&referer=$referer";
}
</script>

</body>
</html>

EOF

1;
