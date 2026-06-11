# If you want to disable instant prompt, do it BEFORE sourcing p10k
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# (Optional) Instant prompt block: if you OFF it, you can remove this entirely.
# If you keep it, keep it at the very top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH="/eww/target/release:$PATH"
#keybinds
bindkey '^[[1;3D' beginning-of-line  # Alt + Left Arrow (Jump to Start)
bindkey '^[[1;3C' end-of-line        # Alt + Right Arrow (Jump to End)
bindkey '^[[1;5D' backward-word      # Ctrl + Left Arrow (Move back one word)
bindkey '^[[1;5C' forward-word       # Ctrl + Right Arrow (Move forward one word)
bindkey '^H' backward-kill-word      # Ctrl + Backspace (Delete word)


# fzf
eval "$(fzf --zsh)"

# thefuck (only once)
#eval "$(thefuck --alias fuck)"

# zoxide
eval "$(zoxide init zsh)"

# nvm (Optimized: Lazy-load)
nvm() {
    unset -f nvm node npm npx
    source /usr/share/nvm/init-nvm.sh
    nvm "$@"
}
node() {
    unset -f nvm node npm npx
    source /usr/share/nvm/init-nvm.sh
    node "$@"
}
npm() {
    unset -f nvm node npm npx
    source /usr/share/nvm/init-nvm.sh
    npm "$@"
}
npx() {
    unset -f nvm node npm npx
    source /usr/share/nvm/init-nvm.sh
    npx "$@"
}

# completion
autoload -Uz compinit && compinit

#plugins
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
export QT_QPA_FONTDIR=/usr/share/fonts

# powerlevel10k (ONLY ONCE)
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# aliases
alias ls="eza --color=always --long --git --icons=always"
alias speed="speedtest-cli"
alias spot="ncspot"
alias y="yazi"
alias cd="z"
alias ff="fastfetch"

# pokego only in interactive shells, and only once per session
if [[ -o interactive && -z "$FAST_RAN" ]]; then
  export FAST_RAN=1
  ff
fi
export PATH=$PATH:/home/mukes/.nvm/versions/node/v24.13.1
export PATH=$PATH:/home/mukes/.spicetify

#auto suggestion config
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

#auto completion config
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always --icons=always $realpath'
