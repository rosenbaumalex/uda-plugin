#!/bin/sh

	# terasort
export EXEC_DIR_PREFIX="exec_"
export TEST_DIR_PREFIX="test_"
export CONFS_DIR_NAME="confs"
export LOGS_DIR_NAME="logs"
export COVERITY_DIR_NAME="code_coverage"
export TERASORT_JOBS_DIR_NAME="terasort"
export SORT_JOBS_DIR_NAME="sort"
export TEST_DFSIO_JOBS_DIR_NAME="TestDFSIO"
export PI_JOBS_DIR_NAME="pi"
export WORDCOUNT_JOBS_DIR_NAME="wordcount"
export WORDCOUNT_TEST_HDFS_DIR_POSTFIX="_VANILLA"
export ATTEMPT_DIR_INFIX="_attempt_"
export TERASORT_DATA_TABLE_FILE_NAME="terasort2Results" # those digits are for viewTerasort.sh, so the sort will succeed
export TERASORT_STAT_TABLE_FILE_NAME="terasort1Summary"
export SORT_OUTCOME_TABLE_FILE_NAME="sortOutcome"
export SORT_SUMMARY_TABLE_FILE_NAME="sortSummary"
export PI_OUTCOME_TABLE_FILE_NAME="piOutcome"
export PI_SUMMARY_TABLE_FILE_NAME="piSummary"
export TEST_DFSIO_OUTCOME_TABLE_FILE_NAME="TestDFSIOOutcome"
export TEST_DFSIO_SUMMARY_TABLE_FILE_NAME="TestDFSIOSummary"
export WORDCOUNT_OUTCOME_TABLE_FILE_NAME="wordcountOutcome"
export WORDCOUNT_SUMMARY_TABLE_FILE_NAME="wordcountSummary"
export TOTAL_OUTCOME_TABLE_FILE_NAME="totalSummary"
export HADOOP_CONF_RELATIVE_PATH="conf"
export USERLOGS_RELATIVE_PATH="logs/userlogs"
export LOGS_HISTORY_RELATIVE_PATH="logs/history"
export TEST_RUN_DIR_PREFIX="testRun_"
export SMOKE_RUN_DIR_PREFIX="smoke_"
export RECENT_JOB_DIR_NAME="recentJob"
export GIT_CO_HADOOP_DIR_NAME="gitHadoopCO"
export GIT_CO_MASTER_DIR_NAME="gitMasterCO"
	
	# TestDFSIO
export TEST_DFSIO_WRITE_DIR_POSTFIX="_write"
export TEST_DFSIO_READ_DIR_POSTFIX="_read"

	# pi
export PI_DIR_POSTFIX="_pi"