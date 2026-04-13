_dotfiles_docker_compose() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    docker compose "$@"
    return
  fi

  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
    return
  fi

  print -u2 -- "docker compose is unavailable"
  return 127
}

alias dco="_dotfiles_docker_compose"
alias dcb="_dotfiles_docker_compose build"
alias dce="_dotfiles_docker_compose exec"
alias dcps="_dotfiles_docker_compose ps"
alias dcrestart="_dotfiles_docker_compose restart"
alias dcrm="_dotfiles_docker_compose rm"
alias dcr="_dotfiles_docker_compose run"
alias dcstop="_dotfiles_docker_compose stop"
alias dcup="_dotfiles_docker_compose up"
alias dcupb="_dotfiles_docker_compose up --build"
alias dcupd="_dotfiles_docker_compose up -d"
alias dcdn="_dotfiles_docker_compose down"
alias dcl="_dotfiles_docker_compose logs"
alias dclf="_dotfiles_docker_compose logs -f"
alias dcpull="_dotfiles_docker_compose pull"
alias dcstart="_dotfiles_docker_compose start"
alias dck="_dotfiles_docker_compose kill"
