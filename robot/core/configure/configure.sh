#!/bin/bash

if [ "$configure_bash" ]
then
    return;
fi
export configure_bash="configure.sh";

:<<!
Execution steps
               1.Define variables and functions.
               2.
!

# steps:1
# variables

# Global robot version code
GLOBAL_ROBOT_VERSION_CODE=1.0;
GLOBAL_ROBOT_RELEASE="robot version 1.0 release";

GLOBAL_CURRENT_TIME="";

# Global robot parameter
GLOBAL_ROBOT_PARAMETER="";

# Global robot dir
GLOBAL_ROBOT_DIR="robot";
GLOBAL_CURRENT_ROBOT_DIR="";

# Global configuration script
GLOBAL_ROBOT_CONFIG_NAME=".robot_config.sh";
GLOBAL_ROBOT_CONFIG="";

# Global option switch
GLOBAL_OPTION_OPEN="open";
GLOBAL_OPTION_CLOSE="close";

GLOBAL_OPTION_ENABLE="enable";
GLOBAL_OPTION_DISABLE="disable";

GLOBAL_OPTION_YES="yes";
GLOBAL_OPTION_NO="no";

# Global system env
GLOBAL_ENV_DEBUG="debug";
GLOBAL_ENV_RELEASE="release";


GLOBAL_NEED_IGNORE_SHELL_SCRIPT=(robot.sh $GLOBAL_ROBOT_CONFIG_NAME robot_dispatch.sh);

# Global log config
GLOBAL_ROBOT_SYSTEM_LOG_NAME="robot";
GOLBAL_ROBOT_SYSTEM_LOG_EXTENSION=".log";
GLOBAL_ROBOT_SYSTEM_LOG_FULL_NAME="${GLOBAL_ROBOT_SYSTEM_LOG_NAME}${GOLBAL_ROBOT_SYSTEM_LOG_EXTENSION}";
GLOBAL_ROBOT_SYSTEM_LOG="/var/log/${GLOBAL_ROBOT_SYSTEM_LOG_FULL_NAME}";
GLOBAL_ROBOT_SYSTEM_LOG_LEVEL=0;
GLOBAL_ROBOT_SYSTEM_LOG_STATUS="";

GLOBAL_ROBOT_SYSTEM_LOCAL="local3";
# log level:verbose
GLOBAL_ROBOT_SYSTEM_LEVEL_VERBOSE="${GLOBAL_ROBOT_SYSTEM_LOCAL}.debug";
# log level:debug
GLOBAL_ROBOT_SYSTEM_LEVEL_DEBUG="${GLOBAL_ROBOT_SYSTEM_LOCAL}.debug";
# log level:info
GLOBAL_ROBOT_SYSTEM_LEVEL_INFO="${GLOBAL_ROBOT_SYSTEM_LOCAL}.info";
# log level:notice
GLOBAL_ROBOT_SYSTEM_LEVEL_NOTICE="${GLOBAL_ROBOT_SYSTEM_LOCAL}.notice";
# log level:error
GLOBAL_ROBOT_SYSTEM_LEVEL_ERROR="${GLOBAL_ROBOT_SYSTEM_LOCAL}.error";


# Global email config
GLOBAL_MAIL_STATUS="";

# Global product config
GLOBAL_PRODUCTS="";
GLOBAL_PRODUCT_CONFIG_NAME=".product";
GLOBAL_PRODUCT_CONFIG="";

GLOBAL_PRODUCT_DIR="product";
GLOBAL_PROJECT_CODE_DIR="code";
GLOBAL_PROJECT_RELEASE_DIR="release";
GLOBAL_PRODUCT_RELEASE_DAILY_BUILD_DIR="daily-build"
GLOBAL_PRODUCT_RELEASE_PACEKAGE_DIR="package";
GLOBAL_PRODUCT_RELEASE_QA_DIR="QA";


GLOBAL_PRODUCT_COUNT="";
GLOBAL_CURRENT_PRODUCT_DIR="";
GLOBAL_CURRENT_PRODUCT_CODE_DIR="";
GLOBAL_CURRENT_PRODUCT_RELEASE_DIR="";

GLOBAL_CURRENT_PRODUCTS="";
GLOBAL_CURRENT_BUILD_TYPE="";
GLOBAL_CURRENT_BUILD="";

GLOBAL_CURRENT_PROJECT_CODE_URL="";
GLOBAL_CURRENT_PROJECT_NAME="";
GLOBAL_CURRENT_PROJECT_CONFIG="";
GLOBAL_CURRENT_PROJECT_CODE_DIR="";
GLOBAL_CURRENT_PROJECT_RELEASE_DIR="";
GLOBAL_CURRENT_PROJECT_RELEASE_DAILY_BUILD_DIR="";
GLOBAL_CURRENT_PROJECT_RELEASE_PACEAGE_DIR="";
GLOBAL_CURRENT_PROJECT_RELEASE_QA_DIR="";
GLOBAL_CURRENT_PROJECT_BUILD_TYPE="";
GLOBAL_CURRENT_PROJECT_OUTPUT_DIR="";
GLOBAL_CURRENT_PROJECT_LOG="";
GLOBAL_CURRENT_PROJECT_BUILD_EXTEND_PARAM="";
GLOBAL_CURRENT_PROJECT_BUILD_COMMAND="";

# Global project config
GLOBAL_PROJECT_CONFIG_NAME=".project.sh";
GLOBAL_PROJECT_CONFIG="";

# Global build type
GLOBAL_SUPPORT_PROJECT_ANDROID_GRADLE_FLAVORS="android:gradle:flavors";
GLOBAL_SUPPORT_PROJECT_ANDROID_GRADLE_NORMAL="android:gradle:normal";
GLOBAL_SUPPORT_PROJECT_ANDROID_GRADLE_CHECK="android:gradle:check";

GLOBAL_SUPPORT_ALL_BUILD_TYPE=($GLOBAL_SUPPORT_PROJECT_ANDROID_GRADLE_FLAVORS $GLOBAL_SUPPORT_PROJECT_ANDROID_GRADLE_NORMAL $GLOBAL_SUPPORT_PROJECT_ANDROID_GRADLE_CHECK);


# Global task queue
GLOBAL_ROBOT_TASK_QUEUE_NAME=".robot_task_queue";
GLOBAL_ROBOT_TASK_QUEUE="";

# Global task lock
GLOBAL_ROBOT_TASK_LOCK_NAME=".robot_lock";
GLOBAL_ROBOT_TASK_LOCK="";

# Gobal robot main shell
GLOBAL_MAIN_ROBOT_SHELL_PATH=". robot/robot.sh";


# gradle command
GRADLE_BUILD_COMMAND_GRADLE="gradle";

GRADLE_BUILD_COMMAND_GRADLE_PARAM_CLEAN="clean";
GRADLE_BUILD_COMMAND_GRADLE_PARAM_BUILD="build";

GRADLE_BUILD_COMMAND_GRADLE_EXTEND_PARAM_DAEMON="--daemon";
GRADLE_BUILD_COMMAND_GRADLE_EXTEND_PARAM_THREADS="--parallel-threads=4";

GRADLE_BUILD_COMMAND_GRADLE_EXTEND_PARAM_DISGNTURE_FILE_PATH="-DsigntureFilePath=";

# function

function is_exist_global_robot_system_log(){
    if [ -f $GLOBAL_ROBOT_SYSTEM_LOG ]
    then
        echo $GLOBAL_OPTION_OPEN;
    else
        echo $GLOBAL_OPTION_CLOSE;
    fi
}

function create_global_robot_config(){
    if [ ! -f "$GLOBAL_ROBOT_CONFIG" ]
    then
        eval "touch ${GLOBAL_ROBOT_CONFIG}";

        echo "#!/bin/bash">>${GLOBAL_ROBOT_CONFIG};

        echo 'GLOBAL_ROBOT_ENV=${GLOBAL_ENV_DEBUG}'>>${GLOBAL_ROBOT_CONFIG};

        echo 'if [ "$GLOBAL_ROBOT_ENV" == "$GLOBAL_ENV_DEBUG" ]'>>${GLOBAL_ROBOT_CONFIG};

        echo "then">>${GLOBAL_ROBOT_CONFIG};

             # debug config start
             echo 'GLOBAL_MAIL_STATUS=$GLOBAL_OPTION_CLOSE;'>>${GLOBAL_ROBOT_CONFIG};
             # debug config end

        echo 'elif [ "$GLOBAL_ROBOT_ENV" == "$GLOBAL_ENV_RELEASE" ]'>>${GLOBAL_ROBOT_CONFIG};

        echo "then">>${GLOBAL_ROBOT_CONFIG};

            # release config start
            echo 'GLOBAL_MAIL_STATUS=$GLOBAL_OPTION_OPEN;'>>${GLOBAL_ROBOT_CONFIG};
            # release config end

        echo "else">>${GLOBAL_ROBOT_CONFIG};

            # default config start
            echo 'GLOBAL_MAIL_STATUS=$GLOBAL_OPTION_OPEN;'>>${GLOBAL_ROBOT_CONFIG};
            # default config end
        echo "fi">>${GLOBAL_ROBOT_CONFIG};
    fi
}


function create_global_product_config(){
    create_file  "$GLOBAL_PRODUCT_CONFIG";
}

function create_global_project_config(){
    if [ ! -f "$GLOBAL_PROJECT_CONFIG" ]
    then
        create_file "$GLOBAL_PROJECT_CONFIG";

        # append "#!/bin/bash to ../robot/.project.sh"
        echo "#!/bin/bash">>$GLOBAL_PROJECT_CONFIG;

    fi
}

# param $1: var
function conversion_legitmate_variables_name(){

    variables=$1;

    result="";

    if [ -n "$variables" ]
    then

        result=${variables//-/_};

    fi

    echo $result;

}

# @param $1: file
function source_shell_file(){

    file=$1;

    if [ -f "$file" ]
    then

        eval "source $file";

    fi

}

# @param $1: project_name
# @param $2: project config file
function create_project_config(){

    project_name=$1;
    project_code_url=$2;
    project_config_file=$3;

    result="";

    robot_logger_i "create_project_config: project_name: $project_name, project_code_url: $project_code_url, project_config_file: $project_config_file";

    if [[ -n "$project_name" && -f "$project_config_file" ]]
    then

        project_config_key=$(conversion_legitmate_variables_name $project_name);

        robot_logger_i "project_config_key: $project_config_key";

        project_config_value=

        # project header
        project_config_value+="${project_config_key}=(";

        # project name
        project_config_value+="\"${project_name}\"";

        project_config_value+=" ";

        # projet code url
        project_config_value+="\"${project_code_url}\"";

        project_config_value+=" ";

        # project build type
        project_config_value+="\"";

        # project android type
        check_android_project="find ./ -name build.gradle | xargs grep -rn 'com.android.application'";
        result=`eval $check_android_project`;
        if [ -n "$result" ]
        then

            project_config_value+=$GLOBAL_SUPPORT_PROJECT_ANDROID_GRADLE_NORMAL;

            # checkstyle, findbug, pmd
            check_android_project_cfp_feature="find ./ -name build.gradle | xargs grep -Ern 'checkstyle|findbug|pmd'";
            result=`eval $check_android_project_cfp_feature`;
            if [ -n "$result" ]
            then

                project_config_value+=",${GLOBAL_SUPPORT_PROJECT_ANDROID_GRADLE_CHECK}";

            fi

            # flavors
            check_android_project_flavors="find ./ -name build.gradle | xargs grep -rn 'productFlavors'";
            result=`eval $check_android_project_flavors`;
            if [ -n "$result" ]
            then

                project_config_value+=",${GLOBAL_SUPPORT_PROJECT_ANDROID_GRADLE_FLAVORS}";

            fi

        fi

        project_config_value+="\"";

        # project end
        project_config_value+=");";

        robot_logger_i "project_config_value: $project_config_value";

        echo $project_config_value>>$GLOBAL_PROJECT_CONFIG;

        source_shell_file $project_config_file;

    fi

    echo $result;

}

# @param $1: project name
#function get_project_config(){

    project_name=$1;

#    project_config="";

#    if [ -n "$project_name" ]
#    then

#        config=$(conversion_legitmate_variables_name $project_name);
#        project_config=`eval echo '$'"$config"`;

#    fi

 #    echo $project_config;

#}

# @param $1: project_name
# @param $2: project_url
function init_current_project_config(){

    # project code dir
    GLOBAL_CURRENT_PROJECT_CODE_DIR=${GLOBAL_CURRENT_PRODUCT_CODE_DIR}/${GLOBAL_CURRENT_PROJECT_NAME};
    robot_logger_i "product code dir: $GLOBAL_CURRENT_PROJECT_CODE_DIR";

    # project release
    GLOBAL_CURRENT_PROJECT_RELEASE_DIR=${GLOBAL_CURRENT_PRODUCT_RELEASE_DIR}/${GLOBAL_CURRENT_PROJECT_NAME};
    create_dir $GLOBAL_CURRENT_PROJECT_RELEASE_DIR;
    robot_logger_i "current project release dir: ${GLOBAL_CURRENT_PROJECT_RELEASE_DIR}";

    # project release:daily-build
    GLOBAL_CURRENT_PROJECT_RELEASE_DAILY_BUILD_DIR=${GLOBAL_CURRENT_PROJECT_RELEASE_DIR}/${GLOBAL_PRODUCT_RELEASE_DAILY_BUILD_DIR};
    create_dir $GLOBAL_CURRENT_PROJECT_RELEASE_DAILY_BUILD_DIR;
    robot_logger_i "current project daily-build dir: $GLOBAL_CURRENT_PROJECT_RELEASE_DAILY_BUILD_DIR";

    # project release:package
    GLOBAL_CURRENT_PROJECT_RELEASE_PACEAGE_DIR=${GLOBAL_CURRENT_PROJECT_RELEASE_DIR}/${GLOBAL_PRODUCT_RELEASE_PACEKAGE_DIR};
    create_dir $GLOBAL_CURRENT_PROJECT_RELEASE_PACEAGE_DIR;
    robot_logger_i "current project package dir: $GLOBAL_CURRENT_PROJECT_RELEASE_PACEAGE_DIR";

    # project release: QA
    GLOBAL_CURRENT_PROJECT_RELEASE_QA_DIR=${GLOBAL_CURRENT_PROJECT_RELEASE_DIR}/${GLOBAL_PRODUCT_RELEASE_QA_DIR};
    create_dir $GLOBAL_CURRENT_PROJECT_RELEASE_QA_DIR;
    robot_logger_i "current project QA dir: $GLOBAL_CURRENT_PROJECT_RELEASE_QA_DIR";

    if [ -d "$GLOBAL_CURRENT_PROJECT_CODE_DIR" ]
    then

        # into code dir
        eval "cd $GLOBAL_CURRENT_PROJECT_CODE_DIR";

        # stash code and sync code
        robot_logger_i "Get the latest code from the code library";
        time=$(date +%Y-%m-%d-%H-%M-%S);
        eval "git stash save stash-${time}";
        eval "git pull --rebase";

    else

        if [ -n "$GLOBAL_CURRENT_PROJECT_CODE_URL" ]
        then

            # into code dir
            eval "cd $GLOBAL_CURRENT_PRODUCT_CODE_DIR";

            # First, sync code
            robot_logger_i "sync code: $GLOBAL_CURRENT_PROJECT_CODE_URL";
            eval "git clone $GLOBAL_CURRENT_PROJECT_CODE_URL";

            # get project config
            robot_logger_i "$GLOBAL_CURRENT_PROJECT_NAME project config";
            project_config=$(get_project_config $GLOBAL_CURRENT_PROJECT_NAME);
            if [ -z "$project_config"  ]
            then

                eval "cd $GLOBAL_CURRENT_PROJECT_CODE_DIR";
                create_project_config "$GLOBAL_CURRENT_PROJECT_NAME" "$GLOBAL_CURRENT_PROJECT_CODE_URL"  "$GLOBAL_PROJECT_CONFIG";

            fi

        fi
    fi

    source_shell_file $GLOBAL_PROJECT_CONFIG;

    cd $CURRENT_BASE_DIR;


}

# The following is a log function configuration
:<<!
# Enable logger in Linux
logger [options] [messages]
**options (选项)：**
-d, --udp
使用数据报(UDP)而不是使用默认的流连接(TCP)
-i, --id
逐行记录每一次logger的进程ID
-f, --file file_name
记录特定的文件
-h, --help
显示帮助文本并退出
-n, --server
写入指定的远程syslog服务器，使用UDP代替内装式syslog的例程
-P, --port port_num
使用指定的UDP端口。默认的端口号是514
-p, --priority priority_level
指定输入消息的优先级，优先级可以是数字或者指定为 " facility.level" 的格式。比如：" -p local3.info " local3 这个设备的消息级别为 info。默认级别是 "user.notice"
-s, --stderr
输出标准错误到系统日志
-t, --tag tag
指定标记记录
-u, --socket socket
写入指定的socket,而不是到内置系统日志例程
-V, --version
现实版本信息并退出

**messages：**写入log文件的内容消息,可以与-f配合使用

logger 以0退出表示成功，大于0表示失败

日志级别

facility:
auth:             用户授权
authpriv:         授权和安全
cron:             计划任务
daemon:           系统守护进程
kern:            与内核有关的信息
lpr:                与打印服务有关的信息
mail:               与电子邮件有关的信息
news:               来自新闻服务器的信息
syslog:             由syslog生成的信息
user:               用户的程序生成的信息，默认
uucp:               由uucp生成的信息
local0~7:           用来定义本地策略

level:
alert          需要立即采取动作
crit           临界状态
debug          调试
emerg          系统不可用
err            错误状态
error          错误状态
info           正常消息
notice         正常但是要注意

Use method steps
1)vi /etc/rsyslog.conf
  2)add  "local3.* /var/log/my_test.log" to /etc/rsyslog.conf  来自local3的所有消息都记录到 /var/log/my_test.log
    3)service rsyslog restart
      4)logger -i -t "my_test" -p local3.notice "test_info"
        my_test--->${GLOBAL_ROBOT_SYSTEM_LOG_NAME}
        local3.notice---->
        GLOBAL_ROBOT_SYSTEM_LOCAL="local3";
         # log level:verbose
         GLOBAL_ROBOT_SYSTEM_LEVEL_VERBOSE="${GLOBAL_ROBOT_SYSTEM_LOCAL}.debug";
         # log level:debug
         GLOBAL_ROBOT_SYSTEM_LEVEL_DEBUG="${GLOBAL_ROBOT_SYSTEM_LOCAL}.debug";
         # log level:info
         GLOBAL_ROBOT_SYSTEM_LEVEL_INFO="${GLOBAL_ROBOT_SYSTEM_LOCAL}.info";
         # log level:notice
         GLOBAL_ROBOT_SYSTEM_LEVEL_NOTICE="${GLOBAL_ROBOT_SYSTEM_LOCAL}.notice";
         # log level:error
         GLOBAL_ROBOT_SYSTEM_LEVEL_ERROR="${GLOBAL_ROBOT_SYSTEM_LOCAL}.error";
         my_test.log---->${GLOBAL_ROBOT_SYSTEM_LOG}
!
