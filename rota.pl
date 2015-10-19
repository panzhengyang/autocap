#!/usr/bin/env perl
use strict;
use warnings;
use File::Copy;
use File::Basename qw/basename dirname/; 
use List::Util qw/max min/;
use Time::Local;
use POSIX qw(strftime); 
$ENV{SAC_DISPLAY_COPYRIGHT}=0;

my $usage="perl $0 event path";
@ARGV ==2 or die "Usage: $usage \n";
my $event=$ARGV[0];
my $path=$ARGV[1];
my $dt = 0.05;
my $co1 = 0.01;
my $co2 = 2;
#cut the data

open( SAC, "| sac ") or die "Error opening sac ";
foreach my $file ( glob( "$path/$event/*.BHZ") ) {
    my $sacfile=basename $file;
  #  print "$sacfile\n";
    my $path1=dirname $file;
   # print "1  $path1\n";
    my ($sta,$pro,$lid,$chn)= split /\./,$sacfile;
    my $ssta=substr($sacfile,0,(length($sacfile)-4));     
    my $sacBHZ="$path1/$ssta.BHZ";
    my $sacBHN="$path1/$ssta.BHN";
    my $sacBHE="$path1/$ssta.BHE";
		# check exist 3 chns
    unless (-f $sacBHN){
        print STDERR "Not exist: $sta.$pro.$lid.BHN \n";
        my $pwd = `pwd`;
        chomp($pwd);
        print "Path: $pwd/$event/ \n";
        print "Check the $sacBHZ or delete them! \n";
        print SAC "quit \n";
        die "die out \n";
    }
    unless (-f $sacBHE){
        print STDERR "Not exist: $sta.$pro.$lid.BHE \n";
        my $pwd = `pwd`;
        chomp($pwd);
        print "Path: $pwd/$event/ \n";
        print "Check the $sacBHZ or delete them! \n";
        print SAC "quit \n";
        die "die out! \n";
    }
    my($nm1,$b1,$e1,$dt1)=split /\s+/,`saclst b e delta f $sacBHZ`;
    my($nm2,$b2,$e2,$dt2)=split /\s+/,`saclst b e delta f $sacBHN`;
    my($nm3,$b3,$e3,$dt3)=split /\s+/,`saclst b e delta f $sacBHE`;
	#	print "$file \n";
    my $b=max($b1,$b2,$b3);
    my $e=min($e1,$e2,$e3);
    my $dt=$dt1;
    my $bg=$b+$dt;
    my $ed=int(($e-$b)/$dt)-2;
    #print SAC "echo \n";
    print SAC "cut off \n";
    print SAC "cut $bg n $ed \n";	
    print SAC "read $sacBHZ $sacBHN $sacBHE \n";
    #print "$ssta.BHZ  cut $bg n $ed \n";
    #print "$ssta.BHN  cut $bg n $ed \n";
    #print "$ssta.BHE  cut $bg n $ed \n";
    print SAC "w over \n";
    print SAC "r $sacBHN \n";
    print SAC "ch cmpaz 0 cmpinc 90 \n";
    print SAC "w over \n";
    print SAC "r $sacBHE \n";
    print SAC "ch cmpaz 90 cmpinc 90 \n";
    print SAC "w over \n";
    print SAC "r $sacBHZ \n";
    print SAC "ch cmpaz 0 cmpinc 0 \n";
    print SAC "w over \n";
    print SAC "read $sacBHN $sacBHE \n";
    print SAC "rot to gcp \n";
    print SAC "w  $path1/$sta.$pro.r  $path1/$sta.$pro.t \n";
    copy "$path1/$sta.$pro.$lid.BHZ" => "$path1/$sta.$pro.z";
}
print SAC "quit \n";
close(SAC);
system("rm -f $path/$event/*.BH? ");

print "$event:cut and rota sucess ! \n";
print strftime("%Y-%m-%d %H:%M:%S\n", localtime(time));
