#!/usr/local/bin/perl
use v5.18.2;
use strict;
use warnings;

my $seq_fas_file = $ARGV[0];

my $window_size = 100 ;
my $step_size = 10 ;
my %fa = FAS2HASH($seq_fas_file);
for my $fa (keys(%fa)){
	print $fa.",";
	my $seq = $fa{$fa}.$fa{$fa}.$fa{$fa};
	my $len = length($fa{$fa});
	for my $k ($len..$len*2){
		next if ($k%$step_size != 0);
		print $k-$len."\t";
		my $region = substr($seq, ($k-$window_size/2), $window_size);
		my $A =()= $region =~ /a/gi;
		my $T =()= $region =~ /t/gi;
		my $G =()= $region =~ /g/gi;
		my $C =()= $region =~ /c/gi;
		my $gc = ($G+$C)/$window_size;
		print $gc."\n";
	}
	print "\n";
}

sub FAS2HASH{	# stored as hash %seq ($seq{'haplotype'}{'all'} = <sequence>)
	my $inputfile = $_[0];
	my %seq;
	die $inputfile unless(-e $inputfile);
	open IN, $inputfile || die "I cant open the file, ".$inputfile." !!\n";
		my @lines = <IN>;
	close IN;
	map{die "Dont use the mark ¥ ! \n" if ($_ =~ /¥¥¥¥¥/)}(@lines);
	for(@lines){
		if ($_ =~ />/){
			$_ = ${[split(/\s+/, $_)]}[0];
			$_ .= "¥¥¥¥¥";
		}
	}
	my $line = join("", @lines);
	$line =~ s/\s//g;
	@lines = split(/>/, $line);
	shift(@lines);
	for my $line (@lines){
		my ($name,$seq)=($1,$2) if ($line =~ /^(.+)¥¥¥¥¥(.+)/);
		$name = $1 if($name =~ /^(.+)#/);
		$seq{$name}=$seq;
	}
	return %seq;
}
