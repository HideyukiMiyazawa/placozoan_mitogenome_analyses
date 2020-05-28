#!/usr/local/bin/perl
use v5.20.0;
use strict;
use warnings;

# read in the fasta file, %fasta : $fasta{"seq_name"} = <nucleotide sequence>
my $infile  = $ARGV[0];
my ($consensus_fa_file, $consensus_seq_name);
if ($infile =~ /^(\w+)\.fa/){
	$consensus_fa_file = $1.".consensus.fa" ;
	$consensus_seq_name = $1.".consensus" ;
}
my @lines;
open IN, "<".$infile || die "17!!";
	@lines = <IN>;
close IN;
my (%fasta, %lengths, @ids, %ids);
my $longest = 0;
map{$_ .= "¥¥¥¥¥" if ($_ =~ />/)}(@lines);
my $line = join("", @lines);
$line =~ s/\s//g;
@lines = split(/>/, $line);
shift(@lines);
for my $line (@lines){
	if ($line =~ /([-\w\:]+)¥¥¥¥¥(.+)/){
		my $name = $1;
		my $seq  = $2; $seq = uc $seq ;
		$fasta{$name}   = [split(//, $seq)];
		$lengths{$name} = length($seq);
		push(@ids, $name);
		$longest = length($seq) if ($longest < length($seq));
		$ids{$name}++;
	}
}

# the sites consisting of "-" at the ratio more than $threshold are removed as sequencing error.
my $threshold = 0.9;
my @consensus;
for my $n (0..$longest-1){
	my %chr;
	map{$chr{$fasta{$_}[$n]}++}(@ids);
	#delete $chr{"-"};
	my $chrs ; map{$chrs += $chr{$_} if ($chr{$_})}(qw(A T G C -));
	next if (!$chrs);
	my @chr ; map{push(@chr, $_)}(sort{$chr{$b}<=>$chr{$a}}keys(%chr));
	shift(@chr) if ($chr[0] eq "-" && $chr{"-"}<$threshold*$chrs);
	$chr[0] = uc($chr[0]);
	push(@consensus, $chr[0]);
}

# output the consensus sequence
open OUT, ">$consensus_fa_file" || die;
say OUT ">$consensus_seq_name";
map{print OUT if (/\w/)}(@consensus); # skip hyphen '-'
say OUT "";
close OUT;
