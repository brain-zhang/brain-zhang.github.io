---
layout: post
title: "解决tmux下vim colorscheme失效的问题"
date: 2014-02-24 16:05:48 -0800
comments: true
categories:tmux, vim, colorscheme, color, config
---
在tmux(v1.6)默认配置下，vim的主题solarized, molokai等颜色设置都会失效

这是由于tmux term设置的问题。

需要在~/.bashrc中添加:
`alias tmux="TERM=screen-256color-bce tmux"`

再在~/.tmux.conf中添加:
`set -g default-terminal "xterm"`


如果是osx，可能在~/.bashrc要添加:
`alias tmux="TERM=screen-256color-bce tmux"`

在~/.tmux.conf中添加:
`set -g default-terminal "screen-256color"`

最后执行
`$ source ~/.bashrc`

就OK了。

参考:
http://stackoverflow.com/questions/10158508/lose-vim-colorscheme-in-tmux-mode
http://rhnh.net/2011/08/20/vim-and-tmux-on-osx
