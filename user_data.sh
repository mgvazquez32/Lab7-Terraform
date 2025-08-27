cat > user_data.sh <<'BASH'
#!/bin/bash
set -euxo pipefail

yum makecache -y || true
yum update -y || true
yum install -y httpd php mariadb unzip wget

wget -q https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-100-ACCLFO-2-102668/2-lab2-vpc/s3/lab-app.zip -O /tmp/lab-app.zip
unzip -o /tmp/lab-app.zip -d /var/www/html/

systemctl enable httpd
systemctl start  httpd
BASH
