#!/usr/bin/env perl
use diagnostics;
use warnings;
use strict;
use File::Copy;
#require "./fk.pl";
# This program is to generate green fuctions using FK
# make sure having weight.dat file which has the distance information

my $usage = "Usage: perl $0 model depth dp_max dp_delt \n";
@ARGV >=4 or die "$usage";
my $model =$ARGV[0];		#  the model name
my $dep=$ARGV[1];
my $dp_max=$ARGV[2];
my $dp_delt=$ARGV[3];

my $nt =4096;					#  the number of points, must be 2^n 
my $dt =0.05;					#  the sampling interval
my @dist;					#   distances

###  calculate the green fuctions
open(IN, "weight.dat") or die "need the weight.dat file !";
my @lines = <IN>;
chomp(@lines);
close(IN);

my $i=0;
while($i<@lines){
	my ($sta,$dist,$w1,$w2,$w3,$w4,$w5,$tp,$ts) = split /\s+/,$lines[$i++];
	$dist=int($dist);
	push @dist,$dist;
}

while( $dep<$dp_max){
	system("perl /home/junlysky/app/fk3.2/bin/fk.pl -M$model/$dep -N$nt/$dt -S2 @dist");
	system("perl /home/junlysky/app/fk3.2/bin/fk.pl -M$model/$dep -N$nt/$dt -S0 @dist");
	$dep += $dp_delt;
}

# Usage: fk.pl -Mmodel/depth[/k_or_f] [-D] [-Hf1/f2] [-Nnt/dt/smth/dk/taper] [-Ppmin/pmax[/kmax]] [-Rrdep] [-SsrcType] [-Uupdn] [-Xcmd] distances ...
# -M: model name and source depth in km. 
#	 k: k indicates that the 3rd column is vp/vs ratio (vp).
#	 f: f triggers earth flattening (off), 
#     	model:  model  has the following format (in units of km, km/s, g/cm3):
#                   #################################################
# 		      #	    thickness	vs   vp_or_vp/vs     [rho    Qs     Qp]           #
#                   #################################################	
#	thickness: If the first layer thickness is zero, it represents the top elastic half-space.
#                          Otherwise, the top half-space is assumed to be vacuum and does not need to be specified.
#                          The last layer (i.e. the bottom half space) thickness should be always be zero.		
#	rho:	 rho=0.77 + 0.32*vp if not provided or the 4th column is larger than 20 (treated as Qs).
# 	Qs:	 Qs=500, Qp=2*Qs, if they are not specified.	
# -D: use degrees instead of km (off).
# -H: apply a high-pass filter with a cosine transition zone between freq. f1 and f2 in Hz (0/0).
# -N: nt is te number of points, must be 2^n (256).
#           Note that nt=1 will compute static displacements (require st_fk compiled).
#                             nt=2 will compute static displacements using the dynamic solution.
#     dt is the sampling interval (1 sec).
#     smth makes the final sampling interval to be dt/smth, must be 2^n (1).
#     dk is the non-dimensional sampling interval of wavenumber (0.3).
#     taper applies a low-pass cosine filter at fc=(1-taper)*f_Niquest (0.3).
# -P: specify the min. and max. slownesses in term of 1/vs_at_the_source (0/1)
#     and optionally kmax at zero frequency in term of 1/hs (15).
# -R: receiver depth (0).
# -S: 0=explosion; 1=single force; 2=double couple (2).
# -U: 1=down-going wave only; -1=up-going wave only (0).
# -X: dump the input to cmd for debug (fk).

# Author: Lupei Zhu, 02/15/2005, SLU
