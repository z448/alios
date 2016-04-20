#!/usr/bin/env perl
#
use 5.010;
use warnings;
use strict;
use File::Find;
use Storable qw<retrieve store>;
use Term::ANSIColor;
use Encode;
use Data::Dumper;
use Term::ANSIColor;
use Getopt::Std;
use JSON qw< encode_json >;
#use open qw< :encoding(UTF-8) >;

my $option = {};
my $apnr = 0;
my ($dumper, $config, @app, @base, $store, $json) = ();
getopts('d:m:f:i', $option);

# --- is in 'config';  DELETE
@base = ("$ENV{HOME}/Containers/Data/Application","$ENV{HOME}/Containers/Shared/AppGroup");
$dumper = "$ENV{HOME}/.alios.dmp";
$json = "$ENV{HOME}/.alios.json";
$config = "./config";
 
my $conf = {};  
$conf->{base}= \@base;
$conf->{store}=$store;
$conf->{json}=$json;

open(my $fh, ">",$config) or die "$! cant open: $config";
print $fh $conf;
close $fh;
# ---

my $init = sub {
    find( sub{ 
        my %app = ();
        my $plist_path = "$File::Find::dir/$_";
        if($plist_path =~ /Library\/Preferences\/.*\.plist/){
            my $match = "$File::Find::dir/$_";
            $match =~ s/(.*)(\/App.*?\/)(.*?)(\/Library\/Preferences\/)(.*)(\.plist)/$1$2$3$4$5$6/;
            $app{path} = $1 . $2 . $3 . $4;
            $app{plist} = $1 . $2 . $3 . $4 . $5 . $6;
            $app{apnr} = $apnr;
            $app{apid} = $5;
            $app{uuid} = $3;
            push @app,{%app};
            $apnr++;
        }
    },  @base );
};

# --init
$init->();

# --json write
open($fh,">",$json);
my $jay = encode_json \@app;
print $fh $jay;
close $fh;

# --dumper write
open(my $dmp, ">",$dumper);
print $dmp Data::Dumper->Dump([ \@app ],['app']);
close $dmp;

# --search appids
my $map = sub {
    my $filter = qr/$option->{f}/;
    my @filter = grep { $_->{"apid"} =~ /$filter/ } @app;
    return \@filter;
};      


# --get app values
say $_->{apid} for( @{$map->()} );

for( @{$map->()} ){
    if( -f $_->{plist}){ 
        say $_->{plist};
        say $_->{apid} . ' >> ' . 'ok';
    } else { 
        say colored(['cyan on_red'], $_->{apid} . ' >> ' . 'notok');
    }
}

for(keys %$option){
#    when(/^i$/)     { $init->() }
    when(/^s$/)     { $map->($option->{s}) }
    when(/^f$/)     { $map->($option->{f}) }
}

