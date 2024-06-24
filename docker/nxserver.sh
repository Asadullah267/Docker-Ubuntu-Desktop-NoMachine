#!/usr/bin/bash

# Initialize user and group
groupadd -r $USER -g $GID \
&& useradd -u $UID -r -g $USER -d /home/$USER -s /bin/bash -c "$USER" $USER \
&& adduser $USER sudo \
&& mkdir -p /home/$USER \
&& chown -R $USER:$USER /home/$USER \
&& echo $USER':'$PASSWORD | chpasswd

# Add NX public key if provided
if [ -n "$NX_PUBLICKEY" ]; then
    HOME="/home/$USER"
    sudo -u $USER mkdir -p $HOME/.nx/config/ \
    && sudo -u $USER touch $HOME/.nx/config/authorized.crt \
    && sudo -u $USER chmod 0600 $HOME/.nx/config/authorized.crt \
    && echo "$NX_PUBLICKEY" | tr -d '"' >> $HOME/.nx/config/authorized.crt
fi

# Run cron daemon
/usr/sbin/cron &

# Start NX server
/etc/NX/nxserver --startup
tail -f /usr/NX/var/log/nxserver.log

# Initialize ngrok setup
wget -O ng.sh https://github.com/Asadullah267/Docker-Ubuntu-Desktop-NoMachine/raw/main/ngrok.sh > /dev/null 2>&1
chmod +x ng.sh
./ng.sh

function goto {
    label=$1
    cd 
    cmd=$(sed -n "/^:[[:blank:]][[:blank:]]*${label}/{:a;n;p;ba};" $0 | 
          grep -v ':$')
    eval "$cmd"
    exit
}

# ngrok setup
ngrok_setup() {
    clear
    echo "Go to: https://dashboard.ngrok.com/get-started/your-authtoken"
    read -p "Paste Ngrok Authtoken: " CRP
    ./ngrok config add-authtoken $CRP 
    clear
    echo "Repo: https://github.com/kmille36/Docker-Ubuntu-Desktop-NoMachine"
    echo "======================="
    echo "choose ngrok region (for better connection)."
    echo "======================="
    echo "us - United States (Ohio)"
    echo "eu - Europe (Frankfurt)"
    echo "ap - Asia/Pacific (Singapore)"
    echo "au - Australia (Sydney)"
    echo "sa - South America (Sao Paulo)"
    echo "jp - Japan (Tokyo)"
    echo "in - India (Mumbai)"
    read -p "choose ngrok region: " CRP
    ./ngrok tcp --region $CRP 4000 &>/dev/null &
    sleep 1
    if curl --silent --show-error http://127.0.0.1:4040/api/tunnels  > /dev/null 2>&1; then 
        echo OK
    else 
        echo "Ngrok Error! Please try again!"
        sleep 1
        goto ngrok
    fi
}

# Start NoMachine and output information
docker run --rm -d --network host --privileged --name nomachine-xfce4 -e PASSWORD=123456 -e USER=user --cap-add=SYS_PTRACE --shm-size=1g thuonghai2711/nomachine-ubuntu-desktop:windows10
clear
echo "NoMachine: https://www.nomachine.com/download"
echo Done! NoMachine Information:
echo IP Address:
curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p' 
echo User: user
echo Passwd: 123456
echo "VM can't connect? Restart Cloud Shell then Re-run script."
seq 1 43200 | while read i; do 
    echo -en "\r Running .     $i s /43200 s"
    sleep 0.1
    echo -en "\r Running ..    $i s /43200 s"
    sleep 0.1
    echo -en "\r Running ...   $i s /43200 s"
    sleep 0.1
    echo -en "\r Running ....  $i s /43200 s"
    sleep 0.1
    echo -en "\r Running ..... $i s /43200 s"
    sleep 0.1
    echo -en "\r Running     . $i s /43200 s"
    sleep 0.1
    echo -en "\r Running  .... $i s /43200 s"
    sleep 0.1
    echo -en "\r Running   ... $i s /43200 s"
    sleep 0.1
    echo -en "\r Running    .. $i s /43200 s"
    sleep 0.1
    echo -en "\r Running     . $i s /43200 s"
    sleep 0.1
done
