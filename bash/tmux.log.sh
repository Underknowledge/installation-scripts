#!/bin/sh 
session=$1

ssh_rh() {
tmux start-server
tmux new -d -s $session
tmux split-window -h 
tmux ls | grep -Fq $session && tmux send -t $session:0.0 "tail -f -n 50 /var/log/audit/audit.log| grep 'sshd'" C-m
tmux ls | grep -Fq $session && tmux send -t $session:0.1 "tail -f -n 50 /var/log/audit/audit.log" C-m
tmux a -t $session
}
ssh_deb() {
tmux start-server
tmux new -d -s $session
tmux split-window -h 
tmux ls | grep -Fq $session && tmux send -t $session:0.0 "tail -f -n 50 /var/log/auth.log| grep 'sshd'" C-m
tmux ls | grep -Fq $session && tmux send -t $session:0.1 "tail -f -n 50 /var/log/auth.log" C-m
tmux a -t $session
}

mail() {
tmux start-server
tmux new -d -s $session
tmux split-window -h 
tmux ls | grep -Fq $session && tmux send -t $session:0.0 "tail -f -n 50 /var/log/maillog" C-m
tmux ls | grep -Fq $session && tmux send -t $session:0.1 "tail -f -n 50 /var/log/messages" C-m
tmux a -t $session
}

kill() {
tmux kill-server
}

list() {
 tmux ls
}

case "$1" in
  mail)   mail ;;
  httpd)  httpd ;;
  ssh)    ssh_deb ;;
  ssh_rh)  ssh_rh ;;
  indico) indico;; 
  kill)   kill ;;
  list)   list ;;
  test)  test ;;
   *) echo "usage $0 indico|mail|ssh|ssh_rh|list|kill" >&2
      exit 1
      ;;
esac
