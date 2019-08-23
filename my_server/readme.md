



# tmux 

Just a newsession:

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

kill session:

    tmux kill-session -t myname

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





` /bin/bash^M: bad interpreter:` 

` $ sed -i -e 's/^M$//' script.sh ` 
