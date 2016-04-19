#!/usr/bin/env perl
#
use 5.010;
use File::Find;
use Encode;
use Data::Dumper;
use Term::ANSIColor;
use open qw< :encoding(UTF-8) >;

my @search_base = ("$ENV{HOME}/Containers/Data/Application","$ENV{HOME}/Containers/Shared/AppGroup");
my $app = {};

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







