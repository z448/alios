#!/usr/bin/env perl
#
use 5.010;
use File::Find;
use Storable;
use Encode;
use Data::Dumper;
use Term::ANSIColor;
use Getopt::Std;
use JSON qw< encode_json >;
use open qw< :encoding(UTF-8) >;

my $option = {};
my $app = {};
my (@search_base, $storable, $json) = ();
my @search_base = ("$ENV{HOME}/Containers/Data/Application","$ENV{HOME}/Containers/Shared/AppGroup");
$storable = "$ENV{HOME}/.alios.dat";
$json = "$ENV{HOME}/.alios.json";
getopts('d:m:f:', $option);

find( sub{ 
        my $i = 0;
        my $plist_path = "$File::Find::dir/$_";
        if($plist_path =~ /Library\/Preferences\/.*\.plist/){
            my $match = "$File::Find::dir/$_";
            $match =~ s/(.*)(\/App.*?\/)(.*?)(\/Library\/Preferences\/)(.*)(\.plist)/$1$2$3$4$5/;
            $app->{apnr} = $i;
            $app->{apid} = $5;
            $app->{uuid} = $3;
            $i++;
}}, @search_base );

#for(keys %$app){
#    print colored(['green'], 'appid: ') . $_ . "\n";
#    print colored(['green'], 'uuid : ') . $app->{$_} . "\n";
#}

# --json
open(my $fh,">",$json);
$json = encode_json $app;
print $fh $json;
close $fh; undef $fh;

# --storable
#eval { store($app, $storable) };
#print "Error writing to file: $@" if $@;
#$storable = retrieve($storable);

my $map = sub {
    my $apid = shift;
    my @match = grep { $app->{apid} eq $apid } %$app;

    for(@match){ say $_ }
};

$map->($option->{f});
__DATA__
my @all_matches = grep { $fruit{$_} eq 'yellow' } keys %fruit;
print("$_ ") foreach @matching_keys;

my ($any_match) = grep { $fruit{$_} eq 'yellow' } keys %fruit;



