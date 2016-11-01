#!/bin/bash

:<<EOF

step 1: Init robot env.
step 2: Find robot dir.
setp 3: Check robot lock.
setp 4: Get robot task.
setp 5: robot config
        1)ubuntu
          a.contab -e
          b.sudo service cron reload
          c.sudo service cron restart
EOF

# step 1: init env
# init env
if [ -f "/etc/profile" ];then
    source /etc/profile
fi
if [ -f "~/.bashrc" ];then
    source ~/.bashrc
fi
export JAVA_HOME=/usr/lib/jvm/java-8-oracle/
export PATH=$PATH:$JAVA_HOME/bin
export JAVA_OPTS='-Xms512m -Xmx4096m -XX:MaxPermSize=128m -XX:-UseGCOverheadLimit -XX:+UseConcMarkSweepGC'
export GRADLE_OPTS='-Xmx1024m -Xms256m -XX:MaxPermSize=512m -XX:+CMSClassUnloadingEnabled -XX:+HeapDumpOnOutOfMemoryError'

# step 2: find dir: ANDROID_PRODUCT_BUILD
CURRENT_BASE_DIR=$(pwd);

echo "dir: $CURRENT_BASE_DIR";

ROBOT_HOME_NAME="ANDROID_PRODUCT_BUILD";
ROBOT_HOME="";

for dir in `find / -type d -name $ROBOT_HOME_NAME`
do

    if [[ "$dir" =~ "$ROBOT_HOME_NAME" ]]
    then

        ROBOT_HOME="$dir";
        break;

    fi

done

# echo "ROBOT_HOME: $ROBOT_HOME";

if [ -z "$ROBOT_HOME" ]
then

    echo "not find dir: ANDROID_PRODUCT_BUILD";
    exit 0;

fi

eval "cd $ROBOT_HOME";

# step 3: check robot lock
GLOBAL_ROBOT_TASK_LOCK_NAME=".robot_lock";
ROBOT_LOCK=${ROBOT_HOME}/robot/${GLOBAL_ROBOT_TASK_LOCK_NAME};

if [ -f "$ROBOT_LOCK" ]
then

    echo "The current robot system is busy, please wait.......";
    exit 0;

fi

# step 4: get robot task from .../robot/.robot_task_queue
GLOBAL_ROBOT_TASK_QUEUE_NAME=".robot_task_queue";
ROBOT_TASK=${ROBOT_HOME}/robot/${GLOBAL_ROBOT_TASK_QUEUE_NAME};
ROBOT_TASK_COUNT=0;

if [ ! -f "$ROBOT_TASK" ]
then

    eval "touch $ROBOT_TASK";

fi

ROBOT_TASK_COUNT=`cat $ROBOT_TASK | awk 'END{print NR}'`;

echo "robot task count: $ROBOT_TASK_COUNT";

if [ $ROBOT_TASK_COUNT -gt 0 ]
then

    TASK=`cat $ROBOT_TASK | awk '{if( ! -z $0 ) {print $0; exit} }'`;
    echo "robot task: $TASK";

    if [ -n "$TASK" ]
    then

        eval "$TASK";

    fi

fi
