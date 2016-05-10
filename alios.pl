#!/usr/bin/env perl

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
my ($alios_json, $alios, $app, @app, @base, $cache, $r) = ();

@base = ("$ENV{HOME}/Containers/Data/Application","$ENV{HOME}/Containers/Shared/AppGroup");
$cache = "/var/mobile/.alios.cache.json";
$alios = "/var/mobile/.alios";
$alios_json = "/var/mobile/.alios.json";

my $init = sub {
    say colored(['black on_yellow'], " init:");
    find( sub{ 
        my %app = ();
        my $apnr = 0;
        if( "$File::Find::dir/$_" =~ /Library\/Preferences\/.*\.plist/){
            my $match = "$File::Find::dir/$_";
            $match =~ s/(.*)(\/App.*?\/)(.*?)(\/Library\/Preferences\/)(.*)(\.plist)/$1$2$3$4$5$6/;
            $app{path} = $1 . $2 . $3;
            $app{plist} = $5 . $6;
            $app{plist_path} = $1 . $2 . $3 . $4 . $5 . $6;
            $app{apnr} = $apnr;
            $app{apid} = $5;
            $app{uuid} = $3;
            push @app,{%app};
            $apnr++;
    },  @base );
};

# reset; remove entrys in ~/.alioa
my $reset = sub {
    my $init_alios_json = '[{"name":"test"}]';
    open(my $fh,">",$alios_json) || die "cant open $alios_json";
    print $fh $init_alios_json;
    close $fh;
    return $init_alios_json;
};

# read stored values;
my $stored = sub {
    my $filter = shift;
    my @filter = ();
    if( ! -f $alios_json ){
        @filter = @{ decode_json $reset->() };
    } else {
        open(my $fh,"<",$alios_json) || die "cant open $alios_json: $!";
        @filter = @{ decode_json <$fh> };
        close $fh;
    } 
    return \@filter;
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

# write to shell env $alios
my $write_alios = sub {
    my $filter = shift;
    open(my $fh,">",$alios_json) || die "cant open $alios_json:$!";
    print $fh encode_json $filter;
    close $fh;

    for(@$filter){
        open($fh, ">>", $alios) || die "cant open $alios:$!";
        print $fh uc($_->{name}). '=' . $_->{path} . ';';
        print $fh 'alias ' .  $_->{name} . '="cd ' . $_->{path} . '"' . ';';
        print $fh $_->{name} . '=' . $_->{apid} . "\n";
        close $fh;
    }
    $list->('alios');
};

# search appids
my $search = sub {
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
# map
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
                $write_alios->(\@filter);
        }
    } else {
        # trigered w/ -s option, list apid/apnr tree
        $filter = lc qr/$filter/;
        @filter = grep { lc $_->{apid} =~ /$filter/ } @{deserialize()};
        #print Dumper(\@filter);# and die;
        return \@filter;
    }
};      

my $repath = sub {
    my $broken = shift;
    serialize();     
    say 'repath: $broken->{plist} = ' . $broken->{plist};
    my @filter = @{$stored->()};

    find( 
        sub { 
            if($_ eq $broken->{plist}){ 
                $broken->{plist_path} "$File::Find::dir/$_"; 
                
                @filter = grep { $broken->{plist} eq $_ } @filter;
                $write_alios->(\@filter);

                $broken->{plist_path} = "$File::Find::dir/$_"; 
                $broken->{plist} = "$_";
                $broken->{uuid} = $broken->{plist_path};
                $broken->{uuid} =~ s/(.*)(\/App.*?\/)(.*?)(\/Library\/Preferences\/)(.*)(\.plist)/$1$2$3$4/;
                $broken->{uuid} = $3;
                $broken->{path} = $1 . $2 . $3;

                push @filter, $broken; 
                write_alios->(\@filter);
            } 
        }, @base
    )
};

# check broken paths  
my $check = sub {
    say "check: ";
    for(@{$stored->('alios')}){
        if( ! -f $_->{plist_path}){
            say "repath: broken link $_->{plist_path}" and $repath->($_);
        }
    }
};  

# json write
sub serialize {
    $init->();
    say "serialize: ";
    open(my $jfh,">",$cache) || die "cant open $cache: $!";
    my $j = encode_json \@app;
    print $jfh $j;
}

# json read
sub deserialize {
    open(my $jfh,"<",$cache) || die "cant open $cache: $!";
    my $j = <$jfh>;
    my $p = decode_json $j;
    return \@$p;
}

if(defined $option->{i}){
    $init->() and die;
    serialize() and say Dumper(deserialize());

} elsif( defined $option->{f} ){
    print Dumper($search->($option->{f}));
} elsif(defined $option->{p}){
    $check->();
} elsif( defined $option->{m} ){
    $search->($option->{m}, $option->{n});
} elsif(defined $option->{d}){
    say Dumper($search->($option->{d}));
} elsif(defined $option->{r}){
    my $jtest = $reset->();
    my $ptest = decode_json $jtest;
    print Dumper($ptest);
} elsif (defined $option->{h}){
    system("perldoc $0");
} elsif (defined $option->{s}){
    $list->();
} else {
    $list->('alios');
}

=head1 NAME

=over 10

=item alios - creates aliases/variables for iOS UUID folders 

back

=head1 SYNOPSIS

=over 10

=item source ~/.alios from ~/.bashrc

C<alios -p && source ~/.alios>

=item initialize

C<alios -i>

=item map alias

C<alios -m nr -n name>

=item delete saved alias

C<alios -d name>

=item list saved aliases

C<alios>

=item list all display IDs in ~/Container directory

C<alios -s>

=item search app

C<alios -f keyword>

=item reset; clear all entrys in ~/.alios config

C<alios -r>

=item perldoc/help

C<alios -h>

=back

=head1 DESCRIPTION

=over 10

Searches for display IDs in C<~/Container> directories to create L<alias> for application directory path. 

Path is assigned to L<$VARIABLE> to use in script, display ID is assigned to L<$variable> to use with other tools such as activator, open etc.

=back

=cut

