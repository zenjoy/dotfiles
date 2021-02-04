# Only set this if we haven't set $EDITOR up somewhere else previously.
if [[ "$EDITOR" == "" ]] ; then
  # Use Visual Studio Code for my editor.
  export EDITOR='code'
fi

#export OPENFAAS_URL=https://fn.zenjoy.be