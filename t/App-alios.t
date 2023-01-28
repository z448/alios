# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl App-alios.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 2;
BEGIN { use_ok('App::alios') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use POSIX qw(uname);

my $expect_os = 'iOS';
my @uname = uname();
my $os = '';

for(@uname){
	if(/iPhone/){ $os = 'iOS' }
}

ok( $os eq $expect_os, 'os_test' )


