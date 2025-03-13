#!/bin/bash
export LANG="en_CN.UTF-8"
ssl_path="/certs"
bot_token="1882707925:AAFkhLbz45lZFrURcn_IQVsW8uNgfXrxbpo"
chat_id="999849909"
expire_domains_file="/tmp/expire_domains.txt"

# Clear the content of expire_domains.txt
echo > $expire_domains_file

# Send start message to Telegram
curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" -d "chat_id=${chat_id}" -d "text=Domain SSL check start"

for ssl in `find $ssl_path/* -name '*.crt'`
do
  domain=`ls $ssl | awk -F'/' '{print $3}'`
  end_time=$(echo | openssl x509 -enddate -noout -in $ssl | grep 'After' | awk -F '=' '{print $2}')
  end_timestamp=$(date +%s -d "$end_time")
  now_time=$(date +%s -d "`date`")
  expire_time=$(($(($end_timestamp-$now_time))/(60*60*24)))

  if [ $expire_time -lt "20" ]; then
    curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" -d "chat_id=${chat_id}" -d "text=${domain} 到期日為 ${end_time}, 將在 ${expire_time} 天後過期"
    echo "$domain" >> $expire_domains_file
  else
    echo "domain: $domain, 證書到期時間: ${end_time}, 剩餘天數 ${expire_time}, It's OK!!"
  fi
done

total_count=`cat $expire_domains_file | wc -l`
curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" -d "chat_id=${chat_id}" -d "text=Domain SSL check done, 預計到期憑證總共有 ${total_count} 筆."

# Send the expire_domains.txt file via Telegram
curl -s -F "chat_id=${chat_id}" -F "document=@${expire_domains_file}" "https://api.telegram.org/bot${bot_token}/sendDocument"
