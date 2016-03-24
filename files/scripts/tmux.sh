#!/bin/bash

if /usr/bin/tmux has-session 2>/dev/null
    then /usr/bin/tmux attach-session -d
else
    /usr/bin/tmux start-server
    /usr/bin/tmux new-session -d
    /usr/bin/tmux new-window -d
    /usr/bin/tmux new-window -d
    /usr/bin/tmux new-window -d
    /usr/bin/tmux split-window -t 1.0
    /usr/bin/tmux split-window -t 2.0

    /usr/bin/tmux rename-window -t 1 general
    /usr/bin/tmux rename-window -t 2 debug
    /usr/bin/tmux rename-window -t 3 command

    /usr/bin/tmux send-keys -t 1.0 "glances" Enter

    /usr/bin/tmux send-keys -t 1.1 "iftop" Enter
    sleep 0.5
    /usr/bin/tmux send-keys -t 1.1 t

    /usr/bin/tmux send-keys -t 2.0 "tail --follow=name --retry -n65535 /tmp/trader.log | egrep -v -e '^[A-Z]{3,8}: 2015-.*$' -e '^$'" Enter
    /usr/bin/tmux send-keys -t 2.1 "tail --follow=name --retry -n65535 /tmp/trader.log | egrep -A1 '__test_symbol_tick_(buy|sell)'" Enter


    /usr/bin/tmux send-keys -t 3.0 "nc -U /tmp/trader.sock" Enter
    sleep 0.5
    /usr/bin/tmux send-keys -t 3.0 "HELP" Enter

    /usr/bin/tmux attach-session -d
fi