#!/usr/bin/perl

#
# General functions goes here
#

package GenFunc;

sub getos
{
  $useragent = shift;
  $os = 'undefined';

  $os = "Windows" if($useragent =~ "windows" or $useragent =~ "win98" or $useragent =~ "win95" or $useragent =~ "win16" );
  $os = "Linux" if($useragent =~ "linux");
  $os = "Mac" if($useragent =~ "macintosh" or $useragent =~ "mac os x" or $useragent =~ "mac_powerpc" );
  $os = "Ubuntu" if($useragent =~ "ubuntu");
  $os = "iPhone" if($useragent =~ "iphone");
  $os = "iPod" if($useragent =~ "ipod");
  $os = "iPad" if($useragent =~ "ipad");
  $os = "Android" if($useragent =~ "android");
  $os = "BlackBerry" if($useragent =~ "blackberry");
  $os = "Mobile" if($useragent =~ "webos");

  return $os;
}

sub getflavor
{
  $useragent = shift;
  $flavor = 'undefined';

  #windows flavor
  $flavor = "10" if($useragent =~ "windows nt 10");
  $flavor = "8.1" if($useragent =~ "windows nt 6.3");
  $flavor = "8.1" if($useragent =~ "windows nt 6.3");
  $flavor = "8" if($useragent =~ "windows nt 6.2");
  $flavor = "7" if($useragent =~ "windows nt 6.1");
  $flavor = "Vista" if($useragent =~ "windows nt 6.0");
  $flavor = "2003" if($useragent =~ "windows nt 5.2");
  $flavor = "XP" if($useragent =~ "windows nt 5.1");
  $flavor = "XP" if($useragent =~ "windows xp");
  $flavor = "2000" if($useragent =~ "windows nt 5.0");
  $flavor = "ME" if($useragent =~ "win 9x 4.9");
  $flavor = "ME" if($useragent =~ "windows me");
  $flavor = "98" if($useragent =~ "windows 98");
  $flavor = "98" if($useragent =~ "win98");
  $flavor = "95" if($useragent =~ "windows 95");
  $flavor = "95" if($useragent =~ "win95");
  $flavor = "3.1" if($useragent =~ "win16");
  $flavor = "NT" if($useragent =~ "win nt 4");

  #mac flavor
  if($os eq 'Mac')
  {
    $flavor = "OSX" if($useragent =~ "macintosh" or $useragent =~ "mac os x");
    $flavor = "OS9" if($useragent =~ "mac_powerpc");
  }

  return $flavor;
}

sub getsp
{
  $useragent = shift;
  $sp = 'undefined';
  $sp = 'SP2' if($useragent =~ "sv1");
  return $sp;
}

sub getlang
{
  $accepted_language = shift;
  $lang = 'undefined';

  my @langs = map {substr($_, 0, 2)} split(/,/, $accepted_language);
  foreach my $l (@langs)
  {
      $wanted_language = $l;
      last;
  }

  if($wanted_language ne "")
  {
    $lang = $wanted_language;
  }


  return $lang;
}

sub getuaname
{
  $useragent = shift;
  $uaname = 'undefined';

  $uaname = 'Mozilla' if($useragent =~ "mozilla");
  $uaname = 'Safari' if($useragent =~ "safari");
  $uaname = 'Opera' if($useragent =~ "opera");
  $uaname = 'Firefox' if($useragent =~ "firefox");
  $uaname = 'Chrome' if($useragent =~ "chrome");
  $uaname = 'Chromium' if($useragent =~ "chromium");
  $uaname = 'Netscape' if($useragent =~ "netscape");
  $uaname = 'Maxthon' if($useragent =~ "maxthon");
  $uaname = 'Konqueror' if($useragent =~ "konqueror");
  $uaname = 'Handheld Browser' if($useragent =~ "mobile");
  $uaname = 'MSIE' if($useragent =~ "msie");
  $uaname = 'Edge' if($useragent =~ "edge");

  return $uaname;
}

sub getuaver
{
  $uaname = shift;
  $uaver = '';

  if($uaname eq 'Mozilla') #Mozilla
  {
    $uacheckie = $useragent;
    $uacheckie =~ /; rv:([0-9\.]*)/g;
    $uaver = $1;
  }
  if($uaname eq 'MSIE') #IE
  {
    $uacheckie = $useragent;
    $uacheckie =~ /msie ([0-9\.]*)/g;
	$uaver = $1;

    if($uaver eq '') #detect IE11
    {
      $uacheckie2 = $useragent;
      $uacheckie2 =~ / rv:([0-9\.]*)/g;
      $uaver = $1;
    }

  }
  if($uaname eq 'Safari') #Safari
  {
    $uachecksaf = $useragent;
    $uachecksaf =~ /version\/([0-9\.]*)/g;
	$uaver = $1;
  }
  if($uaname eq 'Opera') #Opera
  {
    $uacheckope = $useragent;
    $uacheckope =~ /opera\/([0-9\.]*)/g;
	$uaver = $1;
  }
  if($uaname eq 'Firefox') #Firefox
  {
    $uacheckope = $useragent;
    $uacheckope =~ /firefox\/([0-9\.]*)/g;
	$uaver = $1;
  }
  if($uaname eq 'Chrome') #Chrome
  {
    $uacheckope = $useragent;
    $uacheckope =~ /chrome\/([0-9\.]*)/g;
	$uaver = $1;
  }
  if($uaname eq 'Chromium') #Chromium
  {
    $uacheckope = $useragent;
    $uacheckope =~ /chromium\/([0-9\.]*)/g;
	$uaver = $1;
  }
  if($uaname eq 'Edge') #Edge
  {
    $uacheckope = $useragent;
    $uacheckope =~ /edge\/([0-9\.]*)/g;
	$uaver = $1;
  }

  $uaver = 'undefined' if($uaver eq "");

  return $uaver;
}

sub getarch
{
  $useragent = shift;

  $arch = 'undefined';
  $arch = 'x86_x64' if($useragent =~ 'wow64');
  $arch = 'x64' if($useragent =~ 'win64');
  $arch = 'x86_x64' if($useragent =~ 'x86_64');
  return $arch;
}






1;
