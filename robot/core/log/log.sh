#!/bin/bash

# 此文件用于日志工具

if [ "$log_bash" ]; then
    return;
fi

export log_bash="log.sh";

# 日志级别
# v(verbose-black) < d(debug->blue) < i(info->green) < w(warn->yellow) < e(error->red) 

# 字体设置说明
# shell echo 显示内容带颜色需要使用echo -e
# echo -e "\033[字背景颜色;文字颜色m 字符串 \033[0m"
# 字体颜色: 30:黑色; 31:红色; 32:绿色; 33:黄色; 34蓝色; 35:紫色; 36:天蓝色; 37:白色
# 字体背景颜色: 40:黑底; 41:红底; 42:绿底; 43:黄底; 44:蓝底; 45:紫底; 46:天蓝底; 47:白底
# 控制选项: \33[0m:关闭所有属性; \33[1m:设置高亮度; \33[4m:下划线; \33[5m:闪烁 

# use logger in ubuntu.
# @param $1: level
# @param $2: message
function system_logger(){
    level=$1;
    message=$2;
    if [ "$GLOBAL_OPTION_OPEN" == "${GLOBAL_ROBOT_SYSTEM_LOG_STATUS}" ]
    then
        eval "logger -i -t '${GLOBAL_ROBOT_SYSTEM_LOG_NAME}' -p '${level}' '${message}'";
    fi
}

# error log
# @param $1: 消息
function robot_logger_e () {
    message=$1;
    level=4;
    if [ -n "$message" ]; then
    if [ $level -ge $GLOBAL_ROBOT_SYSTEM_LOG_LEVEL ]; then
        echo -e "\033[41;37m $message \033[0m";
        system_logger "${GLOBAL_ROBOT_SYSTEM_LEVEL_ERROR}" "$message";
	fi
    fi
}

# debug log
# @param $1: 消息
function robot_logger_d () {
    message=$1;
    level=1;
    if [ -n "$message" ]; then
    if [ $level -ge $GLOBAL_ROBOT_SYSTEM_LOG_LEVEL ]; then
        echo -e "\033[44;37m $message \033[0m";
        system_logger "${GLOBAL_ROBOT_SYSTEM_LEVEL_DEBUG}" "$message";
	fi
    fi
}

# info log
# @param $1: 消息
function robot_logger_i () {
    message=$1;
    level=2;
    if [ -n "$message" ]; then
    if [ $level -ge $GLOBAL_ROBOT_SYSTEM_LOG_LEVEL ]; then
        echo -e "\033[42;37m $message \033[0m";
        system_logger "${GLOBAL_ROBOT_SYSTEM_LEVEL_INFO}" "$message";
    fi
    fi
}

# warn log
# @param $1:  消息
function robot_logger_w () {
    message=$1;
    level=3;
    if [ -n "$message" ]; then
    if [ $level -ge $GLOBAL_ROBOT_SYSTEM_LOG_LEVEL ]; then
        echo -e "\033[43;37m $message \033[0m";
        system_logger "${GLOBAL_ROBOT_SYSTEM_LEVEL_NOTICE}" "$message";
	fi
    fi
}

# verbose log
# @param $1: 消息
function robot_logger_v () {
    message=$1;
    level=0;
    if [ -n "$message" ]; then
    if [ $level -ge $GLOBAL_ROBOT_SYSTEM_LOG_LEVEL ]; then
        echo -e "\033[30;37m $message \033[0m";
        system_logger "${GLOBAL_ROBOT_SYSTEM_LEVEL_VERBOSE}" "$message";
    fi
    fi
}

