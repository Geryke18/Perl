#!/usr/bin/env perl
use strict;
use warnings;
use v5.010;

my $testScript = $ARGV[0];
my $stringFormat;
my $errors = " Results:\n";

my $stepNum = 0;
my $lineNum = 1;

my $line;
my $lastLine = 'DUMMY';
my $lastBeforeLine = 'DUMMY2';

open ($stringFormat, $testScript);
while (<$stringFormat>) {
	$line = $_;
  
# RULE 1
	if ($line =~ /^step.*;/ && $stepNum != 0 && $lastBeforeLine !~ /#./){
		if (!($lastLine =~ /^\s*$/ && $lastBeforeLine =~ /^\s*$/)) {
	    	$errors .= "\tline " . ($lineNum - 1) . ": RULE 1\n\t\tThere should be 2 blank lines at the end of the steps!\n\n";
		}
  	}
  	
# RULE 2
	if ($line =~ /^#+/ && $lastLine =~ /^\s*$/){
		if ($lastBeforeLine !~ /^\s*$/ && $lastBeforeLine !~ /^testEnd/) {
	    	$errors .= "\tline " . ($lineNum - 1) . ": RULE 2\n\t\tThere should be 2 blank lines at the end of the steps!\n\n";
		}
  	}
  	
# RULE 3
	if ($line =~ /^testEnd;/ ){
		if (!($lastLine =~ /^\s*$/ && $lastBeforeLine =~ /^\s*$/)) {
	    	$errors .= "\tline " . ($lineNum - 1) . ": RULE 3\n\t\tThere should be 2 blank lines at the end of the steps!\n\n";
		}
  	}
  	
# RULE 4
	if ($line =~ /^step.*;/ && $stepNum == 0){
		if (!($lastLine =~ /^\s*$/)) {
	    	$errors .= "\tline " . ($lineNum - 1) . ": RULE 4\n\t\tThere should be 1 blank lines before the steps!\n\n";
		}
  	}
  	
# RULE 5
	if ($line =~ /^\s*$/ && $lastLine =~ /^\s*$/ && $lastBeforeLine =~ /^\s*$/) {
	   $errors .= "\tline " . ($lineNum - 1) . ": RULE 5\n\t\tToo many blank lines!\n\n";
  	}
  
# RULE 6
	if ($line =~ /^step.*;/){
  		$stepNum++;
  		if (!($line =~ /^step \Q$stepNum\E;/)){
			$errors .= "\tline " . $lineNum . ": RULE 6\n\t\tWrong StepNumber!\n\n";
  		}
	}
	
# RULE 7
checkSpaceBeforeBracket();
	
  $lineNum++;
  $lastBeforeLine = $lastLine;
  $lastLine = $line;
}
close ($testScript);
if ($errors eq " Results:\n"){
	$errors .= "\n\tLinter can not find error. This is suspicious...\n";
}
say ($errors);

sub checkSpaceBeforeBracket {
	if ($line =~ /(\w+\()/) {
		my $group = $1;
		if ($group =~ /child\(/ ) {
			$line =~ s/child\(/child \(/;
		}else {
			$errors .= "\tline " . $lineNum . ": RULE 7\n\t\tMaybe here needs a space before the bracket:\t" . $group . "\n\n";
			$line =~ s/(\w+\()/(\w+\()/;
		}
		checkSpaceBeforeBracket();
	}
	if ($line =~ /(\w+\{)/) {
		$errors .= "\tline " . $lineNum . ": RULE 7\n\t\tMaybe here needs a space before the curly bracket:\t" . $1 . "\n\n";
	}
}