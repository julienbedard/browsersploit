#!/usr/bin/perl

#
# Return A hex string from a file
#

require "../config.pl";

package EncHex;

sub ascii_to_hex ($)
{
  (my $str = shift) =~ s/(.|\n)/sprintf("%02lx", ord $1)/eg;
  return $str;
}

sub filetohex
{
  my $fileopen = shift;
  my $str;
  $fileopen = '../dep/' . $config{Exe_default} if($fileopen eq "");
  open(FILE,"<$fileopen") || die "file cannot be openned $fileopen\n";
  while(<FILE>)
  {
    $str .= $_;
  }
  close(FILE);
  
  chomp $str;
  my $h_str = ascii_to_hex $str;
  return $h_str;
}

sub stringtohex
{
  my $fileopen = shift;
  my $str;
  $fileopen = $config{UrlToFolder} . '/dep/' . $config{Exe_default} if($fileopen eq "");
  $str = $fileopen;
  
  chomp $str;
  my $h_str = ascii_to_hex $str;
  return $h_str;
}

1;