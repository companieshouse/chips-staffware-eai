#!/bin/bash

timestamp() {
  while read LINE
  do
    echo "$(date) ${LINE}"
  done
}

export CLASSPATH=/eai:/eai/libs/aqapi12.jar:/eai/libs/aqbridge.jar:/eai/libs/ojdbc8.jar:/eai/libs/log4j.jar:/eai/libs/wlthint3client.jar

# Set the vars in the jndi.properties and jms.properties files
envsubst < jndi.properties.template > jndi.properties
envsubst < jms.properties.template > jms.properties

LOGS_DIR=/eai/logs/eaidaemon
mkdir -p ${LOGS_DIR}
LOG_FILE="${LOGS_DIR}/${HOSTNAME}-eaidaemon-$(date +'%Y-%m-%d_%H-%M-%S').log"

while :
do
  /usr/java/jdk-8/bin/java -d64 -classpath $CLASSPATH uk.gov.ch.chips.server.aqbridge.StaffwareEAIBridge

  echo "========================="
  echo "EAI Daemon Exited >>>  on ${HOST_SERVER} "
  echo "========================="

  sleep 60
done 2>&1 | timestamp >> ${LOG_FILE}

