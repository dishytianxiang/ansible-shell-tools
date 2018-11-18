#!/usr/bin/env bash
#######################################################
# $Version:      v1.0
# $Function:     Shell Template Script
# $Description:  copy file to remote machine
#ansible配置文件
ansible_file=""
#主机组
ansible_host=""
file_type=""
src_path=""
dest_path=""

usage(){
    cat <<EOF
    function: copy file to remote hosts
    dependency: 
        1. target host password passed
	2. ansible soft
    example command:
        bash transfer_file.sh -h hadoop -f transfer_hosts -t gz  -src "xxx.gz" -dest "/dirpath"
    description:
        -f: ansible config file 
        -h: group name of ansible operating hosts
        -t: file compress type
        -src: local file path
        -dest: dir path  of target hosts 
    --help | --h prints help screen
EOF
}

#检查上一个命令执行情况
function check_cmd() {
    if [ $? != 0 ]; then
        local_str=$1
        log_error "${local_str}"
        exit 1
    fi
}

function log_message(){
    message="`date +'%Y-%m-%d %H:%M:%S'`:  $1"
    echo -e "\033[32m ${message}\033[0m" >> transfer_file.log
    echo -e "\033[32m ${message}\033[0m"
}

function log_error() {
    message="`date +'%Y-%m-%d %H:%M:%S'` ERROR:  $1"
    echo -e "\033[31m ${message}\033[0m" >> transfer_file.log
    echo -e "\033[31m ${message}\033[0m"
    exit 1
}

function date_format(){
    echo $(date +'%Y%m%d%H%M%S')
}

function checkout_ansible() {
    if hash ansible 2>/dev/null; then
        log_message "ansible has installed!"
    else
        log_error "ansible has not installed!"
    fi
}

function checkout_param() {
    if [ ! -n "$2" ] || [[ "$2" =~ ^-+ ]];then
        log_error "after '-$1' must enter a right value"
    fi
}
#拷贝文件到远处
function ansible_unarchive_function() {
    
    local compress_type=$1
    local ansiblefile=$2
    local ansiblehost=$3
    local srcpath=$4
    local destpath=$5

    checkout_ansible

    if [[ -z ${ansiblehost} ]]; then
        #statements
        log_error "${ansiblehost} does not exists!"
    fi

    if [[ -z ${destpath} ]]; then
        #statements
        log_error "${destpath} does not exists!"
    fi

    if [ ! -f ${ansiblefile} ]; then
        #statements
        log_error "${ansiblefile} does not exists!"
    fi

    if [ ! -f ${srcpath} ]; then
        #statements
        log_error "${srcpath} does not exists!"
    fi
   
    if [[ ${compress_type} == "gz" ]]; then
        #创建远程文件夹
        ansible -i ${ansible_file} ${ansiblehost} -m file -a "path=${destpath} state=directory mode=0755"
        check_cmd "mkdir ${destpath} in remote hosts"
        #解压文件到远程目录
        ansible -i ${ansible_file} ${ansiblehost} -m unarchive  -a "src=${srcpath} dest=${destpath} mode=755"
        check_cmd "unarchive ${srcpath} ${destpath} in remote hosts"
        echo "gz"
    fi
    
    if [[ "${srcpath}" =~ sdk ]]; then
        soapa_sdk
    fi
    log_message "PATHPATH set success!"
}
#soapa sdk
function soapa_sdk() {
    #python
    local python_third_lib="/xxx/python/lib"
    #java
    local java_third_lib="/xxx/java/lib"
    #soapa python lib加入/etc/profile文件的PYTHONPATH环境变量中去
    ansible -i ${ansible_file} ${ansiblehost} -m lineinfile -a "dest=/etc/profile regexp='^export PYTHONPATH=' line='export PYTHONPATH=\$PYTHONPATH:${python_third_lib}' state=present"
    check_cmd "config /etc/profile PYTHONPATH=$PYTHONPATH:${python_third_lib}"
    #soapa java lib加入/etc/profile文件的CLASSPATH环境变量中去
    ansible -i ${ansible_file} ${ansiblehost} -m lineinfile -a "dest=/etc/profile regexp='^export CLASSPATH=' lineinfile -a "dest=/etc/profile regexp='^export CLASSPATH=' line='export CLASSPATH=\$CLASSPATH:${java_third_lib}' state=present"
    check_cmd "config /etc/profile CLASSPATH=$CLASSPATH:${java_third_lib}"
}

while [ -n "$1" ]; do
    #statements
    case "$1" in
        -f)
            checkout_param i $2
            ansible_file=$2
            log_message "ansible_file = ${ansible_file}"
            shift
            ;;
        -h)
            checkout_param h $2
            ansible_host=$2
            log_message "ansible_host = ${ansible_host}"
            shift 
            ;;
        -t)
            checkout_param t $2
            file_type=$2
            log_message "file_type = ${file_type}"
            shift
            ;;
        -src)
            checkout_param src $2
            src_path=$2
            log_message "src_path = ${src_path}"
            shift
            ;;
        -dest)
            checkout_param dest $2
            dest_path=$2
            log_message "dest_path = ${dest_path}"
            shift
            ;;
        --h | --help)
            usage
            exit 1
            ;;
        *)
            log_error "$1 is not defined"
            ;;
    esac
    shift
done

ansible_unarchive_function ${file_type} ${ansible_file} ${ansible_host} ${src_path} ${dest_path}
