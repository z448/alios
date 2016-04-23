#!/usr/bin/env perl

use 5.010;
use Encode;
use File::Path qw< make_path remove_tree >;
use Data::Dumper;

my $switch = $ARGV[0] || 'create';
my $contain = "Container";
my @containers = ("Containers/Data/Application/FC3256EE-C34F-FC21-AS45-FC3256EE/Library/Preferences", "Containers/Shared/AppGroup/F34F5232-C34F-FC21-AS45-FC3256EE/Library/Preferences");
my $plist = "test.alios.plist";

if($switch eq '-d'){
        remove_tree("$ENV{HOME}/$contain") or die "$!";
        print "removed: $contain";
} elsif($switch eq 'create'){
    for(@containers){
        make_path("$ENV{HOME}/$_");
        open(my $fh, ">:encoding(UTF-8)", "$ENV{HOME}/$_/$plist");
        print $fh 'alios test';
        close $fh;
        say "created: $_/$plist";
    }
}
