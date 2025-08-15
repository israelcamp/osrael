# af-magic.zsh-theme
#
# Author: Andy Fleming
# URL: http://andyfleming.com/

# dashed separator size
function afmagic_dashes {
  # check either virtualenv or condaenv variables
  local python_env_dir="${VIRTUAL_ENV:-$CONDA_DEFAULT_ENV}"
  local python_env="${python_env_dir##*/}"

  # if there is a python virtual environment and it is displayed in
  # the prompt, account for it when returning the number of dashes
  if [[ -n "$python_env" && "$PS1" = *\(${python_env}\)* ]]; then
    echo $(( COLUMNS - ${#python_env} - 3 ))
  elif [[ -n "$VIRTUAL_ENV_PROMPT" && "$PS1" = *${VIRTUAL_ENV_PROMPT}* ]]; then
    echo $(( COLUMNS - ${#VIRTUAL_ENV_PROMPT} - 3 ))
  else
    echo $COLUMNS
  fi
}

setopt prompt_subst

# Path to your small icon (e.g., 2 cells wide, 1 cell tall works great)
PROMPT_ICON_PATH="${HOME}/osrael/zsh/themes/Rlogo.png"
PROMPT_ICON_ID=4242   # any positive integer; reused across prompts

# Print Kitty Graphics Protocol chunks (PNG, base64, chunked, direct)
_kgp_send_png() {
  local img="$1" id="$2" esc=$'\e'
  [[ -f $img ]] || return 0

  # send the PNG once per shell (cache flag)
  [[ -n ${__PROMPT_ICON_SENT-} ]] && return 0

  # base64 (portable: strip newlines)
  local b64; b64=$(base64 < "$img" | tr -d '\n')

  # kitty wants chunked transfers; 4K chunks are safe
  local i=1 L=${#b64}
  while (( i <= L )); do
    local j=$(( i + 4096 - 1 )); (( j > L )) && j=$L
    local more=$(( j < L ? 1 : 0 ))
    # a=t (transmit), f=100 (PNG), t=d (direct), i=<id>, m=<more>
    printf '%%{%s_Ga=t,q=1,f=100,t=d,i=%s,m=%d;%s%s\\%%}' \
      "$esc" "$id" "$more" "${b64[i,j]}" "$esc"
    i=$(( j + 1 ))
  done
  __PROMPT_ICON_SENT=1
}

# Place a 2x1-cell image at the cursor, without moving it; then advance 2 cells
kgp_prompt_icon() {
  local esc=$'\e'
  _kgp_send_png "$PROMPT_ICON_PATH" "$PROMPT_ICON_ID"
  # a=p (place), c=2 (cols), r=1 (rows), C=1 (don’t move cursor)
  printf '%%{%s_Ga=p,q=1,i=%s,c=2,r=1,C=1%s\\%%}' "$esc" "$PROMPT_ICON_ID" "$esc"
  printf '  '   # occupy those 2 cells so text starts after the icon
}


# primary prompt: dashed separator, directory and vcs info
PS1="${FG[237]}\${(l.\$(afmagic_dashes)..-.)}%{$reset_color%}
${FG[032]}$(kgp_prompt_icon) %~\$(git_prompt_info)\$(hg_prompt_info) ${FG[105]}%(!.#.»)%{$reset_color%} "
PS2="%{$fg[red]%}\ %{$reset_color%}"

# right prompt: return code, virtualenv and context (user@host)
RPS1="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
if (( $+functions[virtualenv_prompt_info] )); then
  RPS1+='$(virtualenv_prompt_info)'
fi
RPS1+=" ${FG[237]}%n@%m%{$reset_color%}"

# git settings
ZSH_THEME_GIT_PROMPT_PREFIX=" ${FG[075]}(${FG[078]}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="${FG[214]}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${FG[075]})%{$reset_color%}"

# hg settings
ZSH_THEME_HG_PROMPT_PREFIX=" ${FG[075]}(${FG[078]}"
ZSH_THEME_HG_PROMPT_CLEAN=""
ZSH_THEME_HG_PROMPT_DIRTY="${FG[214]}*%{$reset_color%}"
ZSH_THEME_HG_PROMPT_SUFFIX="${FG[075]})%{$reset_color%}"

# virtualenv settings
ZSH_THEME_VIRTUALENV_PREFIX=" ${FG[075]}["
ZSH_THEME_VIRTUALENV_SUFFIX="]%{$reset_color%}"
