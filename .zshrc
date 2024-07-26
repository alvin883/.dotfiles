# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  fancy-ctrl-z
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

# oh-my-zsh-theme called pure
PURE_PROMPT_SYMBOL="$"
fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure

# thefuck
eval $(thefuck --alias)

# my aliases
alias mydotfiles='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias gre="git restore"
alias lg="lazygit"
alias chat="cd ~/Documents/gpt4all/chat && ./gpt4all-lora-quantized-linux-x86"
alias h="hx ."
alias r="ranger"
alias t="tree"
alias dstop="sudo docker stop"
alias dlist="sudo docker ps -a"
alias dstart="sudo docker container run"

fixTsCache() {
  rm -rf node_modules/.cache
}

disableWebcamAutofocus(){
  v4l2-ctl -c focus_automatic_continuous=0
  v4l2-ctl -c focus_absolute=50
  # Decrease it into 50Hz, because the default is 2 which is 60Hz and somehow
  # camera got shutter horizontal line
  v4l2-ctl -c power_line_frequency=1
}

disableWebcamAutofocus1(){
  v4l2-ctl -d /dev/video1 -c focus_automatic_continuous=0
  v4l2-ctl -d /dev/video1 -c focus_absolute=50
  # Decrease it into 50Hz, because the default is 2 which is 60Hz and somehow
  # camera got shutter horizontal line
  v4l2-ctl -d /dev/video1 -c power_line_frequency=1
}

rebuildHelix() {
  cd ~/Documents/helix
  cargo install --force --locked --path helix-term
}

# Fuzzy filename & filecontent finder
# find-in-file - usage: fif <SEARCH_TERM>
fif() {
  if [ ! "$#" -gt 0 ]; then
    echo "Need a string to search for!";
    return 1;
  fi
  
  # explanation step:
  # - find string with ripgrep
  # - pass all the paths to fzf to be filtered
  # - remove trailing newline from fzf output
  # - copy the output into clipboard with xclip
  FIF_OUTPUT=$(rg --files-with-matches --no-messages --smart-case "$1" | fzf $FZF_PREVIEW_WINDOW --preview "rg --ignore-case --pretty --context 10 '$1' {}")
  echo $FIF_OUTPUT
  echo $FIF_OUTPUT | tr -d '\n' | xclip -sel clip
}

# Convert windows path into normal path and automatically copy-to-clipboard
# for example:
# winp "src\cursed\freakin\windows\path.rs"
# src/cursed/freakin/windows/path.rs
winp() {
  if [ ! "$#" -gt 0 ]; then
    echo "Need a path to be replaced!";
    return 1;
  fi

  echo $(echo $1 | sed 's|\\|/|g') | tr -d '\n' | xclip -sel clip
}

alias gitl="git log --date=relative --pretty=\"format:%C(auto,yellow)%h%C(auto,magenta)% G? %C(auto,blue)%>(12,trunc)%ad %C(auto,green)%<(9,trunc)%aN%C(auto,reset)%s%C(auto,red)%d%C(reset)\""

nfile() {
  if [ ! "$#" -gt 0 ]; then
    echo "Need a filepath to create!";
    return 1;
  fi

  mkdir -p "$(dirname "$1")" && touch "$1"
}

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# nvm end

# pnpm
export PNPM_HOME="/home/alvinnovian/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# FZF mappings and options
[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh

# Rust
. "$HOME/.cargo/env"

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# vnstat render
alias myv="sudo vnstati -m -o /home/alvinnovian/Documents/data-usage.png"

# deno
export DENO_INSTALL="/home/alvinnovian/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
# deno end

# Change FZF default backend with fd (fd-find)
export FZF_DEFAULT_COMMAND='fd --type file'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi"

source ~/Documents/my-bashes/create-component.sh

export HELIX_RUNTIME=~/Documents/helix/runtime

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='hx'
  export VISUAL='hx'
else
  export EDITOR='hx'
  export VISUAL='hx'
fi

export SUDO_EDITOR="$(which hx)"
export MANPAGER="bat -p -l man"

fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# bun completions
[ -s "/home/alvinnovian/.bun/_bun" ] && source "/home/alvinnovian/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bat catppuccin mocha
export BAT_THEME="Catppuccin-mocha"

# surrealdb
export PATH="/home/alvinnovian/.surrealdb:$PATH"

# My bashes (https://github.com/alvin883/my-bashes)
export PATH=$PATH:$HOME/Documents/my-bashes/

# Go lang
export PATH=$PATH:$HOME/go/bin

# GPG
# see: https://stackoverflow.com/a/55032706/6049731
# this will make sure that when using SSH, GPG modal will be opened in terminal
# instead of opening OS modal of the host
export GPG_TTY=$(tty)

# Android
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

MY_SESSION_TYPE='normal'

# Checking session type
if [[ -n $SSH_CONNECTION ]]; then
  MY_SESSION_TYPE='definitelyssh'
elif [[ $(ps -o comm= -p "$PPID") = 'wezterm-mux-ser' ]]; then
  MY_SESSION_TYPE='definitelyssh'
fi

# Auto-run ssh-agent on ssh login
if [[ $MY_SESSION_TYPE = 'definitelyssh' ]]; then
  echo "\n\nStarting ssh-agent and adding github key...";
  eval $(ssh-agent);
  ssh-add ~/.ssh/github_MyPcDailyDriver;
  echo "Agent started & added!\n";

  # Auto-kill ssh-agent on logout or exit
  trap 'test -n "$SSH_AGENT_PID" && eval `/usr/bin/ssh-agent -k`' 0
fi

# Resize video to 1280x720 with ffmpeg
# usage example: resizeVideoTo720p input.mkv output_720.mp4
resizeVideoTo720p() {
  if [ ! "$#" -gt 1 ]; then
    echo "Need two args, video name to be resized & it's output video name!";
    return 1;
  fi

  ffmpeg -i "$1" -filter:v scale=1280:-1 -c:a copy "$2"
}
