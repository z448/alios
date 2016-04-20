#!/usr/bin/env perl
#
use 5.010;
use warnings;
use strict;
use File::Find;
use Storable;
use Encode;
use Data::Dumper;
use Term::ANSIColor;
use Getopt::Std;
use JSON qw< encode_json >;
use open qw< :encoding(UTF-8) >;

my $option = {};
my (@app, @search_base, $storable, $json) = ();
@search_base = ("$ENV{HOME}/Containers/Data/Application","$ENV{HOME}/Containers/Shared/AppGroup");
$storable = "$ENV{HOME}/.alios.dat";
$json = "$ENV{HOME}/.alios.json";
getopts('d:m:f:', $option);

find( sub{ 
        my $i = 0;
        my %app = ();
        my $plist_path = "$File::Find::dir/$_";
        if($plist_path =~ /Library\/Preferences\/.*\.plist/){
            my $match = "$File::Find::dir/$_";
            $match =~ s/(.*)(\/App.*?\/)(.*?)(\/Library\/Preferences\/)(.*)(\.plist)/$1$2$3$4$5/;
            $app{apnr} = $i;
            $app{apid} = $5;
            $app{uuid} = $3;
            push @app,{%app};
            $i++;
}}, @search_base );

# --json
open(my $fh,">",$json);
$json = encode_json \@app;
print $fh $json;
close $fh; undef $fh;

# --storable
#eval { store($app, $storable) };
#print "Error writing to file: $@" if $@;
#$storable = retrieve($storable);

# --search appids
my $map = sub {
    my $filter = qr/$option->{f}/;
    my @filter = grep { $_->{"apid"} =~ /$filter/ } @app;
    \@filter;
};      

# --get app values
say $_->{apid} for( @{$map->()} );






        


