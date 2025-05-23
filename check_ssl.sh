#!/bin/bash
set -euo pipefail          # 建議加上嚴謹模式，方便除錯
export LANG=C              # 用 C/Posix locale，避免日期字串解析問題
export LANG="en_CN.UTF-8"
ssl_path="/certs"
bot_token="1882707925:AAFkhLbz45lZFrURcn_IQVsW8uNgfXrxbpo"
chat_id="999849909"
expire_domains_file="/tmp/expire_domains.txt"

# 先清空檔案
: > "$expire_domains_file"

# 傳送開始訊息
curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
     -d "chat_id=${chat_id}" \
     -d "text=Domain SSL check start"

# 改成以 ssl_path 為根目錄遞迴尋找 *.crt
find "$ssl_path" -type f -name '*.crt' | while read -r crt; do
  domain=$(basename "$crt" .crt)           # 直接取檔名去掉副檔名
  end_time=$(openssl x509 -in "$crt" -noout -enddate | cut -d= -f2)
  end_timestamp=$(date -d "$end_time" +%s) # ← 這裡把 -d 放前面
  now_timestamp=$(date +%s)
  expire_days=$(( (end_timestamp - now_timestamp) / 86400 ))

  if (( expire_days < 14 )); then         # 小於 14 天就通報
    curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
         -d "chat_id=${chat_id}" \
         -d "text=${domain} 的 SSL 將在 ${expire_days} 天後（${end_time}）過期"
    echo "$domain" >> "$expire_domains_file"
  else
    echo "domain: $domain, 證書到期：${end_time}, 剩餘 ${expire_days} 天，OK"
  fi
done

total_count=$(wc -l < "$expire_domains_file")
curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
     -d "chat_id=${chat_id}" \
     -d "text=Domain SSL check done，共有 ${total_count} 筆即將到期。"

# 若有名單才傳送檔案
if (( total_count > 0 )); then
  curl -s -F "chat_id=${chat_id}" \
       -F "document=@${expire_domains_file}" \
       "https://api.telegram.org/bot${bot_token}/sendDocument"
fi
