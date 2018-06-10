#!/bin/perl

use Net::HTTP;
use MIME::Base64;

my $datetime = localtime();                 
print "--->Starting script at " . $datetime . "\n"; # returns Fri Sep 10 12:19:13 1999

print "--->Defining variables" . "\n";
my $host = $ARGV[0];
my $url = $ARGV[1];
my $method = "GET";
my $args = ""; # any extra data to pass (ie, POST arguments)
my $useragent = "Mozilla/5.0";
my $user = $ARGV[2];
my $password = $ARGV[3];

print "--->Generating base64 encoding (hash)" . "\n";
my $hash = encode_base64($user . ":" . $password);

print "--->Setting up some default values" . "\n";
$myrequest_header{'Host'} = "$host" if $myrequest_header{'Host'} eq "";
$myrequest_header{'User-Agent'} = $useragent;
if($hash ne "") { $myrequest_header{'Authorization'} = "Basic " . $hash; }
if($myrequest_header{'Content-Type'} eq "" ) { $myrequest_header{'Content-Type'} = "text/html"; }

while( ($_, my $value) = each(%myrequest_header) ) {
    # Make sure no tokens are blank/non-characters, will cause HTTP errors if not filtered
    if(! m/\w+/ ) {
        delete $myrequest_header{$_};
    }
}

print "--->Defining the HTTP objects" . "\n";
my $http = Net::HTTP->new(Host => $host) || die $@;

print "--->Running the HTTP method" . "\n";
$http->write_request("$method", "$url", %myrequest_header, "$args");
my($code, $mess, %h) = $http->read_response_headers;
# Check HTTP return
if ($code ne "200") {
    print "--->HTTP ERROR: " , $code , " " , $mess , "\n";
    print "--->Finishing script at " . $datetime . "\n";
    exit 1;
}

print "--->Reading the HTML content" . "\n";
# Confirm whether an application has error
my $app_error = "OK";
my $line = "";
while (1) {
	my $buf;
	my $n = $http->read_entity_body($buf, 1024);
	last unless $n;
	print $buf;
	$line = $buf;
	#print $line;
	if(uc($line) =~ /ERROR/) {
		$app_error = "ERROR";
	}
}

#print $app_error;
print "--->Making sure whether result has the word ERROR" . "\n";
if ( $app_error eq "ERROR" ) {
    print "--->APPL ERROR: " . $line . "\n";
    print "--->Finishing script at " . $datetime . "\n";
    exit 1;
} else {
    print "--->OK" . "\n";
    print "--->Finishing script at " . $datetime . "\n";
    exit 0;
}

