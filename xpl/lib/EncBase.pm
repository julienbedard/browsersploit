#!/usr/bin/perl

#
# Return randomized spaced base64
#

require "../lib/JsXOR.pm";
require "../lib/EncHex.pm";

package EncBase;

sub randombase
{
  $data = shift;
  $allbase64data = "";
  # Encode the data
  $ranobjid = JsXOR::generate_random_string(int(rand 20));
  $encoded = wencode_base64($data);

  # Put random space injection
  foreach $charencoded (split //, $encoded)
  {
    $chaoslawnumber = int(rand(2));
    $spaceprint = " " x int(rand(6));
    $returnprint = "\n" x int(rand(3));
    if($chaoslawnumber eq 1 or $chaoslawnumber eq 2)
    {
      $encodespaced .= $spaceprint . $returnprint;
	  $encodespaced .= $charencoded;
    }
    else
    {
      $encodespaced .= $spaceprint . $charencoded;
    }
  }
  $allbase64data .= '<HTML><BODY><OBJECT ID="'. $ranobjid . '" HEIGHT="100%" WIDTH="100%" TYPE="text/html" DATA="data:text/html;base64,';
  $allbase64data .= $encodespaced;
  $allbase64data .= '">Could not render object</OBJECT></BODY></HTML>';
  return $allbase64data;
}

sub wencode_base64 ($;$){
    use integer;
    my $eol = $_[1];
    $eol = "\n" unless defined $eol;
    my $res = pack("u", $_[0]);
    $res =~ s/^.//mg;
    $res =~ s/\n//g;
    $res =~ tr|` -_|AA-Za-z0-9+/|;               # `# help emacs
    my $padding = (3 - length($_[0]) % 3) % 3;
    $res =~ s/.{$padding}$/'=' x $padding/e if $padding;
    if (length $eol) {
	$res =~ s/(.{1,76})/$1$eol/g;
    }
    return $res;
}

1;