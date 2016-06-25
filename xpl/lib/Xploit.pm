#!/usr/bin/perl

#
# Exploits strings
#

package Xploit;

sub allsploit
{
  @exploits = (mozilla35, mozilla_compareto, iepeers, ms09_043, iepeers7, ms09_002, directshow, aol95, aol_ampx, autodesk_iodrop, awingsoftwinds3d, winds3d, icq_downloadagent, java_arginject, javacalendar, adobelibtiff, adobenewplayer, javaCMM, quicktime_marshaled, shockwave, javadocbase, eacheckreq, ms11_xxx, firefoxinter, javadrive, realplayer_cdda, vlc_amv);

  return @exploits;
}


sub xplconf
{

$xpltocheck = shift;

#Config for exploit
# ex:
#     'EXPLOITNAME' => 'UANAME:UAVER:FLAVOR:PLUGIN:PLUGINVER:GROUP:DESCRIPTION'
#                       0     1      2      3        4       5        6
%xplconfig =
(
'mozilla35' => 'Firefox:3.5:XP:NA:NA:Other:Firefox Overflow',
'mozilla_compareto' => 'Firefox:ALL:XP:NA:NA:Other:Firefox CompareTo',
'iepeers' => 'MSIE:6:XP:NA:NA:Other:iepeers 6.0',
'ms09_043' => 'MSIE:6,7:XP,Vista:NA:NA:Other:MS09_043',
'iepeers7' => 'MSIE:7:XP,Vista:NA:NA:Other:iepeers 7.0',
'ms09_002' => 'MSIE:7:XP,Vista:NA:NA:Other:MS09_002',
'directshow' => 'MSIE:7:XP:NA:NA:Other:Microsoft Directshow',
'aol95' => 'MSIE:ALL:ALL:NA:NA:ActiveX:AOL 9.5 ActiveX',
'aol_ampx' => 'MSIE:ALL:ALL:NA:NA:ActiveX:AOL Winamp ActiveX',
'autodesk_iodrop' => 'MSIE:ALL:ALL:NA:NA:ActiveX:Autodesk Iodrop ActiveX',
'awingsoftwinds3d' => 'MSIE:ALL:ALL:NA:NA:ActiveX:Awingsoft Winds3d ActiveX',
'winds3d' => 'MSIE:ALL:ALL:NA:NA:ActiveX:Winds3D ActiveX 2',
'icq_downloadagent' => 'MSIE:ALL:ALL:NA:NA:ActiveX:ICQ Download Agent',
'java_arginject' => 'ALL:ALL:XP,Vista:Java:1.6.0.11,1.6.0.12,1.6.0.13,1.6.0.14,1.6.0.15,1.6.0.16,1.6.0.17,1.6.0.18:Plugin:Java Argument Injection',
'javacalendar' => 'ALL:ALL:ALL:Java:NA:Plugin:Java Calendar Deserialization',
'adobelibtiff' => 'ALL:ALL:XP:Adobe:8.0,8.1,8.2,9.0,9.1,9.2,9.3:Plugin:Adobe Reader LibTiff',
'adobenewplayer' => 'ALL:ALL:ALL:Adobe:8.0,8.1,8.2,9.0,9.1,9.2:Plugin:Adobe Reader NewPlayer',
'javaCMM' => 'ALL:ALL:ALL:Java:NA:Plugin:Java readMabCurveData',
'quicktime_marshaled' => 'MSIE:ALL:XP,Vista:Quicktime:7.6.6.0,7.6.7.0:ActiveX:Quicktime Marshaled ActiveX',
'shockwave' => 'MSIE:ALL:XP,Vista:Shockwave:11.5.7.609,11.5.6.606,11.5.2.606,11.5.2.602,11.5.1.601,11.5.601,11.5.600,11.5.596,11.5.8.612,11.5.0.595,11.0.0.456,11.0.0.0:Plugin:Shockwave RCSL',
'javadocbase' => 'MSIE:ALL:ALL:Java:1.6.0.18,1.6.0.19,1.6.0.20,1.6.0.21:ActiveX:Java Docbase',
'eacheckreq' => 'MSIE:ALL:ALL:NA:NA:ActiveX:EAGames Check',
'ms11_xxx' => 'MSIE:ALL:ALL:NA:NA:Other:MS11_XXX',
'firefoxinter' => 'Firefox:3.6.8,3.6.9,3.6.10,3.6.11:XP:NA:NA:Other:Firefox Interleaved',
'javadrive' => 'ALL:ALL:ALL:Java:NA:Plugin:Java DriveBy',
'realplayer_cdda' => 'MSIE:ALL:ALL:Realplayer:11.0,11.1:ActiveX:RealPlayer cdda',
'vlc_amv' => 'MSIE:ALL:XP,Vista:Vlc:1.1.4.0,1.1.5.0,1.1.6.0,1.1.7.0:ActiveX:VLC AMV',

);

return $xplconfig{$xpltocheck};

}


1;
