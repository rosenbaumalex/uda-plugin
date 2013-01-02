#!/bin/bash

echoPrefix=$(basename $0)
freeSpaceFlag=`df -h | grep -m 1 "\% \/" | grep 100\%`
if [[ $freeSpaceFlag != "" ]];then
	echo -e "$echoPrefix: there is no enouth place on the disk" | tee $ERROR_LOG
	exit $EEC1
fi

currentTestsDir=$CONF_FOLDER_DIR/${CONFS_DIR_NAME}_${CURRENT_DATE}

if [ -d $currentTestsDir ];then
	currentTestsDir=${currentTestsDir}_`date +"%s"`
	echo "$echoPrefix: $currentTestsDir already exist. tring create ${currentTestsDir}"
	if ! mkdir ${currentTestsDir};then
		echo "$echoPrefix: failling to create ${currentTestsDir}" | tee $ERROR_LOG
		$EEC1
	fi
else
	echo "$echoPrefix: creating test folder at $currentTestsDir"
	if ! mkdir -p $currentTestsDir;then
		echo "$echoPrefix: failling to create $currentTestsDir" | tee $ERROR_LOG
		$EEC1
	fi
fi

echo "$echoPrefix: building the tests-files at $currentTestsDir"

# 	after running parseTests.awk the execution folders will include:
# 	one each tests: script named "general.sh", that contains the needed exports
#	for every test: exports-file and (if needed) configuration files (XMLs)

awk -v testsFolderDir=$currentTestsDir -f $SCRIPTS_DIR/parseTests.awk $CSV_FILE 
#/labhome/oriz/backup/CMDpro-3.9.2012/parseTests.awk  $SCRIPTS_DIR/parseTests.awk
if (($?!=0));then
	echo "$echoPrefix: error during executing the parser script" | tee $ERROR_LOG
	exit $EEC1
fi

# using the general exports of the tests
source $currentTestsDir/general.sh

if [[ $ERRORS != "" ]];then
	if (($CONFIGURE_FLAG == 0));then
		echo "$echoPrefix: errors has found in the tests-files: $ERRORS" | tee $ERROR_LOG
	else
		echo "$echoPrefix: errors has found in the tests-files" | tee $ERROR_LOG
	fi
    exit $EEC1
fi

echo "
	#!/bin/sh
	source $currentTestsDir/general.sh
	export TESTS_PATH=$currentTestsDir
" > $TMP_DIR/configureExports.sh