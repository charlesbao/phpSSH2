#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
# install php-ssh2 for centos6 x32
#===============================================================================================
yum install -y php-devel php httpd openssl-devel gcc autoconf libtool libevent
wget http://www.libssh2.org/download/libssh2-1.5.0.tar.gz
tar -zxvf libssh2-1.5.0.tar.gz
cd libssh2-1.5.0
./configure --prefix=/usr/local/libssh2
make && make install
wget http://pecl.php.net/get/ssh2-0.12.tgz
tar -zxvf ssh2-0.12.tgz
cd ssh2-0.12
phpize
./configure --prefix=/usr/local/ssh2 --with-ssh2=/usr/local/libssh2
make
cp modules/ssh2.so /usr/lib/php/modules/
echo 'extension=ssh2.so' >> /etc/php.ini
read -n1 -p "Do you want to make a test? [y/n]?" answer
if [ $answer = "y" ]; then
echo ""
while [ "$password" = "" ];
do
    read  -s  -p "Enter your password:" password
	echo ""
done     
echo "your password has been written"
IP=$(curl -s -4 ipinfo.io | grep "ip" | awk -F\" '{print $4}')
read  -s  -p "Enter your IP(${IP}):" yourIP
if [ "$yourIP" = "" ]; then
        yourIP="${IP}"
fi
echo "${yourIP}"
port=$(netstat -ntlp | awk '!a[$NF]++ && $NF~/sshd$/{sub (".*:","",$4);print $4}')
read  -s  -p "Enter your Port(${port}):" yourport
if [ "$yourport" = "" ]; then
        yourport="${port}"
fi
echo "${yourport}"
cd
touch test.php
cat > test.php<<-EOF
<?php    
	\$user="root";
    \$pass="${password}";
    \$connection=ssh2_connect('${yourIP}',${yourport});
    ssh2_auth_password(\$connection,\$user,\$pass);
    \$cmd="ps aux";
    \$ret=ssh2_exec(\$connection,\$cmd);
    stream_set_blocking(\$ret, true);
    echo (stream_get_contents(\$ret));
?>
EOF
echo "running test.php"
echo "################################################################################"
php -f test.php
echo "################################################################################"
fi
echo ""
echo "Congratulations!ssh2 install completed!"
echo ""