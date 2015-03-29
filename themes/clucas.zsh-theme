#!/usr/bin/env zsh
#

# good resources:
# http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
# http://ruderich.org/simon/config/zshrc

# Use colorized output, necessary for prompts and completions.
autoload -Uz colors; colors

# Some shortcuts for colors. The %{...%} tells zsh that the data in between
# doesn't need any space, necessary for correct prompt drawing.
local red="%{${fg[red]}%}"
local blue="%{${fg[blue]}%}"
local blue_bold="%{${fg_bold[blue]}%}"
local green="%{${fg[green]}%}"
local green_bold="%{${fg_bold[green]}%}"
local yellow="%{${fg[yellow]}%}"
local yellow_bg="%{${bg[yellow]}%}"
local yellow_bold="%{${fg_bold[yellow]}%}"
#local default="%{${fg[default]}%}"
local black="%{${fg[black]}%}"
local default_color="%{$reset_color%}"

# use extended color pallete if available
# see http://pln.jonas.me/xterm-colors for values
if [[ $TERM = *256color* || $TERM = *rxvt* ]]; then
    local turquoise="%{%F{81}%}"
    #orange="%F{166}"
    local orange="%{%F{214}%}"
    local purple="%{%F{135}%}"
    local hotpink="%{%F{161}%}"
    local limegreen="%{%F{118}%}"
else
    local turquoise="$%{fg[cyan]%}"
    local orange="%{$fg[yellow]%}"
    local purple="%{$fg[magenta]%}"
    local hotpink="%{$fg[red]%}"
    local limegreen="%{$fg[green]%}"
fi

ZSH_THEME_GIT_PROMPT_PREFIX="$hotpink("
ZSH_THEME_GIT_PROMPT_SUFFIX="$hotpink)$default_color "
ZSH_THEME_GIT_PROMPT_DIRTY=" $yellow_bold✘$default_color"
ZSH_THEME_GIT_PROMPT_CLEAN=" $green_bold✔$default_color"

clucas_prompt_precmd() {
    # Regex to remove elements which take no space. Used to calculate the
    # width of the top prompt. Thanks to Bart's and Adam's prompt code in
    # Functions/Prompts/prompt_*_setup.
    local zero='%([BSUbfksu]|([FB]|){*})'

    # Setup. Create variables holding the formatted content.

    # Current directory in yellow, truncated if necessary (WIDTH is replaced
    # below).
    local directory="${yellow_bg}${black}%WIDTH<..<%~%<<${default_color}"

    # User name (%n) in bright green.
    local user="${limegreen}%B%n%b${default_color}"
    # Host name (%m) in bright green; underlined if running on a remote system
    # through SSH.
    local host="${limegreen}%B%m%b${default_color}"
    if [[ -n $SSH_CONNECTION ]]; then
        host="%U${host}%u"
    fi

    # Number of background processes in yellow if not zero.
    local background="%(1j. ${yellow}BG=%j${default_color}.)"
    # Exit code in bright red if not zero.
    local exitcode="%(?.. ${red}%BRC=%?%b${default_color})"
    # Prompt symbol, % for normal users, # in red for root.
    local symbol="%(!.${red}#${default_color}.%%)"

    # Prefix characters in first and second line.
    #local top_prefix="${blue}%B.-%b${default_color}"
    #local bottom_prefix="${blue}%B'%b${default_color}"
    local top_prefix=""
    local bottom_prefix=""

    # Combine them to create the prompt.
    # git info on top left
    local top_left=" $(git_prompt_info)"
    # time at top right 
    local top_right=" [%*]"

    local width_top_prefix=${#${(S%%)top_prefix//$~zero/}}
    local width_top_left=${#${(S%%)top_left//$~zero/}}
    local width_top_right=${#${(S%%)top_right//$~zero/}}

    # Calculate the maximum width of ${top_left}. -2 are the braces of
    # ${top_left}, -1 is one separator from ${top_separator} (we want at least
    # one between left and right parts).
    local top_left_width_max=$((
        COLUMNS - $width_top_prefix
                - $width_top_left 
                - 1
                - $width_top_right
    ))
    # Truncate directory if necessary.
    top_left="${directory/WIDTH/${top_left_width_max}}${top_left}"
    width_top_left=${#${(S%%)top_left//$~zero/}}

    # Calculate the width of the top prompt to fill the middle with "-".
    # wont work withou the extra -1
    local width=$((
        COLUMNS - width_top_prefix - width_top_left - width_top_right - 1
    ))
    #local top_separator="%B${blue}${(l:${width}::-:)}%b${default_color}"
    local top_separator="%B${blue}${(l:${width}::—:)}%b${default_color}"

    PROMPT="${top_prefix}${top_left}${top_separator}${top_right}
${bottom_prefix}${user}@${host} %h${background}${exitcode} ${symbol} "

}

precmd_functions+=(clucas_prompt_precmd)

