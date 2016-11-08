#!/bin/bash

:<<!
Execution steps
               1.Define variables and functions.
               2.Load all shell scripts and import them into the environment variable to prepare the call.
               3.Load robot config(..../robot/.robot_config.sh).
               4.Load robot task queue.
               5.Load project config(..../robot/.project).
               6.Load product config(..../robot/.product).
               7.run robot_main.
!

# steps:1
CURRENT_BASE_DIR=$(pwd);

# The current directory must be ANDROID_PRODUCT_BUILD
CHECK_CURRENT_DIR=`echo $CURRENT_BASE_DIR | awk -F '/' '{print $NF}'`;
echo "Current execution robot directory: $CHECK_CURRENT_DIR";
if [ "ANDROID_PRODUCT_BUILD" != "$CHECK_CURRENT_DIR" ]
then
    echo "Execute the current path of the script is not legal, please operate in the ANDROID_PRODUCT_DIR";
    exit;
fi


ALL_SHELL_SCRIPT_NO=0;
function load_all_robot_scripts(){

    # robot directory
    GLOBAL_CURRENT_ROBOT_DIR=${CURRENT_BASE_DIR}/${GLOBAL_ROBOT_DIR};

    for file in ` ls $1 `
    do
        if [ -d $1"/"$file ]
        then
            load_all_robot_scripts $1"/"$file;
        else
            shell_script=$1"/"$file;
            shell_script_name=`echo $shell_script | awk -F '/' '{print $NF}'`;
            shell_script_suffix=`echo $shell_script | awk -F '.' '{print $NF}'`;

            # Ignore all that is not a shell script file
            if [ "sh" != "$shell_script_suffix" ]
            then
                continue;
            fi

            # Ignore the shell script in the array GLOBAL_NEED_IGNORE_SHELL_SCRIPT
            is_continue="false";
            for ignore_script in ${GLOBAL_NEED_IGNORE_SHELL_SCRIPT[@]}
            do
                if [ "$ignore_script" == "$shell_script_name" ]
                then
                    is_continue="true";
                    break;
                fi
            done
            if [ "$is_continue" == "true" ]
            then
                continue;
            fi

            ((ALL_SHELL_SCRIPT_NO++));
            eval "source $shell_script";
            ALL_SHELL_SCRIPTS[ALL_SHELL_SCRIPT_NO]="$shell_script";

        fi
    done

}

function load_robot_config(){

    # robot config
    GLOBAL_ROBOT_CONFIG=${GLOBAL_CURRENT_ROBOT_DIR}/${GLOBAL_ROBOT_CONFIG_NAME};

    # robot config
    create_global_robot_config;
    eval "source ${GLOBAL_ROBOT_CONFIG}";

    # logger in linux
    GLOBAL_ROBOT_SYSTEM_LOG_STATUS=$(is_exist_global_robot_system_log);

}

# @parame $1: dir
function load_effective_products(){

    dir=$1;

    if [ -d "$dir" ]
    then

        j=0;
        for i in `ls $dir`
        do

            GLOBAL_PRODUCTS[j]=$i;
            j=`expr $j + 1`;

        done
    fi

}

function display_all_project_config(){

    for product in ${GLOBAL_PRODUCTS[@]}
    do

        for config in `eval echo '${'$(conversion_legitmate_variables_name $product)'[@]}'`
        do

            robot_logger_i "product: $product, project config: $config";

        done

    done

}

function load_product_config(){

    # product directory
    GLOBAL_CURRENT_PRODUCT_DIR=${CURRENT_BASE_DIR}/product;
    robot_logger_i "product directory: $GLOBAL_CURRENT_PRODUCT_DIR";

    # project config
    GLOBAL_CURRENT_PRODUCT_CODE_DIR=${GLOBAL_CURRENT_PRODUCT_DIR}/code;
    robot_logger_i "product code directory: $GLOBAL_CURRENT_PRODUCT_CODE_DIR";
    GLOBAL_CURRENT_PRODUCT_RELEASE_DIR=${CURRENT_BASE_DIR}/release;
    robot_logger_i "product release directory: $GLOBAL_CURRENT_PRODUCT_RELEASE_DIR";

    # product config
    GLOBAL_PRODUCT_CONFIG=${GLOBAL_CURRENT_ROBOT_DIR}/${GLOBAL_PRODUCT_CONFIG_NAME};
    create_global_product_config;
    robot_logger_i "product config: $GLOBAL_PRODUCT_CONFIG";

    # init product from .product.
    GLOBAL_PRODUCT_COUNT=($(get_number_rows $GLOBAL_PRODUCT_CONFIG));
    robot_logger_i "product count: $GLOBAL_PRODUCT_COUNT";
    if [ $GLOBAL_PRODUCT_COUNT -gt 0 ]
    then

        # read code url from .product.
        product_code_urls=$(cat $GLOBAL_PRODUCT_CONFIG);

        # Lines in the file contain spaces, which need to be processed by the IFS.
        IFSBAK=$IFS;
        IFS=$'\n';

        for GLOBAL_CURRENT_PROJECT_CODE_URL in $product_code_urls
        do
            if [ -n "$GLOBAL_CURRENT_PROJECT_CODE_URL" ]
            then
                GLOBAL_CURRENT_PROJECT_NAME=`echo $GLOBAL_CURRENT_PROJECT_CODE_URL | awk -F '/' '{print $NF}'`;
                robot_logger_i "product: $GLOBAL_CURRENT_PROJECT_NAME";
                robot_logger_i "product code url: $GLOBAL_CURRENT_PROJECT_CODE_URL";
                # init .project by project url and project name.
                init_current_project_config;
            fi
        done

        # Reduction variables and IFS
        GLOBAL_CURRENT_PROJECT_CODE_URL="";
        GLOBAL_CURRENT_PROJECT_NAME="";
        IFS=$IFSBAK;

    fi

    load_effective_products "${GLOBAL_CURRENT_PRODUCT_CODE_DIR}";

    display_all_project_config;
}

function debug_load_robot_config(){

    # robot script
    robot_logger_i "loading robot script";
    for script in ${ALL_SHELL_SCRIPTS[@]}
    do
        robot_logger_i "shell script: $script";
    done
    robot_logger_i "robot script count: ${#ALL_SHELL_SCRIPTS[@]}";

    # robot version code
    robot_logger_i "robot version code: $GLOBAL_ROBOT_VERSION_CODE";

    # robot release
    robot_logger_i "robot release: $GLOBAL_ROBOT_RELEASE";

    # robot config
    robot_logger_i "robot config: $GLOBAL_ROBOT_CONFIG";
    # robot env
    robot_logger_i "robot env: $GLOBAL_ROBOT_ENV";
    # robot mail status
    robot_logger_i "robot mail status: $GLOBAL_MAIL_STATUS";
    # robot system logger status
    robot_logger_i "system log status: $GLOBAL_ROBOT_SYSTEM_LOG_STATUS";
}

function load_project_config(){

    # project config
    GLOBAL_PROJECT_CONFIG=${GLOBAL_CURRENT_ROBOT_DIR}/${GLOBAL_PROJECT_CONFIG_NAME};
    robot_logger_i "project config: $GLOBAL_PROJECT_CONFIG";

    if [ ! -f "$GLOBAL_PROJECT_CONFIG" ]
    then
        create_global_project_config;
    fi

    eval "source $GLOBAL_PROJECT_CONFIG";
}

function check_product_parameter(){

    if [[ "$GLOBAL_CURRENT_PRODUCTS" =~ "all" ]]
    then

        #robot_logger_i "task product product: contain!!!";
        GLOBAL_CURRENT_PRODUCTS=(${GLOBAL_PRODUCTS[*]});

    else

        #robot_logger_i "task product product: not contain!!!";
        OLD_IFS="$IFS";
        IFS=",";
        GLOBAL_CURRENT_PRODUCTS=($GLOBAL_CURRENT_PRODUCTS);
        IFS="$OLD_IFS";

        # check product name whether effective
        for (( i=0;i<${#GLOBAL_CURRENT_PRODUCTS[@]};i++ ))
        do

            #robot_logger_i "i: $i";
            is_product_name_effective=$GLOBAL_OPTION_DISABLE;
            for product in ${GLOBAL_PRODUCTS[*]}
            do

                #robot_logger_i "global product: ${GLOBAL_CURRENT_PRODUCTS[i]}, product: $product";
                if [ "${GLOBAL_CURRENT_PRODUCTS[i]]}" = "$product" ]
                then

                    is_product_name_effective=$GLOBAL_OPTION_ENABLE;

                fi

            done

            #  Remove products that do not exist in the project
            if [ "$is_product_name_effective" = "$GLOBAL_OPTION_DISABLE" ]
            then

                unset GLOBAL_CURRENT_PRODUCTS[$i];

            fi

        done


    fi

}

function print_product_parameter(){

    for product in ${GLOBAL_CURRENT_PRODUCTS[@]}
    do

        robot_logger_i "Legitimate product: $product"

    done

}

function check_build_type_parameter(){

    if [[ "$GLOBAL_CURRENT_BUILD_TYPE" =~ "all" ]]
    then

        #robot_logger_i "task product build: contain!!!";
        GLOBAL_CURRENT_BUILD_TYPE=(${GLOBAL_SUPPORT_ALL_BUILD_TYPE[*]});

    else

        #robot_logger_i "task product build: not contain!!!";
        OLD_IFS="$IFS";
        IFS=",";
        GLOBAL_CURRENT_BUILD_TYPE=($GLOBAL_CURRENT_BUILD_TYPE);
        IFS="$OLD_IFS";

        # check build type name whether effective
        for (( i=0;i<${#GLOBAL_CURRENT_BUILD_TYPE[@]};i++ ))
        do

            #robot_logger_i "i: $i";
            is_build_type_effective=$GLOBAL_OPTION_DISABLE;
            for build_type in ${GLOBAL_SUPPORT_ALL_BUILD_TYPE[*]}
            do

                #robot_logger_i "global build type: ${GLOBAL_CURRENT_BUILD_TYPE[i]}, product: $build_type";
                if [ "${GLOBAL_CURRENT_BUILD_TYPE[i]}" = "$build_type" ]
                then

                    is_build_type_effective=$GLOBAL_OPTION_ENABLE;

                fi

            done

            #  Remove products that do not exist in the project
            if [ "$is_build_type_effective" = "$GLOBAL_OPTION_DISABLE" ]
            then

                unset GLOBAL_CURRENT_BUILD_TYPE[$i];

            fi

        done

    fi

}

function print_build_type_parameter(){

    for build_type in ${GLOBAL_CURRENT_BUILD_TYPE[@]}
    do

        robot_logger_i "Legitimate build type: $build_type"

    done
}

# param $1: product
function init_project_dir_in_product_build_task(){

    product=$1;

    if [ -z "$product" ]
    then
        robot_logger_e "product is not valid";
        exit 0;
    fi

    GLOBAL_CURRENT_PROJECT_NAME=$product;
    GLOBAL_CURRENT_PROJECT_CODE_DIR=${GLOBAL_CURRENT_PRODUCT_CODE_DIR}/${GLOBAL_CURRENT_PROJECT_NAME};

    # project release
    GLOBAL_CURRENT_PROJECT_RELEASE_DIR=${GLOBAL_CURRENT_PRODUCT_RELEASE_DIR}/${GLOBAL_CURRENT_PROJECT_NAME};

    # project release:daily-build
    GLOBAL_CURRENT_PROJECT_RELEASE_DAILY_BUILD_DIR=${GLOBAL_CURRENT_PROJECT_RELEASE_DIR}/${GLOBAL_PRODUCT_RELEASE_DAILY_BUILD_DIR};

    # project release:package
    GLOBAL_CURRENT_PROJECT_RELEASE_PACEAGE_DIR=${GLOBAL_CURRENT_PROJECT_RELEASE_DIR}/${GLOBAL_PRODUCT_RELEASE_PACEKAGE_DIR};

    # project release: QA
    GLOBAL_CURRENT_PROJECT_RELEASE_QA_DIR=${GLOBAL_CURRENT_PROJECT_RELEASE_DIR}/${GLOBAL_PRODUCT_RELEASE_QA_DIR};

    robot_logger_i "product: ${GLOBAL_CURRENT_PROJECT_NAME}, release dir: ${GLOBAL_CURRENT_PROJECT_RELEASE_DIR}, daily-build dir: ${GLOBAL_CURRENT_PROJECT_RELEASE_DAILY_BUILD_DIR}, package dir: ${GLOBAL_CURRENT_PROJECT_RELEASE_PACEAGE}, QA dir: ${GLOBAL_CURRENT_PROJECT_RELEASE_QA_DIR}";

}

# param $1: product
function init_project_config_in_product_build_task(){

    product=$1;

    if [ -z "$product" ]
    then
        robot_logger_e "product is not valid";
        exit 0;
    fi

    i=0;
    for project_config in `eval echo '${'$(conversion_legitmate_variables_name $product)'[@]}'`
    do

        if [ $i -eq 0 ]
        then

            # project name
            GLOBAL_CURRENT_PROJECT_NAME=$project_config;


        elif [ $i -eq 1 ]
        then

            # project code url
            GLOBAL_CURRENT_PROJECT_CODE_URL=$project_config;

        elif [ $i -eq 2 ]
        then

             # project build
             if [ -n $project_config ]
             then

                 OLD_IFS="$IFS";
                 IFS=",";
                 GLOBAL_CURRENT_PROJECT_BUILD_TYPE=($project_config);
                 IFS="$OLD_IFS";

             fi

        elif [ $i -eq 3 ]
        then

            # build extend parameter
            if [ -n $project_config ]
            then

                GLOBAL_CURRENT_PROJECT_BUILD_EXTEND_PARAM=$project_config;

            fi


        fi

             i=$[$i+1];

    done

    robot_logger_i "project name: $GLOBAL_CURRENT_PROJECT_NAME, project code url: $GLOBAL_CURRENT_PROJECT_CODE_URL";

    for build_type in ${GLOBAL_CURRENT_PROJECT_BUILD_TYPE[@]}
    do

        robot_logger_i "project name: $GLOBAL_CURRENT_PROJECT_NAME , support build type: $build_type";

    done

    robot_logger_i "build extend parameter: $GLOBAL_CURRENT_PROJECT_BUILD_EXTEND_PARAM";
}

# param: $1: dir
function create_current_project_output_dir(){

    dir=$1;

    if [ -n "$dir" ]
    then

        GLOBAL_CURRENT_TIME=$(date +%Y-%m-%d-%H-%M-%S);
        robot_logger_i "current time: $GLOBAL_CURRENT_TIME";

        GLOBAL_CURRENT_PROJECT_OUTPUT_DIR=${dir}/${GLOBAL_CURRENT_TIME};
        if [ ! -d "$GLOBAL_CURRENT_PROJECT_OUTPUT_DIR" ]
        then

            eval "mkdir -p $GLOBAL_CURRENT_PROJECT_OUTPUT_DIR";

            GLOBAL_CURRENT_PROJECT_LOG=${GLOBAL_CURRENT_PROJECT_OUTPUT_DIR}/${GLOBAL_CURRENT_TIME}.log;
            if [ ! -f "$GLOBAL_CURRENT_PROJECT_LOG" ]
            then

                eval "touch $GLOBAL_CURRENT_PROJECT_LOG";

            fi

        fi

    fi

}

# parameter $1: build
function create_build_command(){

    build=$1;

    build_command="${GRADLE_BUILD_COMMAND_GRADLE} ${GRADLE_BUILD_COMMAND_GRADLE_PARAM_CLEAN} ${build} ${GRADLE_BUILD_COMMAND_GRADLE_EXTEND_PARAM_DAEMON} ${GRADLE_BUILD_COMMAND_GRADLE_EXTEND_PARAM_THREADS}";

    if [ -n "$GLOBAL_CURRENT_PROJECT_BUILD_EXTEND_PARAM" ]
    then

        build_command+=" $GLOBAL_CURRENT_PROJECT_BUILD_EXTEND_PARAM";

    fi

    output_log=" &>${GLOBAL_CURRENT_PROJECT_LOG}";
    build_command+=$output_log;

    echo $build_command;

}

function send_build_mail(){

    if [ "$GLOBAL_MAIL_STATUS" = "$GLOBAL_OPTION_OPEN" ]
    then

        send_email="mutt -s '$GLOBAL_CURRENT_MAIL_TITLE' nothingoneday@163.com -c hongjun.jing@gmail.com < $GLOBAL_CURRENT_MAIL_CONTENT";

        robot_logger_i "send mail: $send_email";

        eval "$send_email";

    fi

}

# param $1:
function analysis_build_log(){

    if [ -f "$GLOBAL_CURRENT_PROJECT_LOG" ]
    then

        BUILD_RESULT="grep -rnw -A 5 '$GRADLE_BUILD_RESULT_SUCCESS' $GLOBAL_CURRENT_PROJECT_LOG";

        eval $BUILD_RESULT;
        if [ $? -eq 0 ]
        then

            GRADLE_CURRENT_BUILD_RESULT=$GLOBAL_OPTION_SUCCESS;

            # apk dir
            GLOBAL_CURRENT_PROJECT_APK_OUTPUT_DIR="${GLOBAL_CURRENT_PROJECT_OUTPUT_DIR}/${GLOBAL_PROJECT_APK_DIR}";
            if [ ! -d "$GLOBAL_CURRENT_PROJECT_APK_OUTPUT_DIR" ]
            then

                eval "mkdir -p $GLOBAL_CURRENT_PROJECT_APK_OUTPUT_DIR";

            fi
            robot_logger_i "apk dir: $GLOBAL_CURRENT_PROJECT_APK_OUTPUT_DIR";

            # copy all apk to apk dir;
            for apk in `find ./ -name *.apk`
            do

                if [ -f "$apk" ]
                then

                    eval "cp $apk $GLOBAL_CURRENT_PROJECT_APK_OUTPUT_DIR";

                fi
            done

            # write apk dir to mail content
            echo $GLOBAL_APK_DIR_TITLE >>$GLOBAL_CURRENT_MAIL_CONTENT;
            APK_DIR="tree $GLOBAL_CURRENT_PROJECT_APK_OUTPUT_DIR -Dst >>$GLOBAL_CURRENT_MAIL_CONTENT";
            eval $APK_DIR;

            # email success title
            GLOBAL_CURRENT_MAIL_TITLE="${GLOBAL_CURRENT_PROJECT_NAME} build ${GLOBAL_OPTION_SUCCESS}";


        else

            GRADLE_CURRENT_BUILD_RESULT=$GLOBAL_OPTION_FAILURE;

            # email failure title
            GLOBAL_CURRENT_MAIL_TITLE="${GLOBAL_CURRENT_PROJECT_NAME} build ${GLOBAL_OPTION_FAILURE}";

            BUILD_RESULT="grep -rnw -A 40 '$GRADLE_BUILD_FEATURE_FEATURE' $GLOBAL_CURRENT_PROJECT_LOG";
            eval $BUILD_RESULT;
            if [ $? -eq 0 ]
            then

                # excption
                echo $GLOBAL_EXCETIPN_TITLE >>$GLOBAL_CURRENT_MAIL_CONTENT;
                eval "$BUILD_RESULT >>$GLOBAL_CURRENT_MAIL_CONTENT";

            fi

        fi

    fi


}

# param $1: build
function build_android_gradle_normal(){

    build=$1;

    if [ -n "$build" ]
    then

        robot_logger_i "build:normal build: $build";
        create_current_project_output_dir $GLOBAL_CURRENT_PROJECT_RELEASE_DAILY_BUILD_DIR;

        GLOBAL_CURRENT_PROJECT_BUILD_COMMAND=$(create_build_command $build);
        robot_logger_i "build command: $GLOBAL_CURRENT_PROJECT_BUILD_COMMAND";
        eval "$GLOBAL_CURRENT_PROJECT_BUILD_COMMAND";

        # create mail dir
        GRADLE_EMAIL_DIR="${GLOBAL_CURRENT_PROJECT_OUTPUT_DIR}/${GRADLE_EMAIL_DIR_NAME}";
        robot_logger_i "mail dir: $GRADLE_EMAIL_DIR";

        if [ -d "$GRADLE_EMAIL_DIR" ]
        then

            eval "rm -rf $GRADLE_EMAIL_DIR";

        else

            eval "mkdir -p $GRADLE_EMAIL_DIR";
            GRADLE_ANDROID_NORMAL_EMAIL_FILE="${GRADLE_EMAIL_DIR}/${GRADLE_ANDROID_NORMAL_EMAIL_FILE_NAME}";
            robot_logger_i "mail file name: $GRADLE_ANDROID_NORMAL_EMAIL_FILE";

            GLOBAL_CURRENT_MAIL_CONTENT=$GRADLE_ANDROID_NORMAL_EMAIL_FILE;
            robot_logger_i "current mail file:  $GLOBAL_CURRENT_MAIL_CONTENT";

            if [ ! -f "$GRADLE_ANDROID_NORMAL_EMAIL_FILE" ]
            then

                eval "touch $GRADLE_ANDROID_NORMAL_EMAIL_FILE";

            fi

        fi

        analysis_build_log;
        send_build_mail;


    fi

}

# param $1: build
function build_android_gradle_flavors(){

    build=$1;

    if [ -n "$build" ]
    then

        robot_logger_i "build:flavors build: $build";
        create_current_project_output_dir $GLOBAL_CURRENT_PROJECT_RELEASE_PACEAGE_DIR;

        GLOBAL_CURRENT_PROJECT_BUILD_COMMAND=$(create_build_command $build);
        robot_logger_i "build command: $GLOBAL_CURRENT_PROJECT_BUILD_COMMAND";
        eval "$GLOBAL_CURRENT_PROJECT_BUILD_COMMAND";

        # create mail dir
        GRADLE_EMAIL_DIR="${GLOBAL_CURRENT_PROJECT_OUTPUT_DIR}/${GRADLE_EMAIL_DIR_NAME}";
        robot_logger_i "mail dir: $GRADLE_EMAIL_DIR";

        if [ -d "$GRADLE_EMAIL_DIR" ]
        then

            eval "rm -rf $GRADLE_EMAIL_DIR";

        else

            eval "mkdir -p $GRADLE_EMAIL_DIR";
            GRADLE_ANDROID_FLAVORS_EMAIL_FILE="${GRADLE_EMAIL_DIR}/${GRADLE_ANDROID_FLAVORS_EMAIL_FILE_NAME}";
            robot_logger_i "mail file name: $GRADLE_ANDROID_FLAVORS_EMAIL_FILE";

            GLOBAL_CURRENT_MAIL_CONTENT=$GRADLE_ANDROID_FLAVORS_EMAIL_FILE;
            robot_logger_i "current mail file:  $GLOBAL_CURRENT_MAIL_CONTENT";

            if [ ! -f "$GRADLE_ANDROID_FLAVORS_EMAIL_FILE" ]
            then

                eval "touch $GRADLE_ANDROID_FLAVORS_EMAIL_FILE";

            fi

        fi

        analysis_build_log;
        send_build_mail;

    fi

}

# param $1: build
function build_android_gradle_check(){

    build=$1;

    if [ -n "$build" ]
    then

        robot_logger_i "build:check build: $build";
        create_current_project_output_dir $GLOBAL_CURRENT_PROJECT_RELEASE_QA_DIR;

        GLOBAL_CURRENT_PROJECT_BUILD_COMMAND=$(create_build_command $build);
        robot_logger_i "build command: $GLOBAL_CURRENT_PROJECT_BUILD_COMMAND";
        eval "$GLOBAL_CURRENT_PROJECT_BUILD_COMMAND";


        # create mail dir
        GRADLE_EMAIL_DIR="${GLOBAL_CURRENT_PROJECT_OUTPUT_DIR}/${GRADLE_EMAIL_DIR_NAME}";
        robot_logger_i "mail dir: $GRADLE_EMAIL_DIR";

        if [ -d "$GRADLE_EMAIL_DIR" ]
        then

            eval "rm -rf $GRADLE_EMAIL_DIR";

        else

            eval "mkdir -p $GRADLE_EMAIL_DIR";
            GRADLE_ANDROID_CHECK_EMAIL_FILE="${GRADLE_EMAIL_DIR}/${GRADLE_ANDROID_CHECK_EMAIL_FILE_NAME}";
            robot_logger_i "mail file name: $GRADLE_ANDROID_CHECK_EMAIL_FILE";

            GLOBAL_CURRENT_MAIL_CONTENT=$GRADLE_ANDROID_CHECK_EMAIL_FILE;
            robot_logger_i "current mail file:  $GLOBAL_CURRENT_MAIL_CONTENT";

            if [ ! -f "$GRADLE_ANDROID_CHECK_EMAIL_FILE" ]
            then

                eval "touch $GRADLE_ANDROID_CHECK_EMAIL_FILE";

            fi

        fi

        analysis_build_log;
        send_build_mail;

    fi

}

function build_project(){

    build_count=${#GLOBAL_CURRENT_BUILD[@]};
    robot_logger_i "build_count: $build_count";

    for (( i=0;i<${#GLOBAL_CURRENT_BUILD_TYPE[@]};i++ ))
    do

        for (( j=0;j<${#GLOBAL_CURRENT_PROJECT_BUILD_TYPE[@]};j++ ))
        do

            if [ "${GLOBAL_CURRENT_BUILD_TYPE[$i]}" = "${GLOBAL_CURRENT_PROJECT_BUILD_TYPE[$j]}" ]
            then

                if [  "${GLOBAL_CURRENT_BUILD_TYPE[$i]}" = "$GLOBAL_SUPPORT_PROJECT_ANDROID_GRADLE_NORMAL" ]
                then

                    # android:gradle:normal
                    robot_logger_i "android:gradle:normal";
                    for build in ${GLOBAL_CURRENT_BUILD[@]}
                    do

                        robot_logger_i "build: $build";
                        build_android_gradle_normal $build;

                    done


                elif [ "${GLOBAL_CURRENT_BUILD_TYPE[$i]}" = "$GLOBAL_SUPPORT_PROJECT_ANDROID_GRADLE_FLAVORS" ]
                then

                    # android:gradle:flavors
                    robot_logger_i "android:gradle:flavors";
                    for build in ${GLOBAL_CURRENT_BUILD[@]}
                    do

                        # The current task is to identify the key word is assemble, otherwise directly skip
                        identify_key="assemble";
                        if [[  "$build" =~ "$identify_key" ]]
                        then

                            robot_logger_i "build: $build";
                            build_android_gradle_flavors $build;

                        else

                            robot_logger_e "The current task is to identify the key word is assemble, otherwise directly skip";
                            continue;

                        fi


                    done

                elif [ "${GLOBAL_CURRENT_BUILD_TYPE[$i]}" = "$GLOBAL_SUPPORT_PROJECT_ANDROID_GRADLE_CHECK" ]
                then

                    # android:gradle:check
                    robot_logger_i "android:gradle:check";
                    for build in ${GLOBAL_CURRENT_BUILD[@]}
                    do

                        # The current task is to identify the key word is check, otherwise directly skip
                        identify_key="check";
                        if [[  "$build" =~ "$identify_key" ]]
                        then

                            robot_logger_i "build: $build";
                            build_android_gradle_check $build;

                        else

                            robot_logger_e "The current task is to identify the key word is check, otherwise directly skip";
                            continue;

                        fi

                    done

                else

                    continue;

                fi


            else

                continue;

            fi

        done

    done

}

# param $1: task_in_robot_queue
function task_product_build(){

    task_in_robot_queue=$1;

    robot_logger_i "task in robot queue: $task_in_robot_queue";

    if [ -n "$GLOBAL_CURRENT_PRODUCTS" -a -n "$GLOBAL_CURRENT_BUILD_TYPE" ]
    then

        robot_logger_i "task product build: current products: $GLOBAL_CURRENT_PRODUCTS, build_type: $GLOBAL_CURRENT_BUILD_TYPE";

        # step:1 Analysis products parameter
        check_product_parameter;

        # print product msg
        print_product_parameter;

        # step:2 Analysis build type parameter
        check_build_type_parameter;

        # print build type msg
        print_build_type_parameter;

        product_count=${#GLOBAL_CURRENT_PRODUCTS[@]};
        build_type_count=${#GLOBAL_CURRENT_BUILD_TYPE[@]};

        robot_logger_i "products count: $product_count, build type count: $build_type_count";

        # step:3 process robot task
        if [ $product_count -gt 0 -a $build_type_count -gt 0 ]
        then

            if [ "$task_in_robot_queue" = "$GLOBAL_OPTION_NO" ]
            then
                # step:3.1 add robot queue
                add_robot_task_queue;

            else

                # step:3.2 excute robot task
                for product in ${GLOBAL_CURRENT_PRODUCTS[@]}
                do

                    if [ -z "$product" ]
                    then
                        robot_logger_e "project name is not valid!!!";
                        continue;
                    fi

                    # step:4 init product dir
                    init_project_dir_in_product_build_task $product;

                    # step:5 load project config
                    init_project_config_in_product_build_task $product;

                    eval "cd $GLOBAL_CURRENT_PROJECT_CODE_DIR";
                    robot_logger_i "current dir: $(pwd)";

                    # step:6
                    build_project;

                done

            fi


        else

            robot_logger_e "-p|--product or -b|--build is not valid!";

        fi

    fi

}

function load_robot_task_queue(){

    # robot task queue
    GLOBAL_ROBOT_TASK_QUEUE="${GLOBAL_CURRENT_ROBOT_DIR}/${GLOBAL_ROBOT_TASK_QUEUE_NAME}";
    robot_logger_i "robot task queue file path: $GLOBAL_ROBOT_TASK_QUEUE";

    if [ ! -f "$GLOBAL_ROBOT_TASK_QUEUE" ]
    then

        eval "touch $GLOBAL_ROBOT_TASK_QUEUE";

    fi

    queue_count=`cat $GLOBAL_ROBOT_TASK_QUEUE | awk 'END{print NR}'`;
    robot_logger_i "robot task queue count: $queue_count";


}

function add_robot_task_queue(){

    robot_logger_i "robot parameter: $GLOBAL_ROBOT_PARAMETER";

    if [ -n "$GLOBAL_ROBOT_PARAMETER" ]
    then

        add_task_queue=" --task-queue "$GLOBAL_ROBOT_PARAMETER;
        robot_task=${GLOBAL_MAIN_ROBOT_SHELL_PATH}${add_task_queue};
        robot_logger_i "robot task command: $robot_task";

        task_queue_count=`cat $GLOBAL_ROBOT_TASK_QUEUE | awk 'END{print NR}'`;
        if [ $task_queue_count -eq 0 ]
        then

            echo $robot_task >$GLOBAL_ROBOT_TASK_QUEUE;

        else

            sed_command="sed -i '${task_queue_count}a ${robot_task}' $GLOBAL_ROBOT_TASK_QUEUE";
            eval "$sed_command";

        fi

    fi

}

function clean_robot_env(){

    robot_logger_i "clean robot env...";

    # delete product code dir
    if [ -d "${GLOBAL_CURRENT_PRODUCT_CODE_DIR}" ]
    then

        robot_logger_i "delete ${GLOBAL_CURRENT_PRODUCT_CODE_DIR}/*";
        eval "rm -rf ${GLOBAL_CURRENT_PRODUCT_CODE_DIR}/*"
    fi

    # delete release code dir
    if [ -d "${GLOBAL_CURRENT_PRODUCT_RELEASE_DIR}" ]
    then
        robot_logger_i "delete ${GLOBAL_CURRENT_PRODUCT_RELEASE_DIR}/*";
        eval "rm -rf ${GLOBAL_CURRENT_PRODUCT_RELEASE_DIR}/*";
    fi

    # delete .robot_config.sh
    if [ -f "${GLOBAL_ROBOT_CONFIG}" ]
    then
        robot_logger_i "delete ${GLOBAL_ROBOT_CONFIG}";
        eval "rm -rf ${GLOBAL_ROBOT_CONFIG}";
    fi

    # delete .product
    if [ -f "${GLOBAL_PRODUCT_CONFIG}" ]
    then
        robot_logger_i "delete ${GLOBAL_PRODUCT_CONFIG}";
        eval "rm -rf ${GLOBAL_PRODUCT_CONFIG}";
    fi

    # delete .project.sh
    if [ -f "${GLOBAL_PROJECT_CONFIG}" ]
    then
        robot_logger_i "delete ${GLOBAL_PROJECT_CONFIG}";
        eval "rm -rf ${GLOBAL_PROJECT_CONFIG}";
    fi

    # delete .robot_task_queue
    if [ -f "${GLOBAL_ROBOT_TASK_QUEUE}" ]
    then
        robot_logger_i "delete ${GLOBAL_ROBOT_TASK_QUEUE}";
        eval "rm -rf ${GLOBAL_ROBOT_TASK_QUEUE}";
    fi

    # delete .robot_lockI
    if [ -f "${GLOBAL_ROBOT_TASK_LOCK}" ]
    then
        robot_logger_i "delete ${GLOBAL_ROBOT_TASK_LOCK}";
        eval "rm -rf ${GLOBAL_ROBOT_TASK_LOCK}";
    fi
}

function robot_main(){

    GLOBAL_ROBOT_PARAMETER=$*;

    # remark
    # The robot task of the external call is added directly to the robot task queue (./robot/.robot_task_queue), which is unified by the robot task manager schedule.
    task_in_robot_queue=$GLOBAL_OPTION_NO;
    clean_env=$GLOBAL_OPTION_DISABLE;
    # Parse command line arguments
    args=`getopt -o htp:b:c:: --long help,task-queue,clean,product:,build-type:,build:,c-long:: -- "$@"`
    eval set -- "$args";

    while true ; do
        case "$1" in
            -h|--help)
                robot_logger_i "help";
                shift ;;
            -t|--task-queue)
                task_in_robot_queue=$GLOBAL_OPTION_YES;
                shift ;;
            --clean)
                clean_robot_env;
                clean_env=$GLOBAL_OPTION_ENABLE;
                shift ;;
            -p|--product)
                GLOBAL_CURRENT_PRODUCTS=$2;
                shift 2 ;;
            --build-type)
                GLOBAL_CURRENT_BUILD_TYPE=$2;
                shift 2 ;;
            -b|--build)
                OLD_IFS="$IFS";
                IFS=",";
                GLOBAL_CURRENT_BUILD=($2);
                IFS="$OLD_IFS";
                shift 2 ;;
            --) shift ; break ;;
            *) robot_logger_i "internal error!" ; exit 1 ;;
        esac
    done

    if [ "$clean_env" = "$GLOBAL_OPTION_ENABLE" ]
    then

        exit 0;

    fi

    # task: product build
    task_product_build $task_in_robot_queue;

}

# steps:2
GLOBAL_CURRENT_ROBOT_DIR=${CURRENT_BASE_DIR}/robot;
load_all_robot_scripts $GLOBAL_CURRENT_ROBOT_DIR;

# steps:3
load_robot_config;
debug_load_robot_config;

# steps:4
load_robot_task_queue;

# steps:5
load_project_config;

# steps:6
load_product_config;

# steps:7
robot_main $*;
