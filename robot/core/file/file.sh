#!/bin/bash

if [ "$file_bash" ]
then
    echo "loading file.sh";
    return;
fi
export file_bash="file.sh";

# @param $1: file
function read_dir(){

    if [ -z $i ]
    then
       i=0;
    fi

    for file in `ls $1`
    do
        if [ -d $1"/"$file ]
        then
            read_dir $1"/"$file
        else
            ((i++));
            item=$1"/"$file;
            files[i]=$item;
        fi
    done

    echo ${files[*]};

}

# test read_dir
#files=($(read_dir "/taogu/git/ANDROID_PRODUCT_BUILD/auto_builder"));
#for file in ${files[@]}
#do
#    echo "file: $file";
#done

# @param $1: file
function get_number_rows(){

    file=$1;

    rows=0;
    if [  -f "$file" ]
    then
        rows=`cat $file | awk 'END{print NR}'`;
    fi
    echo $rows;

}

function string_to_array(){

    string=$1;

    if [ -n "$string" ]
    then
        OLD_IFS="$IFS";
        IFS=" ";
        array=($string);
        IFS="$OLD_IFS";
        echo ${array[*]};
    fi

}


# @param $1: file
# @param $2: row
function get_specify_rows_from_file(){

    file=$1;
    row=$2;

    content="";
    if [ -f  "$file" ]
    then
        content=`cat $file| awk "NR==$row"`;
    fi
    echo $content;

}

# @param $1: dir
function create_dir(){

    dir=$1;

    if [ ! -d "$dir" ]
    then
        eval "mkdir -p $dir";
    fi
}

# @param $1: file
function create_file(){

    file=$1;

    if [ -n "$file" ]
    then
        file_name=`echo $file | awk -F '/' '{print $NF}'`;
        dir=${file/"${file_name}"/""};
        if [ ! -d "$dir" ]
        then
            create_dir $dir;
        else
            if [ ! -f "$file" ]
            then
                eval "touch $file";
            fi
        fi
    fi

}

function append_content_file_end(){

    file=$1;
    content=$2;

    echo "file: $file, content: $content";

    if [ ! -f "$file" ]
    then
      return 1;
    fi

    if [ -n "$content" ]
    then
        end_row=`cat $file | awk 'END{print NR}'`;
        echo "end rows: $end_row";
        eval "sed -i '${end_row}a ${content}' $file";
    fi

}
