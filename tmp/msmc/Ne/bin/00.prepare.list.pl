my $vcftools="/home/wanglizhong/software/vcftools/vcftools-build/bin/vcftools";

my $out="$0.out";
`mkdir $out`;
my $dir=`pwd`;
chomp $dir;

my %pop_info;
open(I,"../../../sample_label.ids");#/ifshk5/PC_HUMAN_EU/USER/wanglizhong/project.hk/sample_label.ids");
while(<I>){
    chomp;
    my @a=split(/\s+/);
    $pop_info{$a[1]}{$a[0]}++;
}
close I;

my %ind_info;
open(I,"../../../DNSampleInfo.dat.txt");#/ifshk5/PC_HUMAN_EU/USER/wanglizhong/project.hk/DNSampleInfo.dat.txt");
<I>;
while(<I>){
    chomp;
    my @a=split(/\s+/);
    $ind_info{$a[0]}{depth}=$a[1];
}
close I;

open(I,"../../../final_bam.list");#/ifshk5/PC_HUMAN_EU/USER/wanglizhong/project.hk/final_bam.list");
while(<I>){
    chomp;
    /BAM\/([^\.]+)./;
    my $id=$1;
    $ind_info{$id}{bam}="$_";
}
close I;

my %vcf;
open(I,"../../../Phased.vcflist");#/ifshk5/PC_HUMAN_EU/USER/wanglizhong/project.hk/Phased.vcflist");
while(<I>){
    chomp;
    /VCF\/Chr(.+).phased.vcf.gz/;
    next if($1 =~ /X/);
    $vcf{$1}=$_;
}
close I;

open(LOG,"> $0.log");
open(OUT,"> $0.sh");
foreach my $k1(sort keys %pop_info){
    open(O1,"> $k1.bamlist");
    open(O2,"> $k1.samplelist");
    open(O3,"> $k1.vcflist");
    
    my $num=keys %{$pop_info{$k1}};
    if($num<4){
	# log
        print LOG " $k1";
        #print bamlist and samplelist
        my @sample_list;
        my @k2=sort{$ind_info{$b}{depth}<=> $ind_info{$a}{depth}} keys %{$pop_info{$k1}};
        for(my $i=0;$i<@k2;$i++){
            my $k2=$k2[$i];
            print O1 "$k2\t$ind_info{$k2}{bam}\tALLchr\t$ind_info{$k2}{depth}\n"; # bamlist
            print O2 "$k2\n"; #samplelist
        }
        close O1;
        close O2;
	
        # print vcf list
        for(my $j=1;$j<30;$j++){
            my $vcf=$vcf{$j};
            print OUT "$vcftools --gzvcf $vcf --keep $k1.samplelist --chr Chr$j --recode -c|gzip -c >  $dir/$out/$k1.Chr$j.vcf.gz;\n"; # generate vcf per pop using 4 samples
            print O3 "$dir/$out/$k1.Chr$j.vcf.gz Chr$j\n"; # vcflist
        }
        close O3;
	
    }else{
	# log
	print LOG " $k1";
	#print bamlist and samplelist
	my @sample_list;
	my @k2=sort{$ind_info{$b}{depth}<=> $ind_info{$a}{depth}} keys %{$pop_info{$k1}};
	for(my $i=0;$i<4;$i++){
	    my $k2=$k2[$i];
	    print O1 "$k2\t$ind_info{$k2}{bam}\tALLchr\t$ind_info{$k2}{depth}\n"; # bamlist
	    print O2 "$k2\n"; #samplelist
	}
	close O1;
	close O2;
	
	# print vcf list
	for(my $j=1;$j<30;$j++){
	    my $vcf=$vcf{$j};
	    print OUT "$vcftools --gzvcf $vcf --keep $k1.samplelist --chr Chr$j --recode -c|gzip -c >  $dir/$out/$k1.Chr$j.vcf.gz;\n"; # generate vcf per pop using 4 samples
	    print O3 "$dir/$out/$k1.Chr$j.vcf.gz Chr$j\n"; # vcflist
	}
	close O3;
    }
}
print LOG "\n";
close OUT;
close LOG;

