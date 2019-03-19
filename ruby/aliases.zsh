alias migrate='rake db:migrate'

alias b="bundle"
alias bi="b install"
alias bu="b update"
alias be="b exec"
alias rake='noglob rake'

alias pt='papertrail -d 1 '
alias powr='powder restart'
alias powa='powder applog'
alias powl='powder log'

alias mc="open http://localhost:1080"
alias mcs="mailcatcher --growl -b"

alias dcrc="docker-compose run --rm app bundle exec rails console"
alias dcerc="docker exec -it nimbu-app bundle exec rails c"
alias dcrt="docker-compose run --rm app bundle exec spring rspec"
alias dcert="docker exec -it nimbu-app bundle exec spring rspec"
alias dceguard="docker exec -it nimbu-app bundle exec guard"
