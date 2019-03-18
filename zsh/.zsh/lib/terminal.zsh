#
# Terminal Title
#

# Terminal title and tab color functions taken from
# https://github.com/dotphiles/dotzsh/blob/master/modules/terminal/init.zsh
function window-title() {
  printf '\e]2;%s\a' ${(V)argv}
}

function tab-title() {
  printf '\e]1;%s\a' ${(V)argv}
}

function tmux-title() {
  if [[ "$TERM" == screen* ]] || [[ ! -z $TMUX ]]; then
    printf '\033]2;%s\033\\' ${(V)argv}
  fi
}

function tab-color() {
  print "\033]6;1;bg;red;brightness;$1\a"
  print "\033]6;1;bg;green;brightness;$2\a"
  print "\033]6;1;bg;blue;brightness;$3\a"
}

function tab-reset() {
  print "\033]6;1;bg;*;default\a"
}

#
# Command Hooks
#

autoload -Uz add-zsh-hook

# Sets title before prompt is displayed
function set-title-precmd() {
  local suffix=${(V)argv[1]}
  suffix=${suffix:+ (${suffix})}

  local prefix=""
  if [[ ! -z $SSH_CONNECTION ]] && [[ -z $TMUX ]]; then
    prefix+="$(whoami)@${$(hostname)%%.*} "
  fi

  window-title "${prefix:- }${prefix:+$(spwd)${suffix}}"
  tab-title "${prefix}$(spwd)${suffix}"
  tmux-title "${prefix}$(spwd)${suffix}" 
}

add-zsh-hook precmd set-title-precmd

# Set title before command execution
function set-title-with-command() {
  emulate -L zsh
  setopt EXTENDED_GLOB

  # Get the command name that is under job control.
  if [[ "${2[(w)1]}" == (fg|%*)(\;|) ]]; then
    # Get the job name, and, if missing, set it to the default %+.
    local job_name="${${2[(wr)%*(\;|)]}:-%+}"

    # Make a local copy for use in the subshell.
    local -A jobtexts_from_parent_shell
    jobtexts_from_parent_shell=(${(kv)jobtexts})

    jobs "$job_name" 2>/dev/null > >(
      read index discarded
      # The index is already surrounded by brackets: [1].
      set-title-with-command "${(e):-\$jobtexts_from_parent_shell$index}"
    )
  else
    # Set the command name, or in the case of sudo or ssh, the next command.
    local cmd="${2[(wr)^(*=*|sudo|ssh|-*)]}"
    unset MATCH

    if [[ "$cmd" == "tmux" ]]; then
      set-title-precmd
    else
      set-title-precmd "$cmd"
    fi
  fi
}
add-zsh-hook preexec set-title-with-command
