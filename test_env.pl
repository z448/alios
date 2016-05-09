#!/usr/bin/env perl

use 5.010;
use Encode;
use File::Path qw< make_path remove_tree >;
use Data::Dumper;
use UUID::Tiny qw<:std>;

my $switch = $ARGV[0] || 'create';
my $contain = "Containers";
my $uuid  = sub { return uc create_uuid_as_string(UUID_V1) };

my $uuid1 = $uuid->();
my $uuid2 = $uuid->();

#my @containers = (qq|Containers/Data/Application/$uuid1/Library/Preferences|, qq|Containers/Shared/AppGroup/$uuid2/Library/Preferences|);
my @containers = (qq|Containers/Data/Application/$uuid1/Library/Preferences|);
my $plist = "com.test.plist";

if($switch eq '-d'){
    #remove_tree("$ENV{HOME}/$contain") or die "$!";
       print "-d option is disabled; edit test_env.sh to enable it";
} elsif($switch eq 'create'){
    for(@containers){
        make_path("$ENV{HOME}/$_");
        open(my $fh, ">:encoding(UTF-8)", "$ENV{HOME}/$_/$plist");
        print $fh 'alios test';
        close $fh;
        say "created: $_/$plist";
    }
}
