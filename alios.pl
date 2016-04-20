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
use open qw< :encoding(UTF-8) >;

my $option = {};
my (@app, @base, $store, $json) = ();
getopts('d:m:f:i', $option);

#--- is in 'config';  DELETE
@base = ("$ENV{HOME}/Containers/Data/Application","$ENV{HOME}/Containers/Shared/AppGroup");
$store = "$ENV{HOME}/.alios.dat";
$json = "$ENV{HOME}/.alios.json";

my $conf = {};
$conf->{base}= \@base;
$conf->{store}=$store;
$conf->{json}=$json;

store $conf, 'config';
undef $conf;
#---

$conf = retrieve('config');
print Dumper($conf);

my $init = sub {
    find( sub{ 
        my $i = 0;
        my %app = ();
        my $plist_path = "$File::Find::dir/$_";
        if($plist_path =~ /Library\/Preferences\/.*\.plist/){
            my $match = "$File::Find::dir/$_";
            $match =~ s/(.*)(\/App.*?\/)(.*?)(\/Library\/Preferences\/)(.*)(\.plist)/$1$2$3$4$5/;
            $app{path} = $1 . $2 . $3 . $4;
            $app{plist} = $1 . $2 . $3 . $4 . $5 . $6;
            $app{apnr} = $i;
            $app{apid} = $5;
            $app{uuid} = $3;
            push @app,{%app};
            $i++;
        }
    },  @base );

# --json
    open(my $fh,">",$json);
    my $jay = encode_json \@app;
    print $fh $jay;
    close $fh; undef $fh;
# --storable
    store \@app, $store;
    return \@app;
};

# --init
$init->();
# --retrive file

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
    when(/^i$/)     { $init->() }
    when(/^s$/)     { $map->($option->{s}) }
    when(/^f$/)     { $map->($option->{f}) }
}

