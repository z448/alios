#!/usr/bin/perl

use utf8;
use 5.010;

package App::alios;

use strict;
use warnings;
use autodie;

use vars qw( @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION );

$VERSION = 'v2.9';

@EXPORT_OK = qw( init del conf $map );
%EXPORT_TAGS = (
	'all' => [ @EXPORT_OK ],
);

use Exporter qw(import);

use Term::ANSIColor;
use Getopt::Std;
use open qw< :encoding(UTF-8) >;
use autodie;

my $conf = "$ENV{'HOME'}/.alios";
my $base = ["/var/mobile/Containers/Data/Application", "/var/mobile/Containers/Shared/AppGroup"];


sub init {
	my %app = ();
	my @app = ();
	my $nr = 1;
	my @plist = glob("$base->[0]/*/Library/Preferences/*.plist $base->[1]/*/Library/Preferences/*.plist");

	for(@plist){
		next if (/measurement/);
		$app{plist} = $_;
		$app{plist} =~ /(.*)(\/App.*?\/)(.*?)(\/Library\/Preferences\/)(.*)(\.plist)/;
		$app{path} = $1.$2.$3;
		$app{uuid} = $3;
		$app{nr} = $nr;
		$app{id} = $5;
		my @appid = split(/\./, $app{id});
		$app{name} = $appid[-1];
		$nr++;
		push @app,{%app};
	}
	\@app;
}

our $map = sub {
	my($apnr, $alios) = @_;
    exit unless int $apnr;

	my $app = init;
	for(@$app){
		next if ($apnr != $_->{nr});
        $_->{alios} = $_->{name};
		$_->{alios} = $alios if $alios;
        my $VAR = uc $_->{alios};
    	open(my $fh, '>>', $conf);
		print $fh "$VAR=$_->{path};alias $_->{alios}=\"cd $_->{path}\";$_->{alios}=$_->{id}\n";
		close $fh;
	}
};

sub del {
	my $alios = shift;
	my $VAR = uc $alios;
	my @app = ();
	
	{
		open(my $fh, '<', $conf);
		while(<$fh>){ push @app, $_ unless /^$VAR\=/ }
		close $fh;
	}

	{
		open(my $fh, '>', $conf);
		for my $app(@app){ print $fh $app; }
		close $fh;
	}
};

sub conf {
	
	my $heal = sub {
		my $cfapps = shift;
		my $apps = init;
		unlink $conf;

		for my $cfapp(@$cfapps){
			if($cfapp->{ill} == 1){
				for my $app(@$apps){
					if($app->{id} eq $cfapp->{id}){
						open(my $fh, '>>', $conf);
                        print $fh "$cfapp->{var}=$app->{path};alias $cfapp->{alios}=\"cd $app->{path}\";$cfapp->{alios}=$app->{id}\n";
						close $fh;
					}
				}
			}
			if($cfapp->{ill} == 0){
				for my $app(@$apps){
					if($app->{id} eq $cfapp->{id}){
						open(my $fh, '>>', $conf);
						print $fh "$cfapp->{conf}\n";
						close $fh;
					}
				}
			}

		}
	};
	
	my $h = shift || 0;
	my @app = ();

	if( -e $conf and -s $conf != 0){
		open(my $fh, '<', $conf);
		while(<$fh>){
			my %app = ();
			chomp;
			($app{plist}, $app{alias}, $app{id}) = split(/;/, $_);
			
			$app{conf} = $_;
			$app{alias} =~ s/^alias (.*?)=.*/$1/;
			$app{id} =~ s/.*\=(.*)/$1/;
			$app{plist} =~ s/(.*)\=(.*)/$2\/Library\/Preferences\/$app{id}\.plist/;
			$app{var} = $1;
			$app{path} = "$app{plist}/../../..";
            $app{alios} = $app{alias};
			my @appname = split(/\./, $app{id});
			$app{name} = $appname[-1];
			$app{ill} = 0;
			$app{ill} = 1 unless -e $app{plist};
			push @app, \%app;
		}
		close $fh;
		$heal->(\@app) if $h;
	} else {
        open(my $fh, '>', $conf);
        close $fh;
    }

	\@app;
};

=encoding utf8

=head1 NAME

App::alios - module for alios

=head1 SYNOPSIS

	use App::alios qw(:all);

=head1 SOURCE AVAILABILITY

	https://github.com/z448/alios

=head1 AUTHOR

Zdeněk Bohuněk, C<< <zdenek@cpan.org> >>

=head1 COPYRIGHT

Copyright © 2016-2023, Zdeněk Bohuněk C<< <zdenek@cpan.org> >>. All rights reserved. 

This code is available under the Artistic License 2.0.

=cut

1;
