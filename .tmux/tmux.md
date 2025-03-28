# *tmux* Terminal Multiplexer

*tmux* allows to create multiple terminal panes inside one (larger) window
and to switch between them.

<img src="https://backbeat.tech/img/tmux-work-2.png" width="600"/>

A good introduction into *tmux* is
[[1]](https://www.perl.com/article/an-introduction-to-tmux/).


&nbsp;
---
### Basic *tmux* Commands

Control inside *tmux* is initiated with a `Ctrl`-*prefix key* (`b` is default)
to toggle into command mode, e.g. to navigate panes. Letter `b` is often
mapped to `a` in *tmux* config file.

```
# create panes
Ctrl-b "        split pane horizontally
Ctrl-b %        split pane vertically

# navigate panes
Ctrl-b o        next pane
Ctrl-b ;        prior pane
Ctrl-b ←↑→↓     jump to pane
Ctrl-b q <n>	briefly show pane numbers, type number to select

# arrange panes
Ctrl-b Ctrl-o   swap panes
Ctrl-b space    arrange panes

# change panes
Ctrl-b-←↑→↓     change pane size
Ctrl-b !        pop a pane into a new window
```


&nbsp;
---
### *tmux* Control

*tmux* uses a concept of a *session*, which is an arrangement of *windows*
and *panes* a user has created to do some work.

*Sessions* are maintained by a *tmux server* that preserves session states.
Users can end sessions and reconnect (attach) to prior sessions.

The *tmux server* can be started and stopped with:

```sh
tmux start-server
tmux kill-server
tmux new-session ";" source-file ~/.tmux/default.conf

# show sessions
tmux ls                     # show sessions

tmux kill-session -t <n>    # end n-th session (close all attached windows)
tmux kill-session -a        # remove all sessions
```


&nbsp;
---
### References

- [1] David Farrell: [*An Introduction to Tmux*](https://www.perl.com/article/an-introduction-to-tmux/), (2016).

---
&nbsp;
