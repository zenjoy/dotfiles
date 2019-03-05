#!/usr/bin/env zsh

if [[ "`uname -s`" != "Darwin" ]]; then
  return
fi

function enable-touchid-sudo() {
  file=/etc/pam.d/sudo

  if grep -q "pam_tid.so" "$file"; then
    echo "Touch ID is already enabled for the sudo command. Enjoy!"
  else
    echo "Touch ID not enabled for sudo.. Please provide your password:"
    sudo bash -eu <<'EOF'
    # A backup file will be created with the pattern /etc/pam.d/sudo.backup.1
    # (where 1 is the number of backups, so that rerunning this doesn't make you lose your original)
    file=/etc/pam.d/sudo
    # suppress file not found errors
    # suppress file not found errors
    exec 2>/dev/null
    bak=$(dirname $file)/$(basename $file).backup.$(echo $(ls $(dirname $file)/$(basename $file).backup* | wc -l))
    cp $file $bak
    awk -v is_done='pam_tid' -v rule='auth       sufficient     pam_tid.so' '
    {
      # $1 is the first field
      # !~ means "does not match pattern"
      if($1 !~ /^#.*/){
        line_number_not_counting_comments++
      }
      # $0 is the whole line
      if(line_number_not_counting_comments==1 && $0 !~ is_done){
        print rule
      }
      print
    }' > $file < $bak
EOF
    echo "All done. Enjoy!"
  fi
}