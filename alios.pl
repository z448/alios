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
use JSON qw< encode_json decode_json>;
use open qw< :encoding(UTF-8) >;

my $option = {};
getopts('s:m:n:f:pi', $option);
my $apnr = 0;
my ( $dfhr, $dumper, $app, $config, @app, @base, $store, $json ) = ();

# --- is in 'config';  DELETE
@base = ("$ENV{HOME}/Containers/Data/Application","$ENV{HOME}/Containers/Shared/AppGroup");
$dumper = "$ENV{HOME}/.alios.dmp";
$json = "$ENV{HOME}/.alios.json";
$config = "./config";

my $init = sub {
    say colored(['black on_yellow'], " init:"); #----------------debug
    find( sub{ 
        my %app = ();
        if( "$File::Find::dir/$_" =~ /Library\/Preferences\/.*\.plist/){
            my $match = "$File::Find::dir/$_";
            $match =~ s/(.*)(\/App.*?\/)(.*?)(\/Library\/Preferences\/)(.*)(\.plist)/$1$2$3$4$5$6/;
            $app{path} = $1 . $2 . $3 . $4;
            $app{plist} = $1 . $2 . $3 . $4 . $5 . $6;
            $app{apnr} = $apnr;
            $app{apid} = $5;
            $app{uuid} = $3;
            push @app,{%app};
            $apnr++;
        } #else { print "$_ \," }
    },  @base );
};

my $repath = sub {
    my $broken = shift;
    say colored(['black on_yellow'], " repath:"); #---------------debug
    say "broken links:";
    for(@$broken){
        print colored(['black on_red'], "\t" . $_->{apid});
    }
    $init->(), serialize(); deserialize();
};

my $check = sub {
    say colored(['black on_yellow'], " check:"); #----------------debug
    my @broken = ();
    for( @app ){
        if( ! -f $_->{plist}){
            say colored(['yellow'], $_->{apid});
            push @broken, $_;
        }
    }
    if (@broken){
        $repath->(\@broken) 
    } else { say "no broken links" and return; }
};  


sub serialize {
# --json write
    say colored(['black on_yellow'], " serialize:") . "json"; #---------------debug
    open(my $jfh,">",$json) || die "cant open $json: $!";
    my $j = encode_json \@app;
    print $jfh $j;
}

# --json read
sub deserialize {
    open(my $jfh,"<","$json");
    local $\ = undef;
    my $j = <$jfh>;
    my $p = decode_json $j;
    return \@$p;
}

#say colored(['yellow'],'deserialized') if deserialize();
#say @{deserialize()}; #-------------to list all hash ref 

# --search appids
my $search = sub {
    my $filter = shift;
    my $name = shift;
    my @filter = ();

    if( $filter =~ /\d+/){
        @filter = grep { $_->{apnr} eq $filter } @{deserialize()};
        for(@filter){
            if(defined $option->{n}){
                $_->{name} = $name;
            } else {
                $name = $_->{apid}; $name =~ s/(.*\.)(.*)/$2/;
                $_->{name} = $name;
            }
        }
    return \@filter;
    }
    say colored(['black on_yellow'], " search:") . "filter"; #----------------debug
    $filter = lc qr/$option->{s}/;
    @filter = grep { lc $_->{apid} =~ /$filter/ } @{deserialize()};
    return \@filter;
};      

say colored(['black on_yellow'], "  option:");#----------------debug
if(defined $option->{i}){
    $init->(); serialize() and say "init; serialize"; 
    say Dumper(deserialize());
} elsif(defined $option->{s}){
    deserialize();
    print Dumper($search->());
} elsif(defined $option->{p}){
    $check->();
} elsif(defined $option->{m}){
    say Dumper($search->($option->{m}, $option->{n}));
}
__DATA__

=head1 NAME

=over 16

=item alios - jump over iOS application UUIDs 

=back

=head1 SYNOPSIS

=over 16

-force init

=item C<alios -i>

-source from ~/.bashrc or ~/.bash_profile

=item C<alios -p && source ~/.alios>

-search app
=item C<alios [-s] [keyword]>

-map alias and $variable
=item C<alios [-m] [nr appname]>

- initialize
=item C<alios [-i]>

=back

=head1 DESCRIPTION

=over 16

=item Loops through application UUIDs in C<~/Container> directories and assign numbers to display IDs which can be used to create L<alias> for directory path that can be used to quickily switch into application directory. Additionaly, env C<$VARIABLE> is created to use in scripts and C<$variable> display id of application to use with other tools such as activator, open etc.

=back

=cut

