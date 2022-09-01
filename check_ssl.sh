#!/bin/bash
export LANG="en_CN.UTF-8"
date="/usr/local/bin/gdate"
ssl_path="/Users/walterxue/Desktop/company/gitlab/certs"
token="eGy2fC3Ux2U0gDVvpFABZ6Jzd8S2nZxXn8u8bRkt7X3"


curl https://notify-api.line.me/api/notify -H "Authorization: Bearer ${token}" -d "message=domain ssl check start"
#for ssl in `find $ssl_path/* -name '*.crt'`
for ssl in `find /certs/* -name '*.crt'`
  do   
      # if
        domain=`ls $ssl | awk -F'/' '{print $3}'`
        end_time=$(echo | openssl x509 -enddate -noout -in $ssl | grep 'After' | awk -F '=' '{print $2}')
        end_timestamp=$(date +%s -d "$end_time")
        now_time=$(date +%s -d "`date`")
        expire_time=$(($(($end_timestamp-$now_time))/(60*60*24)))

        if [ $expire_time -lt "14" ] 
         then
             curl https://notify-api.line.me/api/notify -H "Authorization: Bearer ${token}" -d "message="$domain"到期日為 ${end_time},將在${expire_time}天後過期"
	     echo $domain >> /tmp/domain.txt 
        else
             echo "domain: $domain,證書到期時間:${end_time}, 剩餘天數${expire_time},It's OK!!" 
        fi

  done
      curl https://notify-api.line.me/api/notify -H "Authorization: Bearer ${token}" -d "message=domain ssl check done"


