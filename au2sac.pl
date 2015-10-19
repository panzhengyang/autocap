#!/use/bin/env perl
use strict;
use warnings;
use Time::Local;
use POSIX qw/strftime/;
use File::Basename qw/basename dirname/;
use List::Util qw/max min/;
use Date::Calc qw/Add_Delta_Days/;



our $sacdir = "/home/junlysky/testsac";
mkdir "$sacdir",0755 if !-e $sacdir;
our $rtzdir = "/home/junlysky/testrtz";
mkdir  "$rtzdir",0755 if !-e $rtzdir;

our $path1 = $sacdir;
our $path2 = $rtzdir;

our ($i,$j);
our ($path,$seeddir,$seedfile);
our ($year,$mon,$mday,$hour,$min,$sec,$msec,$mmsec,$lat,$lon,$dep,$mag,$magtp);
our ($date,$time);
our $gmt_time;
our ($eventdir,$eventdir2,$eventnm);


open(IN, "< /home/junlysky/test/25_33_99_106_m3_m4.txt");
my @lines = <IN>;
chomp(@lines);
close(IN);

our %event_of;
foreach my $line (@lines){
    ($date,$time,$lat,$lon,$dep,$mag,$magtp)=split /\s+/,$line;
    ($year,$mon,$mday) = split /\//,$date;
    ($hour,$min,$msec) = split /\:/,$time;
    ($sec,$mmsec) = split /\./,$msec;
    $mon = $mon-1;
    $gmt_time=timelocal("$sec","$min","$hour","$mday","$mon","$year")-8*3600 ;
    $year = strftime "%Y",localtime($gmt_time);
    $mday = strftime "%d",localtime($gmt_time);
    $hour = strftime "%H",localtime($gmt_time);
    $min=strftime "%M",localtime($gmt_time);
    $sec=strftime "%S",localtime($gmt_time);
    $mon=strftime "%m",localtime($gmt_time);

    my $key = "${year}${mon}${mday}${hour}${min}${sec}";
    $event_of{$key} = $line;
    #    our @sortorder = sort keys %event_of ;  # sort the eqt
    #    foreach my $key (@sortorder) { }

    my $pwd = `pwd`;
    chomp($pwd);
    $path = $pwd;
    $seeddir = "$pwd/$year/$year$mon";  
    $eventnm = $key;
    $eventdir = "$sacdir/$eventnm";
    $eventdir2= "$rtzdir/$eventnm";
    print "$eventdir2\n";
 #   sprintf($msec, "%03d", int($msec*10+0.5));
    $msec = sprintf("%03d", int($msec*10+0.5) );
    $seedfile = "$year$mon$mday$hour$min$msec.IGP.SEED";
    print "$seedfile\n";
    mkdir "$eventdir",0755 if !-e $eventdir;
    mkdir "$eventdir2",0755 if !-e $eventdir2;
    system("cp $seeddir/$seedfile  $eventdir/");
    system("rdseed -Rdf $seeddir/$seedfile -q $eventdir ");
    system("perl $path/presac.pl $eventnm $lat $lon $path1 $path2");
    system("perl $path/rota.pl   $eventnm $path2");
 
}
