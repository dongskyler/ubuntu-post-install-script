#!/bin/bash
#
# Author:
# Skyler Dong <skylerdong.com>
#
# Description:
# Script for installing essential programs on a freshly installed
# Ubuntu Desktop 20 (Focal Fossa)
#
# Repository:
# https://github.com/dongskyler/ubuntu-20-desktop-post-installation-script
#
# Copyright (c) 2020 Skyler Dong.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#

install_programs() {
  printf "\033c"
  printf "Updating apt package lists...\n"
  sudo apt update

  printf "\033c"
  printf "Installing cURL...\n"
  sudo apt install -y curl
  curl --version

  printf "\033c"
  printf "Installing Wget...\n"
  sudo apt install -y wget
  wget --version

  # Temporarily remove VirtualBox installation due to full-window
  # interactive dialogue complications (agree to terms)
  # printf "Installing VirtualBox...\n"
  # wget -qO- \
  # http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc \
  # | sudo apt-key add -
  # sudo bash -c \
  # 'printf "deb http://download.virtualbox.org/virtualbox/debian focal \
  # non-free contrib\n" >> /etc/apt/sources.list.d/virtualbox.org.list'
  # sudo apt update
  # sudo apt install -y virtualbox-6.1

  printf "\033c"
  printf "Upgrading all packages...\n"
  sudo apt upgrade -y

  printf "\033c"
  printf "Installing some dependencies...\n"
  sudo apt install -y \
    zlib1g-dev \
    build-essential \
    software-properties-common \
    sqlite3 \
    apt-transport-https \
    ca-certificates \
    python-dev-is-python2 \
    libssl-dev \
    libreadline-dev \
    libyaml-dev \
    libsqlite3-dev \
    libxml2-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    libffi-dev \
    dconf-cli \
    uuid-runtime

  printf "\033c"
  printf "Installing Git...\n"
  sudo apt install -y git

  printf "\033c"
  printf "Installing GnuPG...\n"
  sudo apt install -y \
    gnupg \
    gnupg-agent

  printf "\033c"
  printf "Installing Vim...\n"
  sudo apt install -y vim

  printf "\033c"
  printf "Installing ELinks...\n"
  sudo apt install -y elinks

  printf "\033c"
  printf "Installing PulseAudio and PavuControl...\n"
  sudo apt install -y \
    pulseaudio \
    pavucontrol

  printf "\033c"
  printf "Installing Flameshot...\n"
  sudo apt install -y flameshot

  printf "\033c"
  printf "Installing ClamAV and ClamTK...\n"
  sudo apt install -y \
    clamav-daemon \
    clamtk

  printf "\033c"
  printf "Uninstalling Apache...\n"
  sudo systemctl stop apache2.service
  sudo systemctl disable apache2.service
  sudo apt purge -y apache2
  sudo apt autoremove -y
  sudo systemctl daemon-reload
  sudo systemctl reset-failed

  printf "\033c"
  printf "Installing Nginx...\n"
  sudo apt install -y nginx
  sudo systemctl start nginx.service
  sudo systemctl enable nginx.service

  printf "Creating an HTML test page..."
  printf "\
  <"'!'"DOCTYPE html>\n\
  <html>\n\
    <head>\n\
      <title>Test page</title>\n\
    </head>\n\
    <body>\
      Test page\n\
    </body>\n\
  </html>\n" \
    >>"$HOME/Sites/index.html"

  printf "\033c"
  printf "Installing PHP...\n"
  sudo apt install -y \
    php \
    php-fpm \
    php-mysql
  sudo systemctl start php7.4-fpm.service
  sudo systemctl enable php7.4-fpm.service
  sudo cp "$HOME/.ubuntu-post-installation/config/nginx/localhost.conf" \
    /etc/nginx/conf.d/
  sudo sed -i -e 's/USERNAME_PLACEHOLDER/'"$USER"'/g' \
    /etc/nginx/conf.d/localhost.conf
  sudo sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' \
    /etc/php/7.4/cli/php.ini
  sudo systemctl restart php7.4-fpm.service
  sudo systemctl restart nginx.service

  printf "Creating a PHP test page...\n"
  printf "<?php phpinfo(); ?>\n" \
    >>"$HOME/Sites/info.php"

  printf "\033c"
  printf "Installing MySQL...\n"
  sudo apt install -y mysql-server

  printf "\033c"
  printf "Installing MongoDB Community Edition...\n"
  wget -qO- https://www.mongodb.org/static/pgp/server-4.2.asc |
    sudo apt-key add -
  printf "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu \
bionic/mongodb-org/4.2 multiverse\n" |
    sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
  sudo apt update
  sudo apt install -y mongodb-org

  printf "\033c"
  printf "Installing ElasticSearch...\n"
  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch |
    sudo apt-key add -
  printf "deb https://artifacts.elastic.co/packages/7.x/apt stable main\n" |
    sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
  sudo apt update
  sudo apt install -y elasticsearch

  printf "\033c"
  printf "Installing Docker...\n"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
  sudo apt update
  sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io

  printf "\033c"
  printf "Installing Visual Studio Code...\n"
  curl https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor >packages.microsoft.gpg
  sudo install -o root -g root -m \
    644 packages.microsoft.gpg /usr/share/keyrings/
  sudo bash -c "printf \
  \"deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] \
  https://packages.microsoft.com/repos/vscode stable main\" \
  > /etc/apt/sources.list.d/vscode.list"
  sudo apt update
  sudo apt install -y code
  rm "$HOME/packages.microsoft.gpg"
  source "$HOME/.bashrc"

  printf "Installing Visual Studio Code extensions..."
  declare -a vscode_extensions
  vscode_extensions=(
    bmewburn.vscode-intelephense-client
    dsznajder.es7-react-js-snippets
    eamodio.gitlens
    esbenp.prettier-vscode
    foxundermoon.shell-format
    james-yu.latex-workshop
    jdforsythe.add-new-line-to-files
    ms-python.python
    sibiraj-s.vscode-scss-formatter
    visualstudioexptteam.vscodeintellicode
  )

  for ext in "${vscode_extensions[@]}"; do
    code --install-extension "$ext"
  done

  printf "\033c"
  printf "Installing Tor...\n"
  printf "deb https://deb.torproject.org/torproject.org bionic main\n" \
    >>/etc/apt/sources.list
  printf "deb-src https://deb.torproject.org/torproject.org bionic main\n" \
    >>/etc/apt/sources.list
  curl \
    https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc |
    gpg --import
  gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 |
    apt-key add -
  sudo apt update
  sudo apt install -y \
    tor \
    deb.torproject.org-keyring

  printf "\033c"
  printf "Installing Tor Browser...\n"
  sudo apt install -y torbrowser-launcher

  printf "\033c"
  printf "Installing Google Chrome...\n"
  wget \
    https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    -P "$HOME/Downloads/"
  sudo apt install -y "$HOME/Downloads/google-chrome-stable_current_amd64.deb"
  rm "$HOME/Downloads/google-chrome-stable_current_amd64.deb"

  printf "\033c"
  printf "Installing Slack...\n"
  wget \
    https://downloads.slack-edge.com/linux_releases/slack-desktop-4.4.3-amd64.deb \
    -P "$HOME/Downloads/"
  sudo apt install -y "$HOME/Downloads/slack-desktop-4.4.3-amd64.deb"
  rm "$HOME/Downloads/slack-desktop-4.4.3-amd64.deb"

  printf "\033c"
  printf "Installing Skype...\n"
  wget https://go.skype.com/skypeforlinux-64.deb -P "$HOME/Downloads/"
  sudo apt install -y "$HOME/Downloads/skypeforlinux-64.deb"
  rm "$HOME/Downloads/skypeforlinux-64.deb"

  printf "\033c"
  printf "Installing Zoom...\n"
  wget https://zoom.us/client/latest/zoom_amd64.deb -P "$HOME/Downloads/"
  sudo apt install -y "$HOME/Downloads/zoom_amd64.deb"
  rm "$HOME/Downloads/zoom_amd64.deb"

  printf "\033c"
  printf "Installing Python 3...\n"
  sudo apt install -y python3-pip

  printf "\033c"
  printf "Installing virtualenv via pip3...\n"
  yes | sudo pip3 install \
    virtualenv \
    virtualenvwrapper
  export WORKON_HOME="$HOME/.virtualenvs"
  mkdir -p $WORKON_HOME
  printf \
    "VIRTUALENVWRAPPER_PYTHON='/usr/bin/python3'\n\
source /usr/local/bin/virtualenvwrapper.sh\n" \
    >>"$HOME/.bashrc"
  source "$HOME/.bashrc"

  printf "\033c"
  printf "Creating a Python virtual environment for Jupyter Notebook \
called 'jupyter'.\n"
  mkvirtualenv jupyter

  printf "Installing Jupyter Notebook, numpy, pandas and matplotlib, \
inside 'jupyter' virtual environment.\n"
  workon jupyter
  yes | sudo pip3 install -U \
    notebook \
    numpy \
    pandas \
    matplotlib
  deactivate jupyter

  printf "\033c"
  printf "Installing Node Version Manager...\n"
  curl -o- \
    https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] &&
    printf %s "${HOME}/.nvm" ||
    printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  source "$HOME/.bashrc"
  command -v nvm

  printf "\033c"
  printf "Installing Node.js and Node Package Manager...\n"
  nvm install node
  node --version
  npm --version

  printf "\033c"
  printf "Installing Yarn...\n"
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg |
    sudo apt-key add -
  printf "deb https://dl.yarnpkg.com/debian/ stable main\n" |
    sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt update
  sudo apt install -y --no-install-recommends yarn
  export PATH="$PATH:/opt/yarn-[version]/bin"
  export PATH="$PATH:$(yarn global bin)"
  yarn --version

  printf "\033c"
  printf "Installing Ruby...\n"
  git clone https://github.com/rbenv/rbenv.git \
    "$HOME/.rbenv"
  printf 'export PATH="$HOME/.rbenv/bin:$PATH"\n' \
    >>"$HOME/.bashrc"
  printf 'eval "$(rbenv init -)"\n' \
    >>"$HOME/.bashrc"
  source "$HOME/.bashrc"
  git clone https://github.com/rbenv/ruby-build.git \
    "$HOME/.rbenv/plugins/ruby-build"
  printf 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"\n' \
    >>"$HOME/.bashrc"
  source "$HOME/.bashrc"
  rbenv install 2.7.1
  rbenv global 2.7.1
  ruby -v
  gem install bundler

  printf "\033c"
  printf "Installing Rails...\n"
  gem install rails -v 6.0.2.2
  rbenv rehash
  rails -v

  printf "\033c"
  printf "Installing TexLive... This could take a while.\n"
  sudo apt install -y texlive-full

  printf "\033c"
  printf "Installing Zsh...\n"
  sudo apt install -y zsh
  git clone https://github.com/robbyrussell/oh-my-zsh.git \
    "$HOME/.oh-my-zsh" \
    --depth 1
  cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" \
    "$HOME/.zshrc"

  printf "Set Zsh theme to 'bira'...\n"
  sed -i -e 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/g' "$HOME/.zshrc"

  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$HOME/.zsh-syntax-highlighting" \
    --depth 1
  printf 'source $HOME/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\n' \
    >>"$HOME/.zshrc"
}
