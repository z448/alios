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
use JSON::PP qw< encode_json decode_json>;
use open qw< :encoding(UTF-8) >;
use autodie;

my $opt = {};
getopts('sd:pm:n:h', $opt);

#my $MYHOME = "/var/mobile";
my $MYHOME = "/home/z/alios/dev/var/mobile";
my $base = ["$MYHOME/Containers/Data/Application","$MYHOME/Containers/Shared/AppGroup"];
my $conf = "$MYHOME/.alios";


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

my $map = sub {
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

	show();
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
	
	show();
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

sub search {
	my $app = init;
	for(@$app){
		print " " x (length $_->{id}) . colored(['yellow'], "$_->{name}") . colored(['yellow'], "__") . colored(['black on_yellow'], " $_->{nr}") . "\n"; 
	}
};

sub show {
	my $apps = conf;
	print colored(['black on_yellow'], " alios"); for my $app(@$apps){ print " $app->{alios}" }; print " " . colored(['black on_yellow'], " ") . "\n";
};

sub help {
	print "\n" . colored(['bold white'], "alios") . " - tool for quick jumps into app folders. Creates alias 'app', shell variable '\$APP' holding app folder path and shell variable '\$app' holding app id.\n"
	. "\t" . colored(['bold white'], "-s") . " search for available apps\n"
	. "\t" . colored(['bold white'], "-m") . " map alios\n"
	. "\t" . colored(['bold white'], "-d") . " delete mapped alios\n"
	. colored(['bold white'], "E.g") . "\n"
	. "\t'" . colored(['bold white'], "alios -s") . "' search for available apps\n"
	. "\t'" . colored(['bold white'], "alios -m 44 -n name") . "' map 44th app to name\n"
	. "\t'" . colored(['bold white'], "alios") . "' list alios\n"
	. "\t'" . colored(['bold white'], "alios -d name") . "' delete alios\n\n";
};

if($opt->{m} and $opt->{n}){ $map->($opt->{m}, $opt->{n}) }
elsif($opt->{s}){ search }
elsif($opt->{p}){ conf(1) }
elsif($opt->{d}){ del($opt->{d}) }
elsif($opt->{h}){ help }
else { show };


=head1 NAME

alios - tool for quick jumps into app folders 

=head1 VERSION

This document describes alios version 2.6

=head1 SYNOPSIS

=over 10

=item C<-p> repath  

=item C<-s> search for available apps

=item C<-m> map alios

=item C<-d> delete alios

=item C<-h> show help

=back

=head1 DESCRIPTION

Creates shell variable '$APP' holding app home folder path, alias 'app' pointing to app home folder and shell variable '$app' holding app id.

=head1 EXAMPLES

C<alios -p> repath path to app home folders

C<alios -s> search for available apps

C<alios -m 44 -n name> map 44th app to name

C<alios> list alioses

C<alios -d name> delete alios

=cut
