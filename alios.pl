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
my ($dumper, $app, $config, @app, @base, $store, $json) = ();

# --- is in 'config';  DELETE
@base = ("$ENV{HOME}/Containers/Data/Application","$ENV{HOME}/Containers/Shared/AppGroup");
$dumper = "$ENV{HOME}/.alios.dmp";
$json = "$ENV{HOME}/.alios.json";
$config = "./config";
 
my $conf = {};  
$conf->{base}= \@base;
$conf->{store}=$store;
$conf->{json}=$json;

open(my $fh, ">",$config) or die "$! cant open: $config";
print $fh $conf;
close $fh;
# ---

my $serialize = sub {
# --json write
    say colored(['green'], '$serialize: ') . "json"; #---------------debug
    open(my $jfh,">",$json) || die "cant open $json: $!";
    my $jay = encode_json \@app;
    print $jfh $jay;
    close $jfh; 
    $jfh = undef;

# --dumper write
    say colored(['green'], '$serialize: ') . "dumper"; #----------------debug
    open(my $dfh, ">",$dumper) || die "cant open $dumper: $!";
    print $dfh Data::Dumper->Dump([ \@app ],['app']);
    close $dfh;
};  

# --dumper read
sub deserialize {
    say colored(['green'], '$deserialize: ') . "dumper"; #----------------debug

    open(my $fh,"<",$dumper) || close $fh and say "cant open $dumper:$!\n reserialze..." and $serialize->() and return; 
    local $/ = undef;  # read whole file
    my $app = <$fh>;
    close $fh;
    return @{ eval $app };
}
# --deserialize in first step
deserialize();

my $init = sub {
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


# --search appids
my $search = sub {
    my $filter = shift;
    $filter = qr/$filter/;
    my @filter = grep { $_->{"apid"} =~ /$filter/ } deserialize();
    return \@filter;
};      

#$init->();
#say  $_->{apid} for(@{$search->($option->{s})});

my $check = sub {
    say colored(['green'], '$check: ') . "plists"; #----------------debug
    for( @{ $search->('.') } ){
        if( -f $_->{plist}){
            # ------------------------todo: create $repath->($_->{plist})
            say colored(['yellow'], $_->{apid} . ' >> ' . 'path broken') and $repath->($_->{plist});
        }
    }
};  

for(keys %$option){
    say colored(['green'], 'options: ') . "..."; #----------------debug
    # initialize (-i)
    if(defined $option->{i}){
        say "initializing..."; $init->() and $serialize->();
        # search (-s keyword) 
    } elsif(defined $option->{s}){
        for( @{$search->($option->{s})}){
            say $_->{apnr} . ' >> ' . $_->{apid};
        }
    } 
}

# --check $app->{plist} after each alios command
$check->();



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




