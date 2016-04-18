#!/usr/bin/env perl

use 5.010;
use warnings;
use strict;
use Encode;
use Data::Dumper;
use JSON;

my $cache = $ARGV[0] ||  "$ENV{HOME}/.alios.cache";


my $alios_cache = sub {
    my $c = shift;
    my @app = ();
    my %app = ();

    open( my $fh, "<:encoding(UTF-8)", $c );
    while(<$fh>){
           my $id = '';
           my $path = '';
        if(/app\[/){
           s/(app.*?\=\/)(.*)/$2/;
           $path=$2;
        } 
        if(/^open\[/){
            # say $_;
           s/(^open\=)(\')/$2/;
           $id = $2;
        }
        $app{"$id"} = "$path";
        #push @app, \%app;
    }; close $fh;
    return \%app;
};

my $alios_app = $alios_cache->($cache);

print Dumper($alios_app);
#my $json = encode_json $alios_app;

#say $json;

#for my $app( @$alios_app ){
#    for(keys %$app){
#        chomp($app->{$_});
#        print $_ . ' -> ' . $app->{$_} . "\n";
#    }
        # say Dumper($_);
        #say $_ . '->' . $hash->{$_};
#}
#. ' -> ' . "$alios_app->{$_}";
