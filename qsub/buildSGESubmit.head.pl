#!/usr/bin/perl -w
use strict;
use warnings;

my($fileIn,$mem,$proj_num)=@ARGV;
die("usage: <shell_script> [mem] [project_num] \n\nProject_num: \nCATwiwR(cattle) \nRATxdeR(BlindMoleRat) \nSHEtbyR(sheep) \n")unless($fileIn);

$proj_num||="CATwiwR";
$mem||="1";

my $outname=$fileIn;
$outname =~ s/(\.s\.\d+)$//;
my $dirout="z.$outname.z";
`mkdir $dirout`unless(-e $dirout);

open(Fo,"> $dirout/z.$fileIn.pbs");
print Fo "
#\$ -S /bin/sh
#\$ -e $dirout/z.$fileIn.pbs.\$JOB_ID.e
#\$ -o $dirout/z.$fileIn.pbs.\$JOB_ID.o
#\$ -l vf=${mem}G
#\$ -m n
#\$ -cwd
#\$ -P $proj_num
#\$ -q bc.q
";
my $pwd=`pwd`;
chomp $pwd;
print Fo "cd $pwd\n";
print Fo "date1=`date \"+%Y-%m-%d %H:%M:%S\"`; date1_sys=`date -d \"\$date1\" +%s`;echo \"start running ========= at \$date1\"\n\n";

open(F,'<',$fileIn) or die("$!: $fileIn\n");
while(<F>){
    print Fo "$_";
}
close(F);
print Fo "date2=`date \"+%Y-%m-%d %H:%M:%S\"`; date2_sys=`date -d \"\$date2\" +%s`; interval=`expr \$date2_sys - \$date1_sys`; hour=`expr \$interval / 3600`;left_second=`expr \$interval % 3600`; min=`expr \$left_second / 60`; second=`expr \$interval % 60`; echo \"done  running ========= at \$date2 in \$hour hour \$min min \$second s\"\n";
close(Fo);

