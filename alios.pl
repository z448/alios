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
getopts('sm:n:f:pi', $option);
my $apnr = 0;
my ( $alios_json, $alios, $dfhr, $app, @app, @base, $store, $cache ) = ();

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

sub del {
    open(my $fh, "<", $alios_json) || die "cant open $alios_json: $!";
    my $j = decode_json <$fh>;
    for(@$j){
        say colored(['white on_red'], $_->{apid});
    }
    close $fh;
}

sub write {
    my $filter = shift;
    # write old+new values into $alios_json
            open(my $fh,">",$alios_json) || "cant open $alios_json:$!";
            print $fh encode_json \@filter;
            close $fh;
            return \@filter
}

# --searchmap appids
my $searchmap = sub {
    my $filter = shift;
    my $name = shift;
    my @filter = ();

    # read stored values; todo: delete from stored values
    open(my $fh,"<",$alios_json) || die "cant open $alios_json:$!";
    my $j = <$fh>;
    @filter = @{ decode_json $j };
    close $fh;
    
    # delete entry from $alios_json
    if(defined $option->{d}){
        my @d = grep { $_->{name} eq $filter } @$p;
        for(@d){ undef $_ }
    }

    if( defined $option->{m} and defined $option->{n}){
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
            open(my $fh, ">>", $alios) || "cant open $alios:$!";
            print $fh uc($_->{name}). '=' . $_->{path} . ';';
            print $fh 'alias ' .  $_->{name} . '="cd ' . $_->{path} . '"' . ';';
            print $fh $_->{name} . '=' . $_->{apid} . "\n";
            close $fh;
            }
            write(\@filterr)
    } else {
        # trigered w/ -s option, list apid/apnr tree
        $filter = lc qr/$filter/;
        @filter = grep { lc $_->{apid} =~ /$filter/ } @{deserialize()};
        print Dumper(\@filter) and die;
        return \@filter;
    }
};      

my $search = sub {
        my @filter = grep { $_->{apnr} =~ /.*/ } @{deserialize()};
        for(@filter){
            my $ln = length $_->{apid};
            my $tail = $_->{apid}; $tail =~ s/(.*\.)(.*)/$2/;
            say " " x $ln . "$tail" . colored(['yellow'], "__") . colored(['black on_yellow'], " $_->{apnr}"); 
        }
};
    

say colored(['black on_yellow'], "  option:");#----------------debug
if(defined $option->{i}){
    $init->(); serialize() and say "init; serialize"; 
    say Dumper(deserialize());
} elsif(defined $option->{f}){
    print Dumper($searchmap->($option->{f}));
} elsif(defined $option->{p}){
    $check->();
} elsif(defined $option->{m}){
    say Dumper($searchmap->($option->{m}, $option->{n}));
} elsif(defined $option->{s}){
    say Dumper($search->());
}


__DATA__

=head1 NAME

=over 16

=item alios - creates aliases/variables for iOS UUID folders 

back

=head1 SYNOPSIS

=over 16

force init

=item C<alios -i>

-source from ~/.bashrc or ~/.bash_profile

=item C<alios -p && source ~/.alios>

-search app
=item C<alios [-f] [keyword]>

-map alias and $variable
=item C<alios [-m] nr [-n] appname>

=back

=head1 DESCRIPTION

=over 16

=item Loops over application UUIDs in C<~/Container> directories and generate display IDs which can be used to create L<alias> for directory path. Additionaly, env C<$VARIABLE> is created to use in scripts and C<$variable> display id of application to use with other tools such as activator, open etc.

=back

=cut

