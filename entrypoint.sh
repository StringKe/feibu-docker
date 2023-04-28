#!/usr/bin/env bash
set -e

###
 # @Author: 胡勇超 huyongchao98@163.com
 # @Date: 2023-04-26 15:47:00
 # @LastEditors: 胡勇超 huyongchao98@163.com
 # @LastEditTime: 2023-04-27 21:29:23
 # @FilePath: /fireboom-server/entrypoint.sh
 # @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
### 

# 检测使用 pnpm yarn 还是 npm
# function detect_package_manager(){
#   pm=("pnpm" "yarn" "npm")
#   for i in ${pm[@]}
#   do
#     if type $i >/dev/null 2>&1; then
#       echo $i
#       return
#     fi
#   done
# }

# PM=$(detect_package_manager)


# echo "Staring node server..."
# echo '127.0.0.1 localhost.localdomain localhost' > /etc/hosts
# cd /app/custom-ts 
# $PM install
# $PM run watch &

while ! echo -e '\x1dclose' | nc localhost 9992 > /dev/null 2>&1
do
  echo " node server is not ready yet. Retrying in 5 seconds..."
  sleep 5
done
echo "node server is ready. Starting fireboom server..."
cd /app
./fireboom dev --host 0.0.0.0 &
wait
