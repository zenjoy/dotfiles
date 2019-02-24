# GRC colorizes nifty unix tools all over the place
if $(command -v grc &>/dev/null) && ! $(command -v brew &>/dev/null)
then
  source `brew --prefix`/etc/grc.bashrc
fi
