msir-eval
=========

This is the evaluation script for the FIRE Shared Task on Trannsliterated Search Subtask II - Mixed Script Adhoc Retrieval

This script evaluates the NDCG@k, MRR, MAP and recall for the supplied runs according to the relevance judgement (qrel). 
The script is developed for the purpose to evaluate the runs submitted to Shared Task on Transliterated Search at FIRE 2014. 

http://research.microsoft.com/en-us/events/fire13_st_on_transliteratedsearch/fire14st.aspx

usage: perl msir14-eval.pl <qrel-file> <run-file> <verbose-level>

sample usage: perl msir14-eval.pl sample_qrel.txt sample_run.txt 0

Author: Parth Gupta, email: pgupta@dsic.upv.es

Copyright (C) 2012, 2013, 2014 Parth Gupta All rights reserved.

