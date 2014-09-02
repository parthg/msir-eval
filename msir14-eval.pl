#!/usr/bin/perl -w
# Copyright (C) 2012, 2013, 2014 Parth Gupta All rights reserved.


# This script evaluates the NDCG@k, MRR, MAP and recall for the supplied runs according to the relevance judgement (qrel). 
# The script is developed for the purpose to evaluate the runs submitted to Shared Task on Transliterated Search at FIRE 2014. 
#
# http://research.microsoft.com/en-us/events/fire13_st_on_transliteratedsearch/fire14st.aspx
#
# Author: Parth Gupta, email: pgupta@dsic.upv.es

if ( @ARGV != 3 ) {
	die "\nInsufficient/Improper Arguments.\n\nUsage:\nperl msir14-eval.pl <qrelFile> <runFile> <verbose> \n\n\nOptions\n<verbose>\t0\tPrints only average (over all the queries)\n\t\t1\tPrints querywise scores\n\t\t2\tPrints querywise ranklist and corresponding gold ranklist\n\n";
}


# The list of "n" to be considered in evaluation
my @N = (1,5,10);

# Path to the Qrel File
$QRELS = $ARGV[0];

# Path to the Run File
$RUN = $ARGV[1];

# 0 if only average to be printed
# 1 if results for all the queries required
$verbose = $ARGV[2];

# Threshold to be used when converting the graded relevance into binary in subroutine getMapMrrRec() [(rel>=relTheta)?1:0].
my $relTheta = 3;

# If some Queries are not needed in the evaluation
# then include in the list in the following manner.
# = ("xyz", 1, 
#    "abc", 1);
# and so on.. 
my %extopic = ("english-document-00046.txt",1);

my @avg;
my $avgMAP=0.0, $avgMRR=0.0, $avgREC=0.0;

my $j = 0;
foreach(@N) {
	$avg[$j]=0;
	$j++;
}

my %topiclist = ();
my %runlist = ();



# Read qrels file and store in hash
open (QRELS) || die "$0: cannot open \"$QRELS\": !$\n";
while (<QRELS>) {
	chomp($_);
	my @cols = split(/ /);
 	$topic = $cols[0];
 	$docno = $cols[2];
 	$rel = $cols[3];
 	# stores only non-zero relevance
	if($rel>0) {
  		$topics->{$topic}->{$docno} = $rel;
	}
 }

# Read the run file and store it in the hash
open (RUN) || die "$0: cannot open \"$RUN\": !$\n";
while (<RUN>) {
	chomp($_);
	my @cols = split(/ /);
 	$topic = $cols[0];
 	$docno = $cols[2];
 	$rank = $cols[3];

  	$rel = 0;
  	if(exists $topics->{$topic}->{$docno}) {
		$rel = $topics->{$topic}->{$docno};
	}
  	$runlist->{$topic}->{$rank} = $rel;
 }

 
 my @ranklist;
 my %scores;
 
 print "Query\t\t\t\t";
 foreach(@N) {
 	print "\tNDCG\@$_";
 }
 print "\tMAP\tMRR\tRECALL";
 print "\n";
 my $total = 0;

	for my $k1 ( sort keys %$topics) {
		       print "Topic: $k1\n" if $verbose>=2;
		if(!exists $extopic{$k1}) {
			$total++; 
			if(exists $runlist->{$k1}) {
				@ranklist=();
				for my $k2 ( sort{$a <=> $b}  keys  %{$runlist->{ $k1 }} ) {
					$ranklist[int($k2)] = $runlist->{$k1}->{$k2};  # Note that the ranklist is initialized from the index 1 and not 0.
#            				print "$k1\t$k2\t$runlist->{ $k1 }->{ $k2 }\n";
				}
				$ranklist[0]=0;
   			
				@tlist = values %{$topics->{$k1}};
				@ilist = sort { $b <=> $a } @tlist;
#   				print "@ranklist\n";
  				my @printRanklist = @ranklist[1 .. $#ranklist];
				print "Your Ranklist: @printRanklist\n" if $verbose>=2;
   				print "Gold Ranklist: @ilist\n" if $verbose>=2;
				@result = getdcg();

				my ($map,$mrr,$rec) = getMapMrrRec();
				$avgMAP+=$map;
				$avgMRR+=$mrr;
				$avgREC+=$rec;
  
				if(scalar(@result)>1) {
					print "$k1\t" if $verbose>=1;
					my $j=0;
					foreach(@result) {
						print "\t" if $verbose>=1;
						printf '%.4f',$_ if $verbose>=1;
						$avg[$j]+=$_;
						$j++;
					}
					print "\t" if $verbose>=1;
                                        printf '%.4f',$map if $verbose>=1;
					
					print "\t" if $verbose>=1;
                                        printf '%.4f',$mrr if $verbose>=1;

					print "\t" if $verbose>=1;
                                        printf '%.4f',$rec if $verbose>=1;

					print "\n" if $verbose>=1;
				}
			}	
     		
			
		}	
	}
	print "average\t\t\t";
	foreach(@avg) {
		print "\t";
		printf '%.4f',($_/$total);
	}
	print "\t";
        printf '%.4f',($avgMAP/$total);

	print "\t";
        printf '%.4f',($avgMRR/$total);

	print "\t";
        printf '%.4f',($avgREC/$total);
	print "\n";

# Subroutine to compute DCG for the specified ranklist for each N points
sub getdcg {
	my $count = 0;
	my @result;
	foreach(@N) {
		$dcg=0;
   		$idcg=0;
   		# gains for the ranklist
   		if(defined($ranklist[1])) {
   			$dcg += int($ranklist[1]);
   
   			for($i=2; $i<=$_; $i++) {
   				if(defined($ranklist[$i])) {
					$dcg += (($ranklist[$i]==0) ? 0 : ($ranklist[$i]/(log($i)/log(2))));
				}
   			}
   
   		# ideal gains
#   		@ilist = sort { $b <=> $a } @ranklist;
		if(defined($ilist[0])) {
			$idcg += int($ilist[0]);
		}
   		for($i=1; $i< $_; $i++) {
   			if(defined($ilist[$i])) {
				$idcg += (($ilist[$i]==0)  ? 0 : ($ilist[$i]/(log($i+1)/log(2))));
			}
   		}
   		$result[$count] = ($idcg==0) ? 0 : ($dcg/$idcg);
   		$count++;
		}
	}
	return @result;
}

# Subroutine to compute MAP for the specified ranklist
sub getMapMrrRec {
	my $totrecall = 0;
	my $ap = 0.0;
	my $mrr = 0.0;
	my $recall = 0.0;
	
	# count total number of relevant documents
	for(@ilist) {
		if(rel($_,$relTheta)) {
			$totrecall++;
		}
	}

	if($totrecall==0) { return ($ap,$mrr,$recall); }

        my $i = 0;
	my $relAtK = 0;

	# ranklist starts with index 1
        for(@ranklist[1 .. $#ranklist]) {
                if(rel($_,$relTheta)) { $relAtK++; }
		$i++;
#		print "POS $i Rel $relAtK\t";
		if($relAtK==1 && $mrr==0) {
			$mrr = (1.0/$i); # Mean Reciprocal Rank
		}
		$ap += ((($relAtK/$i)*rel($_,$relTheta))/$totrecall);
        }
	$recall = $relAtK/$totrecall; # recall of the ranklist
	return ($ap, $mrr, $recall);
}

# subroutine to binarise relevance
sub rel {
	if($_[0]>=$_[1]) { return 1.0; }
	else {return 0.0; }

}
