#!/usr/bin/env perl
#
use 5.010;
use warnings;
use strict;

use File::Find;
use Term::ANSIColor;
use Encode;
use Data::Dumper;
use Term::ANSIColor;
use Getopt::Std;
use JSON qw< encode_json decode_json>;
use open qw< :encoding(UTF-8) >;

my $option = {};
getopts('rhsm:d:n:f:pi', $option);
my $apnr = 0;
my ( $alios_json, $alios, $app, @app, @base, $cache ) = ();

# --- is in 'config';  DELETE
@base = ("$ENV{HOME}/Containers/Data/Application","$ENV{HOME}/Containers/Shared/AppGroup");
$cache = "$ENV{HOME}/.alios.cache.json";
$alios = "$ENV{HOME}/.alios";
$alios_json = "$ENV{HOME}/.alios.json";

my $init = sub {
    say colored(['black on_yellow'], " init:"); #----------------debug
    find( sub{ 
        my %app = ();
        if( "$File::Find::dir/$_" =~ /Library\/Preferences\/.*\.plist/){
            my $match = "$File::Find::dir/$_";
            $match =~ s/(.*)(\/App.*?\/)(.*?)(\/Library\/Preferences\/)(.*)(\.plist)/$1$2$3$4$5$6/;
            $app{path} = $1 . $2 . $3;
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

my $list = sub {
    my $mode = shift || 'all';
    my @filter = ();

    if($mode eq 'alios'){
        print colored(['black on_yellow']," alios ");
        for(@{$stored->()}){
            print ' ' . $_->{name};
        }
        print ' ' . colored(['black on_yellow'], " ") . "\n";
    } elsif($mode eq 'all') {
        @filter = grep { $_->{apnr} =~ /.*/ } @{deserialize()};
    }
    for(@filter){
        my $ln = length $_->{apid};
        my $tail = $_->{apid}; $tail =~ s/(.*\.)(.*)/$2/;
        say " " x $ln . "$tail" . colored(['yellow'], "__") . colored(['black on_yellow'], " $_->{apnr}"); 
    }
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
    } else { 
        say "no broken links" and return;
    }
    $list->('alios');
};  


sub serialize {
# --json write
    say colored(['black on_yellow'], " serialize:") . "json"; #---------------debug
    open(my $jfh,">",$cache) || die "cant open $cache: $!";
    my $j = encode_json \@app;
    print $jfh $j;
}

# --json read
sub deserialize {
    open(my $jfh,"<",$cache) || die "cant open $cache: $!";
    local $\ = undef;
    my $j = <$jfh>;
    my $p = decode_json $j;
    return \@$p;
}

# --write old+new values into $alios_json
my $write_alios = sub {
    my $write = shift;
    open(my $fh,">",$alios_json) || die "cant open $alios_json:$!";
    print $fh encode_json $write;
    close $fh;
};

my $reset = sub {
    my $init_json = '[{}]';
    open(my $fh,">",$alios_json) || die "cant open $alios_json";
    print $fh $init_json;
    close $fh;
    return $init_json
};


my $stored = sub {
    my @filter = ('[{}]');
# read stored values;
    if( ! -f $alios_json ){
        @filter = @{ decode_json $reset->() };
    } else {
        open(my $fh,"<",$alios_json) || die "cant open $alios_json: $!";
        @filter = @{ decode_json <$fh> };
        close $fh;
    } 
    return \@filter;
};

# --searchmap appids
my $searchmap = sub {
    my ($filter, $name) = @_;
    my (@filter, @alios, $fh) = ();

    @filter = @{$stored->()};
    # delete entry from $alios_json
    if(defined $option->{d}){
        @alios = grep { $_->{name} ne $filter } @filter;
        $write_alios->(\@alios);
        $list->('alios');
    } 
    elsif( defined $option->{m} and defined $option->{n}){
        my @f = grep { $_->{apnr} eq $filter } @{deserialize()};
        for(@f){
                if(defined $option->{n}){
                    $_->{name} = $name;
                } else {
                    $name = $_->{apid}; $name =~ s/(.*\.)(.*)/$2/;
                    $_->{name} = $name;
                }
                # concatenate stored $alios_json w/ new map
                @filter = (@filter, @f);

                # write to shell env $alios
                open($fh, ">>", $alios) || die "cant open $alios:$!";
                print $fh uc($_->{name}). '=' . $_->{path} . ';';
                print $fh 'alias ' .  $_->{name} . '="cd ' . $_->{path} . '"' . ';';
                print $fh $_->{name} . '=' . $_->{apid} . "\n";
                close $fh;
                $write_alios->(\@filter);
        }
    } else {
        # trigered w/ -s option, list apid/apnr tree
        $filter = lc qr/$filter/;
        @filter = grep { lc $_->{apid} =~ /$filter/ } @{deserialize()};
        print Dumper(\@filter);# and die;
        return \@filter;
    }
};      

    

if(defined $option->{i}){
    $init->(); serialize() and say Dumper(deserialize());
} elsif( defined $option->{f} ){
    print Dumper($searchmap->($option->{f}));
} elsif( defined $option->{p} ){
    $check->();
} elsif( defined $option->{m} ){
    say Dumper($searchmap->($option->{m}, $option->{n}));
} elsif(defined $option->{d}){
    say Dumper($searchmap->($option->{d}));
} elsif(defined $option->{r}){
    reset->();
} elsif (defined $option->{h}){
    system("perldoc $0");
} elsif (defined $option->{s}){
    $list->();
} else {
    $list->('alios');
}

    



__DATA__

=head1 NAME

=over 10

=item alios - creates aliases/variables for iOS UUID folders 

back

=head1 SYNOPSIS

=over 10

=item initialize

C<alios -i>

=item C<source from ~/.bashrc or ~/.bash_profile>

C<alios -p && source ~/.alios>

-search app
=item C<alios -f keyword>

-map alias
=item C<alios -m nr -n name>

=back

=head1 DESCRIPTION

=over 10

Searches for display IDs in C<~/Container> directories to create L<alias> for application directory path. 

Path is assigned to L<$VARIABLE> to use in script, display ID is assigned to L<$variable> to use with other tools such as activator, open etc.

=back

=cut

