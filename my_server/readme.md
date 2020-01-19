
# Hassio walkthrough on Debian 
``` 
sudo -i
wget https://github.com/Underknowledge/installation-scripts/raw/master/my_server/DEBIAN_static_ip.sh 
vi DEBIAN_static_ip.sh 
bash DEBIAN_static_ip.sh 
# log back in with the new ip 
reboot

sudo -i
apt-get update
apt-get install -y apparmor-utils apt-transport-https avahi-daemon ca-certificates curl dbus jq network-manager socat software-properties-common
curl -sSL https://get.docker.com | sh
systemctl disable ModemManager
apt-get purge modemmanager
curl -sL "https://raw.githubusercontent.com/home-assistant/hassio-installer/master/hassio_install.sh" | bash -s

mkdir ~/.ssh
touch .ssh/authorized_keys
echo "****CONTENT_PUBLIC_KEY*****" >> ~/.ssh/authorized_keys
wget https://raw.githubusercontent.com/Underknowledge/installation-scripts/master/pi-zero/initial_setup/enable-ssh-keys.sh
bash enable-ssh-keys.sh
``` 


# curl to download 

    sudo curl <URL> -o <filename>

# tmux 

Just a new session:

    tmux
    
attach to this new one:
(a flag like at, or attach)

    tmux a -t 0
    
or with name:

    tmux new -s docker
    
    tmux a -t docker
    
    tmux kill-session -t docker
    
    
list:

    tmux ls

hit `ctrl+b` and then:

## Sessions

    s  list sessions
    $  name the session

## Tabs

    c           new
    p           previous 
    n           next
    ,           name
    w           list
    f           find
    &           kill
    .           move


## Split

    %  horizontal split
    "  vertical split
    
    o  swap panes
    q  show pane numbers
    x  kill pane
    space - toggle layouts
    
## Misc

    d  detach
    ?  list shortcuts
    t  big clock



# Docker/-Compose 
[Offical Documentation](https://docs.docker.com/compose/)

#### running containers -a for stopped

    docker ps

#### resource usage 

    docker stats
    
#### network check

    docker network inspect <network>

#### kill all running containers
    docker kill $(docker ps -q)

#### remove old containers
    docker ps -a | grep 'weeks ago' | awk '{print $1}' | xargs docker rm

#### remove stopped containers
    docker rm -v $(docker ps -a -q -f status=exited)

#### bashrc

    alias dockeryaml='sudo nano /opt/docker-compose.yml'
    alias dcp='docker-compose -f /opt/docker-compose.yml '
    alias dcpup='docker-compose -f /opt/docker-compose.yml --compatibility up -d'
    alias dcpull='docker-compose -f /opt/docker-compose.yml pull --parallel'
    alias dclogs='docker-compose -f /opt/docker-compose.yml logs -tf --tail="50" '
    alias dtail='docker logs -tf --tail="50" "$@"'
    


# Misc

    ` /bin/bash^M: bad interpreter:` 

    ` $ sed -i -e 's/^M$//' script.sh ` 
