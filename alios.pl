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
getopts('s:m:f:i', $option);
my $apnr = 0;
my ($dfh_r, $dumper, $app, $config, @app, @base, $store, $json) = ();

# --- is in 'config';  DELETE
@base = ("$ENV{HOME}/Containers/Data/Application","$ENV{HOME}/Containers/Shared/AppGroup");
$dumper = "$ENV{HOME}/.alios.dmp";
$json = "$ENV{HOME}/.alios.json";
$config = "./config";

=head1
my $conf = {};  
$conf->{base}= \@base;
$conf->{store}=$store;
$conf->{json}=$json;

open(my $fh, ">",$config) or die "$! cant open: $config";
print $fh $conf;
close $fh;
=cut

my $repath = sub {
    my $broken = shift;
    say colored(['black on_yellow'], '$repath: ->') . ""; #---------------debug
    say "broken links:";
    for(@$broken){
        say $_->{apid};
    }
};

my $serialize = sub {
# --json write
    say colored(['black on_yellow'], '$serialize: ->') . "json"; #---------------debug
    open(my $jfh,">",$json) || die "cant open $json: $!";
    my $jay = encode_json \@app;
    print $jfh $jay;
    close $jfh; 
    $jfh = undef;

# --dumper write
    say colored(['black on_yellow'], '$serialize: ->') . "dumper"; #----------------debug
    open(my $dfh, ">",$dumper) || die "cant open $dumper: $!";
    print $dfh Data::Dumper->Dump([ \@app ],['app']);
    close $dfh;
};  

# --dumper read
my $deserialize = sub {
    my $a = [];
    say colored(['black on_yellow'], '$deserialize: ->') . "dumper"; #----------------debug
    open(my $dfhr,"< $dumper") or die "Cant open $dumper: $!";
#or close $dfh_r and say "cant open $dumper:$!\n reserialze..." and $serialize->() and return; 
    local $/ = undef;  # read whole file
    $a = <$dfhr>;
    #close $dfh_r;
    return @{ eval @$a };
};
say $deserialize->() and die;

# --search appids
my $search = sub {
    my $filter = shift;
    say colored(['black on_yellow'], '$search: ->') . "$filter"; #----------------debug
    $filter = qr/$filter/;
    my @filter = grep { $_->{"apid"} =~ /$filter/ } @{$deserialize->()};
    return \@filter;
};      

#$init->();
#say  $_->{apid} for(@{$search->($option->{s})});

my $check = sub {
    say colored(['black on_yellow'], '$check: ->') . "plists"; #----------------debug
    my @broken = ();
    for( @{$deserialize->()} ){
        if( ! -f $_->{plist}){
            # ------------------------todo: create $repath->($_->{plist})
            say colored(['yellow'], $_->{apid} . ' >> ' . 'path broken');
            push @broken, $_;
        }
    }
    $repath->(\@broken);
};  

my $init = sub {
    say colored(['black on_yellow'], '$init: ->') . "..."; #----------------debug
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

say "check" unless ($check->());

sub option {
    say colored(['black on_yellow'], ' option: ->') . "..."; #----------------debug

    # initialize (-i)
    if(defined $option->{i}){
        $init->(); $serialize->() and say " option\$option->{i} \$init->(); \$serialize->()..."; 
    } 
    # search (-s keyword) 
    elsif(defined $option->{s}){
        my $s = $search->($option->{s});
        say "\$option->(s): say \$_->{apnr} ..."; 
        print Dumper($s);

        #for(@$s){
        #    say 'search results: ' . $_->{apid};
        #}
    } 
}
option();
# --check $app->{plist} after each alios command

=head1 NAME

=over 16

=item alios - jump over iOS application UUIDs 

=back

=head1 SYNOPSIS

=over 16

-source from ~/.bashrc or ~/.bash_profile

=item C<alios -p && source ~/.alios>

-search app
=item C<alios [-s] [keyword]>

-map alias and $variable
=item C<alios [-m] [nr appname]>

- inifialize
=item C<alios [-i]>

=back

=head1 DESCRIPTION

=over 16

=item Loops through application UUIDs in C<~/Container> directories and assign numbers to display IDs which can be used to create L<alias> for directory path that can be used to quickily switch into application directory. Additionaly, env C<$VARIABLE> is created to use in scripts and C<$variable> display id of application to use with other tools such as activator, open etc.

=back

=cut




