#xrdbify
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

#export gtk style to qt
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

#set wallpaper
eval $(cat ~/.fehbg)

#start redshiftgui
redshiftgui &

#start conky
#conky &

#start urxvt daemon
urxvtd &

#start wm
exec awesome

