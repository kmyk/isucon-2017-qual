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

    for f in app.py setup.sh requirements.txt ; do
        scp -i $IDENTITY $f isucon@$IP_ADDR:isubata/webapp/python/$f
    done
    for f in etc/nginx/nginx.conf etc/nginx/sites-enabled/nginx.conf etc/systemd/system/isubata.python.service ; do
        scp -i $IDENTITY $f isucon@$IP_ADDR:$(basename $f)
        ssh -i $IDENTITY isucon@$IP_ADDR "sudo mv $(basename $f) /$f"
    done
    ssh -i $IDENTITY isucon@$IP_ADDR '
    sudo systemctl daemon-reload
    sudo systemctl restart nginx
    sudo systemctl restart isubata.python
    sudo sysctl -p
    '
}

db-server() {
    IP_ADDR="$1"
    IDENTITY="$2"

    for f in init.sh isubata.sql ; do
        scp -i $IDENTITY $f isucon@$IP_ADDR:isubata/db/$f
    done
    for f in etc/mysql/conf.d/mysql.cnf ; do
        scp -i $IDENTITY $f isucon@$IP_ADDR:$(basename $f)
        ssh -i $IDENTITY isucon@$IP_ADDR "sudo mv $(basename $f) /$f"
    done
    ssh -i $IDENTITY isucon@$IP_ADDR '
    sudo systemctl restart mysql
    sudo ./isubata/db/init.sh
    zcat ./isubata/db/isucon7q-initial-dataset.sql.gz | sudo mysql -D isubata --default-character-set=utf8mb4
    sudo sysctl -p
    '
}

# $ scp isucon@163.43.31.252:.ssh/id_rsa id_rsa.1
# $ scp isucon@163.43.29.226:.ssh/id_rsa id_rsa.2
# $ scp isucon@163.43.28.193:.ssh/id_rsa id_rsa.3
db-server  163.43.28.193 id_rsa.3
web-server 163.43.29.226 id_rsa.2
web-server 163.43.31.252 id_rsa.1

echo '*DEPLOY END*'
