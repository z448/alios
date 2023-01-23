#!/usr/bin/perl

use utf8;
use 5.010;

package App::alios;

use strict;
use warnings;

use vars qw( @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION );

$VERSION = 'v2.8.4';

@EXPORT_OK = qw( init del conf $map );
%EXPORT_TAGS = (
	'all' => [ @EXPORT_OK ],
);

use Exporter qw(import);

use File::Find;
use Term::ANSIColor;
use Getopt::Std;
use open qw< :encoding(UTF-8) >;
use autodie;

my $base = ["/var/mobile/Containers/Data/Application","/var/mobile/Containers/Shared/AppGroup"];
my $conf = "$ENV{'HOME'}/.alios";

unless( -e $conf ){
	open(my $fh, '>>', $conf);
	close $fh;
}

sub init {
	my %app = ();
	my @app = ();
	my $nr = 1;

	find( sub {
		if("$File::Find::dir/$_" =~ /Library\/Preferences\/.*\.plist/){
			$app{plist} = "$File::Find::dir/$_";
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
	}, @$base);
	\@app;
};

our $map = sub {
	my($apnr, $alios) = @_;
	my $app = init;
	my $VAR = uc $alios;
	for(@$app){
		next if ($apnr != $_->{nr});
		$_->{alios} = $alios;
    		open(my $fh, ">>", $conf);
		print $fh "$VAR=$_->{path};alias $_->{alios}=\"cd $_->{path}\";$_->{alios}=$_->{id}\n";
		close $fh;
	}
	print "\n'" . colored(['bold white'], "source ~/.alios") . "' to make changes available.\n";
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
	
	print "\nRestart shell session '" . colored(['bold white'], "exec \$SHELL") . "' to make changes available.\n";
};

sub conf {
	
	my $heal = sub {
		my $cfapps = shift;
		my $apps = init;
		
		for my $cfapp(@$cfapps){
			next if ($cfapp->{ill} != 1);
			for my $app(@$apps){
				our $^I = '.bak';
				our @ARGV = ($conf);
				if($app->{id} eq $cfapp->{id}){
						while(<ARGV>){
							chomp;
							s/$cfapp->{conf}/$cfapp->{var}=$app->{path};alias $cfapp->{alios}=\"cd $app->{path}\";$cfapp->{alios}=$app->{id}/;
							print "$_\n";
	                			}
				} else { unless(-e $app->{plist}){
							while(<ARGV>){
								chomp;
								s/$cfapp->{conf}//;
								print "$_\n";
							}
					}
				}
			}
		}
	};
	
	my $h = shift || 0;
	my @app = ();
	open(my $fh, "<", $conf);
	while(<$fh>){
		my %app = ();
		chomp;
		($app{plist}, $app{alias}, $app{id}) = split(/;/, $_);
			
		$app{conf} = $_;
		$app{alias} =~ s/^(.*)\=.*\"(.*)\"/$1/;
		$app{id} =~ s/.*\=(.*)/$1/;
		$app{plist} =~ s/(.*)\=(.*)/$2\/Library\/Preferences\/$app{id}\.plist/;
		$app{var} = $1;
		$app{path} = "$app{plist}/../../..";
		$app{alios} = lc $1;
		my @appname = split(/\./, $app{id});
		$app{name} = $appname[-1];
		$app{ill} = 0;
		$app{ill} = 1 unless -e $app{plist};
		push @app, \%app;
	}
	close $fh;
	$heal->(\@app) if $h;
	\@app;
};

=head1 SOURCE AVAILABILITY

	https://github.com/z448/alios

=head1 AUTHOR

Zdeněk Bohuněk, C<< <4zdenek@gmail.com> >>

Copyright © 2016-2023, Zdeněk Bohuněk C<< <4zdenek@gmail.com> >>. All rights reserved. 

This code is available under the Artistic License 2.0.

=cut

1;
