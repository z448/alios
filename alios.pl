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


my $serialize = sub {
# --json write
    say colored(['green'], '$serialize: ') . "starting json"; #---------------debug
    open($fh,">",$json) || die "cant open $json: $!";
    my $jay = encode_json \@app;
    print $fh $jay;
    close $fh;

# --dumper write
    say colored(['green'], '$serialize: ') . "starting dumper"; #----------------debug
    open(my $dmp, ">",$dumper) || die "cant open $dumper: $!";
    print $dmp Data::Dumper->Dump([ \@app ],['app']);
    close $dmp;
};  

# --init; todo: move to -i option only
#$init->(); $serialize->();

# --dumper read

{   
    open( my $dmp,"<",$dumper) || die "cant open $dumper:$!";
    say colored(['green'], '$deserializing: ') . "dumper"; #----------------debug
    undef $/;
    eval<$dmp>;
    die "cannot recreate data structures from \"$dumper\": $@" if $@;
    $/ = "\n";
    close $dmp; 
}

# --search appids
my $search = sub {
    my $filter = shift;
    $filter = qr/$filter/;
    my @filter = grep { $_->{"apid"} =~ /$filter/ } @app;
    return \@filter;
};      


my $check = sub {
    say colored(['green'], '$check: ') . "plists"; #----------------debug
    for( @{$search->()} ){
        if( -f $_->{plist}){ 
            say $_->{apid} . ' >> ' . 'ok';
        } else { 
            say colored(['yellow'], $_->{apid} . ' >> ' . 'notok');
        }
    }
};  

#$check->();



for(keys %$option){
    say colored(['green'], 'options: ') . "..."; #----------------debug
    if(defined $option->{i}){
        say "initializing..."; $init->()
    } elsif(defined $option->{s}){
        for( @{$search->($option->{s})}){
            say $_->{apnr} . ' >> ' . $_->{apid};
        }
    }
    elsif($option->{f}){
        say $search->($option->{f});
    } else {
        # --dumper status
        my $dumper_status = Dumper($app);
        say colored(['green'], 'dumper read status: ') unless ($dumper_status); #----------------debug
        say "default option";
    }
}

