msir-eval
=========

This is the evaluation script for the FIRE Shared Task on Trannsliterated Search Subtask II - Mixed Script Adhoc Retrieval.

This script evaluates the NDCG@k, MRR, MAP and recall for the supplied runs according to the relevance judgements (qrels). 
The script is developed for the purpose to evaluate the runs submitted to Shared Task on Transliterated Search at FIRE 2014 but can be used outside it as well. 

http://research.microsoft.com/en-us/events/fire13_st_on_transliteratedsearch/fire14st.aspx

**usage**
--------

`perl msir14-eval.pl <qrel-file> <run-file> <verbose-level>`

**sample usage**
--------------

`perl msir14-eval.pl sample_qrel.txt sample_run.txt 0`


**sample output**
----------------
```
Query                           NDCG@1  NDCG@5  NDCG@10 MAP     MRR     RECALL

average                         1.0000  0.7871  0.8502  0.7083  1.0000  0.8750
```

**Verbose levels**
------------------

There are three verboser levels [0-2]. 

* 0 - It prints the evaluation measures averaged over all queries only.
* 1 - It prints the evaluation measures for each query and average.
* 2 - It prints the gold ranklist and the your ranklist for each query in addtion to the info printed in level-1.


**Format of files**
-------------------

* sample_run.txt (single-space delimited):

`<query-id> Q0 <docid> <rank> <similarity-score>`

* sample_qrel.txt (single-space delimited):

`<query-id> QO <docid> <relevance-score>`

where, relevance scores are between [0-4] ranging from irrelevant=0 to perfectly relevant=4. 

**How to get**
-------------

Either you can fork this github repository or you can simply download the repository as ZIP by clicking "Download ZIP" button.

**Author**
---------

Parth Gupta, email: pgupta@dsic.upv.es


Copyright (C) 2012, 2013, 2014, 2015 Parth Gupta.

