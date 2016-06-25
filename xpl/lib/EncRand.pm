#!/usr/bin/perl

#
# Return randomized Cookie-Based Javascript Encryption
#

package EncRand;

sub CsCrypt
{
  $data = shift;
  $csname = shift;
  $theCookie = shift;
  $csname = 'gfdjk4389fgdh' if($csname eq "");
  $theCookie = '4585425488245282824' if($theCookie eq "");

  $key = $theCookie;
  $string = $data;
  #$key = '1111111111'; #debug
  
  #Encrypt the data according to the cookie value
  $result = "";
  for($i=0; $i<length($string); $i++)
  {
    $char = substr($string, $i, 1);
    $keychar = substr($key, ($i % length($key))-1, 1);
    $char = chr(ord($char)+ord($keychar));
    $result.=$char;
  }
  $base64 = wencode_base64($result);
  $base64 =~ s/\n//g;

  #generate random vars for javascript

  #generate javascript encrypted with functions
  $javascriptfunc = <<EOF;
function decode64(input) {
     var output = "";
     var chr1, chr2, chr3 = "";
     var enc1, enc2, enc3, enc4 = "";
     var i = 0;
 
     // remove all characters that are not A-Z, a-z, 0-9, +, /, or =
     var base64test = /[^A-Za-z0-9\+\/\=]/g;
     if (base64test.exec(input)) {
     }
     input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
 
     do {
        enc1 = keyStr.indexOf(input.charAt(i++));
        enc2 = keyStr.indexOf(input.charAt(i++));
        enc3 = keyStr.indexOf(input.charAt(i++));
        enc4 = keyStr.indexOf(input.charAt(i++));
 
        chr1 = (enc1 << 2) | (enc2 >> 4);
        chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
        chr3 = ((enc3 & 3) << 6) | enc4;
 
        output = output + String.fromCharCode(chr1);
 
        if (enc3 != 64) {
           output = output + String.fromCharCode(chr2);
        }
        if (enc4 != 64) {
           output = output + String.fromCharCode(chr3);
        }
 
        chr1 = chr2 = chr3 = "";
        enc1 = enc2 = enc3 = enc4 = "";
 
     } while (i < input.length);
   
     return unescape(output);
  }

function ord (string) {
    var str = string + '';
    var code = str.charCodeAt(0);
    if (0xD800 <= code && code <= 0xDBFF) {
        var hi = code;
        if (str.length === 1) {
            return code;
        }
        var low = str.charCodeAt(1);
        if (!low) {
            
        }
        return ((hi - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;
    }
    if (0xDC00 <= code && code <= 0xDFFF) {
        return code;
    }
    return code;
}

function ReadCookie(cookieName) {
 var theCookie=""+document.cookie;
 var ind=theCookie.indexOf(cookieName);
 if (ind==-1 || cookieName=="") return ""; 
 var ind1=theCookie.indexOf(';',ind);
 if (ind1==-1) ind1=theCookie.length; 
 return unescape(theCookie.substring(ind+cookieName.length+1,ind1));
}

var keyStr = "ABCDEFGHIJKLMNOP" +
             "QRSTUVWXYZabcdef" +
             "ghijklmnopqrstuv" +
             "wxyz0123456789+/" +
             "=";

var key = ReadCookie("$csname");
bencoded = "$base64";

var base641 = decode64(bencoded);

result2 = "";
for(i=0; i<base641.length; i++)
{
  char2 = base641.substr(i, 1);
  keychar = key.substr((i % key.length)-1, 1);
  char2 = String.fromCharCode(ord(char2)-ord(keychar));
  result2 += char2;
}

eval(result2);
EOF

  return $javascriptfunc;
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
