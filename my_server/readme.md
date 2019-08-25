



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



# Docker/-Compose https://docs.docker.com/compose/

##running containers -a for stopped

    docker ps

##resource usage 

    docker stats

## kill all running containers
    docker kill $(docker ps -q)

## remove old containers
    docker ps -a | grep 'weeks ago' | awk '{print $1}' | xargs docker rm

## remove stopped containers
    docker rm -v $(docker ps -a -q -f status=exited)

## bashrc

    alias dockeryaml='sudo nano /opt/docker-compose.yml'
    alias dcp='docker-compose -f /opt/docker-compose.yml '
    alias dcpup='docker-compose -f /opt/docker-compose.yml --compatibility up -d'
    alias dcpull='docker-compose -f /opt/docker-compose.yml pull --parallel'
    alias dclogs='docker-compose -f /opt/docker-compose.yml logs -tf --tail="50" '
    alias dtail='docker logs -tf --tail="50" "$@"'
    


# Misc

    ` /bin/bash^M: bad interpreter:` 

    ` $ sed -i -e 's/^M$//' script.sh ` 
