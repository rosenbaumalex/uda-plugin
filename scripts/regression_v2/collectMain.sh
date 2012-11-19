#!/bin/bash

echoPrefix=$(basename $0)

reportSubject=$REPORT_SUBJECT
if (($TEST_RUN_FLAG == 1));then
	currentNfsResultsDir=$NFS_RESULTS_DIR/${TEST_RUN_DIR_PREFIX}$CURRENT_DATE
else
	currentNfsResultsDir=$NFS_RESULTS_DIR/${SMOKE_RUN_DIR_PREFIX}$CURRENT_DATE
fi

if ! mkdir $currentNfsResultsDir;then
	echo "$echoPrefix: failling to create $currentNfsResultsDir" | tee $ERROR_LOG
	exit $EEC1
fi
echo "$echoPrefix: the NFS collect dir is $currentNfsResultsDir"

	# copying the logs dirs
echo "$echoPrefix: collecting logs"
logsDestDir=$currentNfsResultsDir/$LOGS_DIR_NAME
mkdir -p $logsDestDir
scp -r $RES_SERVER:$CURRENT_LOCAL_RESULTS_DIR/* $logsDestDir > /dev/null
	# copying the tests dirs
echo "$echoPrefix: collecting test-files"
confsDestDir=$currentNfsResultsDir/$CONFS_DIR_NAME
mkdir $confsDestDir
cp -r $TESTS_PATH/* $confsDestDir > /dev/null
	# copying the csv configuration file
echo "$echoPrefix: collecting csv-configuration-file"
cp $CSV_FILE $currentNfsResultsDir > /dev/null
	# copying the coverity files
echo "$echoPrefix: collecting code coverage files"
coverityDestDir=$currentNfsResultsDir/$COVERITY_DIR_NAME
mkdir -p $coverityDestDir
#for slave in 
scp -r $RES_SERVER:$CODE_COVERAGE_DIR/* $coverityDestDir > /dev/null

errorExist=`grep -c "" $ERROR_LOG`
if (($errorExist != 0));then
	echo "$echoPrefix: collecting the errors-log"
	cp -r $ERROR_LOG $currentNfsResultsDir > /dev/null
fi


	# taking care the directories for the reports

terasortResultsDir=$currentNfsResultsDir/$LOGS_DIR_NAME/$TERASORT_LOGS_RELATIVE_DIR
if [ -d $terasortResultsDir ];then
	echo "$echoPrefix: terasort executions are in $terasortResultsDir"
else
	terasortResultsDir=""
fi
TestDFSIOResultsDir=$currentNfsResultsDir/$LOGS_DIR_NAME/$TEST_DFSIO_LOGS_RELATIVE_DIR
if [ -d $TestDFSIOResultsDir ];then
	echo "$echoPrefix: TestDFSIO executions are in $TestDFSIOResultsDir"
else
	TestDFSIOResultsDir=""
fi
piResultsDir=$currentNfsResultsDir/$LOGS_DIR_NAME/$PI_LOGS_RELATIVE_DIR
if [ -d $piResultsDir ];then
	echo "$echoPrefix: pi executions are in $piResultsDir"
else
	piResultsDir=""
fi

chmod -R 775 $currentNfsResultsDir
#$CURRENT_NFS_RESULTS_DIR/$LOGS_DIR_NAME
echo "
	#!/bin/sh
	export CURRENT_NFS_RESULTS_DIR='$currentNfsResultsDir'
	export REPORT_INPUT_DIR='$currentNfsResultsDir/$LOGS_DIR_NAME'
	export TERASORT_RESULTS_INPUT_DIR='$terasortResultsDir'
	export TEST_DFSIO_RESULTS_INPUT_DIR='$TestDFSIOResultsDir'
	export PI_RESULTS_INPUT_DIR='$piResultsDir'
" > $TMP_DIR/collectExports.sh
