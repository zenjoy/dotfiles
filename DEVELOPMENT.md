# Development

To work on our dotfile, use Vagrant:

    % vagrant up

To check the script on older versions of bash:

```
sudo apt-get install build-essential byacc bison -y
mkdir ~/bash
cd ~/bash
wget http://ftp.gnu.org/gnu/bash/bash-3.2.57.tar.gz
tar xvzf bash-3.2.57.tar.gz
cd bash-3.2.57
./configure
make

export PATH="$HOME/bash/bash-3.2.57:$PATH"

# check that it is used
/usr/bin/env bash --version # should print 3.2.57

# enter the new bash
/usr/bin/env bash
```