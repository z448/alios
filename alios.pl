#!/usr/bin/env perl
#
use 5.010;
use File::Find;
use Encode;
use Data::Dumper;
use Term::ANSIColor;
use Getopt::Std;
use JSON qw< encode_json >;
use open qw< :encoding(UTF-8) >;

my $option = {};
my ($storage) = ();
my $dump = "$ENV{HOME}/.alios.dmp";
my @search_base = ("$ENV{HOME}/Containers/Data/Application","$ENV{HOME}/Containers/Shared/AppGroup");
my $app = {};
getopts('d:m:s', $option);

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

my $dumper = Data::Dumper->Dump([$app]);
open(my $fh,">",$dump);
print $dumper;
print $fh $dumper;
close $fh; undef $fh;

open($fh,"<","$ENV{HOME}/.alios.dmp");
while(<$fh>){ $storage .= $_ }
close $fh; undef $fh;


#print Dumper($conf);
eval $storage;
print $VAR1->{"com.opera.Coast.plist"};

my $json = encode_json $app;
#print $json;
