#!/usr/bin/env perl
#
use 5.010;
use File::Find;
use Storable;
use Encode;
use Data::Dumper;
use Term::ANSIColor;
use Getopt::Std;
use FreezeThaw qw< freeze thaw>;
use JSON qw< encode_json >;
use open qw< :encoding(UTF-8) >;
use FreezeThaw qw(freeze thaw); # Import freeze() and thaw()

my $option = {};
my ($storage, $serialize, $freezethaw, $storable, $json) = ();
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

# --dumper
my $dumper = Data::Dumper->Dump([$app]);
open(my $fh,">",$dump);
print $dumper;
print $fh $dumper;
close $fh; undef $fh;

open(my $fh,">",'dumper');
print $fh $dumper;
close $fh; undef $fh;

open($fh,"<","$ENV{HOME}/.alios.dmp");
while(<$fh>){ $storage .= $_ }
close $fh; undef $fh;

eval $storage;
#print Dumper($conf);
print $VAR1->{"com.opera.Coast.plist"};

# --json
open(my $fh,">","json");
$json = encode_json $app;
print $fh $json;
close $fh; undef $fh;

# --freezethaw
$freezethaw = freeze($app, $obj);
open (F, "> freezethaw") || die;
syswrite (F, $freezethaw, length($freezethaw)); # can also use write() or print()

# --storable
eval { store($app, 'storable.dat') };
print "Error writing to file: $@" if $@;
$storable = retrieve('storable.dat');

