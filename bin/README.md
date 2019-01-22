Verify 1password tool using gpg:

```
brew install gpg
gpg --keyserver hkp://$(host keys.gnupg.net | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1) --recv-keys 3FEF9748469ADBE15DA7CA80AC2D62742012EA22
gpg --verify op.sig op
```
