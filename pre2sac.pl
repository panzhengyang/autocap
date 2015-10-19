#!/usr/bin/env perl
use strict;
use warnings;
use Time::Local;
use POSIX qw/strftime/;
use File::Basename qw/basename dirname/;
use List::Util qw/max min/;
use Date::Calc qw/Add_Delta_Days/;


$ENV{SAC_DISPLAY_COPYRIGHT}=0;
my $usage="perl $0 event lat lon sacpath  rtzpath";
@ARGV ==5 or die "$usage \n";
my $event=$ARGV[0];
my $lat =$ARGV[1];
my $lon =$ARGV[2];
my $sacpath=$ARGV[3];
my $rtzpath=$ARGV[4];

my $lp1 = 0.002;		   #freq $lp1/$lp2/$hp1/$hp2
my $lp2 = 0.005;           #0.02/0.05/15/20
my $hp1 = 3;
my $hp2 = 5;

# directory
our $path;
our $path1 = "$sacpath/$event";
our $path2 = "$rtzpath/$event";


our $year=substr($event,0,4);
our $month=substr($event,4,2);
our $mday=substr($event,6,2);
our $hour=substr($event,8,2);
our $min=substr($event,10,2);
our $sec=substr($event,12,2);
our $msec = 0.0 ; 
   $month-=1;
my $gmt_time=timelocal("$sec","$min", "$hour", "$mday", "$month","$year");

	$year = strftime "%Y",localtime($gmt_time);
my  $jday = strftime "%j",localtime($gmt_time);
    ($year,$month,$mday)=Add_Delta_Days($year,1,1,$jday-1) ;
	$hour = strftime "%H",localtime($gmt_time);
 	$min=strftime "%M",localtime($gmt_time);
 	$sec=strftime "%S",localtime($gmt_time);
 	$month=strftime "%m",localtime($gmt_time);
	printf STDERR "$year-$month-$mday($jday) $hour:$min:$sec $event \n";
# time convert over


our ($year2,$jday2,$hour2,$min2,$sec2,$msec2,$pro,$sta,$lid,$chn,$q,$sac);
#	mkdir "$dirpre",0755 or warn "Cannot make directory : $!";          #build work dirctory
	open(SAC,"|sac") or die "Error opening sac ";
foreach my $file ( glob( "$path1/*.SAC") ) {
    $path = dirname $file;
    my $sacfile = basename $file;
    ($year2,$jday2,$hour2,$min2,$sec2,$msec2,$pro,$sta,$lid,$chn,$q,$sac) = split /\./,$sacfile;   # basename
    my $resnm="RESP.$pro.$sta.$lid.$chn";
    #my $pznm="$sta.$pro.$chn.pz";
    $resnm="$path/$resnm";

    # check respose file exist
		unless (-f $resnm){
      		print STDERR "Resp file not exist: RESP.$pro.$sta.$lid.$chn \n";
	    #		print "response file path: $resdir/$pro/ \n";
	    		print "the problem station: $sacfile \n";
	    		print SAC "quit \n";
	    		die "die out \n";
		}
    	print SAC "readerr badfile fatal\n";
    	print SAC "r $path/$sacfile \n";
    	print SAC "rtr \n";
		print SAC "rmean \n";
		print SAC "taper \n";
    	print SAC "ch LOVROK TRUE\n";
    	print SAC "ch LCALDA TRUE \n";
    	print SAC "ch EVLO $lon EVLA $lat \n";
    	print SAC "ch o gmt $year $jday $hour $min $sec $msec \n" ;
    	print SAC "ch allt (0 - &1,o&) iztype IO \n";
		print SAC" transfer from evalresp fname $resnm TO VEL freq $lp1 $lp2 $hp1 $hp2 \n";
		#print SAC" transfer from polezero s $pznm TO VEL freq $lp1 $lp2 $hp1 $hp2 \n";
		#print SAC "transfer from evalresp fname $instr to vel $filter\n";

		print SAC "dec 5 \n";
		print SAC "write $path2/$sta.$pro.$lid.$chn \n";
		print SAC "r $path2/$sta.$pro.$lid.$chn \n";
		print SAC "div 1.0e7\n";
        print SAC "w over\n";
	}
print SAC "quit \n";
close(SAC);
printf STDERR "$event: transfer is sucess ! \n";
print strftime("%Y-%m-%d %H:%M:%S\n", localtime(time));
