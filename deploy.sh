#!/bin/bash

SLACK_TOKEN=$(cat SLACK_TOKEN)  # issue: https://api.slack.com/custom-integrations/legacy-tokens
SLACK_CHANNEL=isucon7-student
slack_post() {
    message="$(urlencode)"
    curl "https://slack.com/api/chat.postMessage?token=${SLACK_TOKEN}&channel=${SLACK_MESSAGE}&text=${message}"
}

echo '*DEPLOY BEGIN*' | slack_post

{
    echo '$ git rev-parse HEAD'
    git rev-parse HEAD
    echo '$ git diff'
    git diff
} |& tee /dev/tty | slack_post

{

# $ mysql -u isucon -D isuda --password=isucon
# mysql> CREATE TABLE `star` (
#   `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
#   `keyword` varchar(191) COLLATE utf8mb4_bin NOT NULL,
#   `user_name` varchar(191) COLLATE utf8mb4_bin NOT NULL,
#   `created_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`)
# ) ENGINE=InnoDB AUTO_INCREMENT=131 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
# mysql> alter table entry add length_keyword int(10) as (CHARACTER_LENGTH(keyword)) stored;
# mysql> alter table entry add index index_length_keyword (length_keyword);

scp -i id_rsa -P 2222 nginx.conf isucon@localhost:/home/isucon/nginx.conf
scp -i id_rsa -P 2222 isuda.py isucon@localhost:/home/isucon/webapp/python/isuda.py
scp -i id_rsa -P 2222 isutar.py isucon@localhost:/home/isucon/webapp/python/isutar.py
ssh -i id_rsa -p 2222 isucon@localhost '
sudo cp nginx.conf /etc/nginx/nginx.conf
sudo sh -c '\''rm -rf /var/cache/nginx/*'\''
sudo systemctl restart nginx
sudo systemctl restart mysql
sudo systemctl restart isuda.python
sudo systemctl restart isutar.python
sudo systemctl restart isupam
'

} |& tee /dev/tty | slack_post

echo '*DEPLOY END*' | slack_post
