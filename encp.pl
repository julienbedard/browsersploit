#!/usr/bin/perl

#
# Xor with password
#

use MIME::Base64;

$file = $ARGV[0];

open(ENC, ">>$file.enc");
open(PLAIN, "<$file");
while (<PLAIN>)
{
  $input .= $_;
}
close(PLAIN);

# Do encryption operation
chomp($input);
$mama = encode_base64($input);

#Complete the Sub
$sub = 'sub decry ($){ local($^W) = 0;my $str = shift;my $res = "";
$str =~ tr|A-Za-z0-9+=/||cd;$str =~ s/=+$//;  $str =~ tr|A-Za-z0-9+/| -_|;  
while ($str =~ /(.{1,60})/gs) {my $len = chr(32 + length($1)*3/4); 
$res .= unpack("u", $len . $1 ); }$res;}';

#save to encfile
print ENC <<EOF;
#!/usr/bin/perl

#
#  This module is a part of Ez Install Converter
#
#  Do not modify this file
#
#  Use on your own systems only or where you have
#  permission to use this tool.
#

$sub
my \$crojhg = '$mama';
eval(decry(\$crojhg));

EOF
close(ENC);

unlink("$file");
rename "$file.enc",$file;
