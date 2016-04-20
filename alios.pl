#!/usr/bin/env perl
#
use 5.010;
use File::Find;
use Storable;
use Encode;
use Data::Dumper;
use Term::ANSIColor;
use Getopt::Std;
use Sys::Hostname;
use JSON qw< encode_json >;
use open qw< :encoding(UTF-8) >;

my $option = {};
my $app = {};
my (@search_base, $storable, $json) = ();
my @search_base = ("$ENV{HOME}/Containers/Data/Application","$ENV{HOME}/Containers/Shared/AppGroup");
$storable = "$ENV{HOME}/.alios.dat";
$json = "$ENV{HOME}/.alios.json";
getopts('d:m:s', $option);


# --find hostname, if not ios use local test env
$host = hostname;
say "$host";
if( $host =~ /ria/){
    say "IN RIA";
    @search_base = ("Containers/Data/Application","Containers/Shared/AppGroup");
    $storable = ".alios.dat";
    $json = ".alios.json";
};

say $storable;


find( sub{ 
        my $plist_path = "$File::Find::dir/$_";
        if($plist_path =~ /Library\/Preferences\/.*\.plist/){
            my $match = "$File::Find::dir/$_";
            print $match;
            $match =~ s/(.*)(\/App.*?\/)(.*?)(\/Library\/Preferences\/)(.*\.plist)/$3$5/;
            $app->{$5} = $3;
}}, @search_base );

for(keys %$app){
    print colored(['green'], 'appid: ') . $_ . "\n";
    print colored(['green'], 'uuid: ') . $app->{$_} . "\n";
}

# --json
open(my $fh,">",$json);
$json = encode_json $app;
print $fh $json;
close $fh; undef $fh;

# --storable
eval { store($app, $storable) };
print "Error writing to file: $@" if $@;
$storable = retrieve($storable);

