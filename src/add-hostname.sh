HOSTNAME=$1

sudo hostnamectl set-hostname $HOSTNAME

sudo sed -i '' "/^127.0.0.1/ a\\
127.0.0.1 $HOSTNAME" /etc/hosts
sudo sh -c "echo $HOSTNAME > /etc/hostname"

echo "Hostname $HOSTNAME added."