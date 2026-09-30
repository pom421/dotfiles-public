# Machine "de formation" : Ubuntu 24.04 (comme au boulot), sans brew ni outils de confort.
# Seulement ce qu'on trouve sur un poste Ubuntu standard (vi, less, bash-completion) + stow.
FROM ubuntu:24.04

RUN apt-get update \
 && apt-get install -y --no-install-recommends bash zsh git make stow ca-certificates vim-tiny less bash-completion \
 && rm -rf /var/lib/apt/lists/*

# Utilisateur normal, avec le squelette Ubuntu (~/.bashrc, ~/.profile…)
# Terminal réaliste : sans TERM, git coupe la couleur (et donc interactive.diffFilter)
ENV TERM=xterm-256color

RUN useradd --create-home --shell /bin/bash tester
USER tester
WORKDIR /home/tester/dotfiles/dotfiles-public

COPY --chown=tester:tester . .

CMD ["bash", "tests/smoke.sh"]
