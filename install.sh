#!/usr/bin/env bash
set -e

function get_os_name() {
  if [ "$(uname -s)" == "Darwin" ]; then
    os_name="mac"
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then   
    os_name="linux"
  elif [ "$(expr substr $(uname -s) 1 5)" == "MINGW" ]; then    
    os_name="windows"
  fi
}

get_os_name
cpu_arch=$(uname -m)

function get_os_bin_name() {
  ctl_filename="$1-${os_name}"
  if [ $os_name == 'windows' ]; then
    if [ $cpu_arch == 'arm64' ]; then
      ctl_filename="${ctl_filename}-${arch}.exe"
    else
      ctl_filename="${ctl_filename}.exe"
    fi
  else
    if [ $cpu_arch == 'arm64' ]; then
      ctl_filename="${ctl_filename}-${cpu_arch}"
    fi
  fi
}

function install_deps() {
  function detect_package_manager(){
    pm=("pnpm" "yarn" "npm")
    for i in ${pm[@]}
    do
      if type $i >/dev/null 2>&1; then
        echo $i
        return
      fi
    done
  }

  PM=$(detect_package_manager)

  echo "$PM Installing dependencies..."
  cd custom-ts
  $PM install
  cd ../
}

function download_fireboom() {
  echo "Downloading fireboom..."
  get_os_bin_name fireboom
  bin_url="https://fb-bin.oss-cn-hangzhou.aliyuncs.com/prod/${ctl_filename}.tar.gz"
  echo $bin_url
  curl -o ${ctl_filename}.tar.gz $bin_url
  tar -zxvf ${ctl_filename}.tar.gz -O > fireboom
  rm -rf ${ctl_filename}.tar.gz
  chmod +x fireboom
}

function init_project() {
  download_fireboom
  install_deps
  # 如果存在第一位参数跳过执行
  if [ $# -eq 0 ]; then
    echo "Starting fireboom server..."
    ./fireboom dev
  fi
}

function install() {
  if [ $# -eq 0 ]; then
    >&2 echo "Please specify the project name."
    exit 1
  else
    if [ -d "$1" ]; then
      echo "\"$1\" exist, please specify another project name."
      exit 2
    fi
    type git >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      if [ "$2" = "-t" ]; then
        if [[ $3 =~ ^https?:// ]]; then
          git clone $3 --depth=1 $1
        else
          git clone https://github.com/$3.git --depth=1 $1
        fi
      else
        git clone https://github.com/fireboomio/fb-init-simple.git --depth=1 $1
      fi
      cd $1
      rm -rf .git
      init_project $4
    else
      >&2 echo "Git command not found, Please follow https://git-scm.com/downloads to install"
      exit 3
    fi
  fi
}

install $1 $2 $3 $4