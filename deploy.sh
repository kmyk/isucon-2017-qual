#!/bin/bash

# SLACK_TOKEN=$(cat SLACK_TOKEN)  # issue: https://api.slack.com/custom-integrations/legacy-tokens
# SLACK_CHANNEL=isucon7-student
# slack_post() {
#     message="$(urlencode)"
#     curl "https://slack.com/api/chat.postMessage?token=${SLACK_TOKEN}&channel=${SLACK_MESSAGE}&text=${message}"
# }

echo '*DEPLOY BEGIN*'

{
    echo '$ git rev-parse HEAD'
    git rev-parse HEAD
    echo '$ git diff'
    git diff
}

web-server() {
    IP_ADDR="$1"
    IDENTITY="$2"

    # scp -i $IDENTITY -P 2222 nginx.conf isucon@$IP_ADDR:/home/isucon/nginx.conf
    # ssh -i $IDENTITY -p 2222 isucon@$IP_ADDR '
    # sudo cp nginx.conf /etc/nginx/nginx.conf
    # '
}

db-server() {
    IP_ADDR="$1"
    IDENTITY="$2"
}

# $ scp isucon@163.43.31.252:.ssh/id_rsa id_rsa.1
# $ scp isucon@163.43.29.226:.ssh/id_rsa id_rsa.2
# $ scp isucon@163.43.28.193:.ssh/id_rsa id_rsa.3
web-server 163.43.31.252 id_rsa.1
web-server 163.43.29.226 id_rsa.2
db-server  163.43.28.193 id_rsa.3

echo '*DEPLOY END*'
