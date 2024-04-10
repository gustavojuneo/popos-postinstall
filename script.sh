#!/usr/bin/env bash

configure()
{
  echo "Deseja utilizar o homebrew para instalar os pacotes? (S/n)"

  read enable_homebrew;

  URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  URL_FISH_SHELL="https://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_12/amd64/fish_3.7.1-1_amd64.deb"
  URL_VS_CODE="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
  URL_WARP_TERMINAL="https://app.warp.dev/download?package=deb"

  URL_FISH_CONFIG="https://gist.githubusercontent.com/gustavojuneo/93a5439c59441bc4676664bd4c964128/raw/038dc956f565b752e29a16914310f5bddf8003c0/config.fish"

  URL_SWEET_THEME="https://github.com/EliverLara/Sweet/releases/download/v4.0/Sweet-Dark-v40.zip"
  URL_DRACULA_THEME="https://github.com/dracula/gtk/releases/download/v4.0.0/Dracula.tar.xz"
  URL_FLATERY_ICONS="https://github.com/cbrnix/Flatery.git"
  URL_MCMOJAVE_CURSORS="https://github.com/vinceliuice/McMojave-cursors.git"
  URL_JETBRAINS_MONO="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.0/JetBrainsMono.zip"

  DIRETORIO_DOWNLOADS="$HOME/Downloads/programas"

  PROGRAMAS_PARA_INSTALAR=(
    snapd
    guvcview
    gnome-tweaks
    flameshot
    libvulkan1
    libvulkan1:i386
    libgnutls30:i386
    libldap-2.4-2:i386
    libgpg-error0:i386
    libxml2:i386
    libasound2-plugins:i386
    libsdl2-2.0-0:i386
    libfreetype6:i386
    libdbus-1-3:i386
    libsqlite3-0:i386
    ttf-mscorefonts-installer
    ubuntu-restricted-extras
  )

  ## Removendo travas eventuais do apt ##
  sudo rm /var/lib/dpkg/lock-frontend
  sudo rm /var/cache/apt/archives/lock

  ## Adicionando/Confirmando arquitetura de 32 bits ##
  sudo dpkg --add-architecture i386

  ## Atualizando
  sudo apt update -y

  ## Download e instalaçao de programas externos ##
  mkdir "$DIRETORIO_DOWNLOADS"
  wget -c "$URL_GOOGLE_CHROME"       -P "$DIRETORIO_DOWNLOADS"
  wget -c "$URL_FISH_SHELL"       -P "$DIRETORIO_DOWNLOADS"
  wget -c "$URL_VS_CODE"       -P "$DIRETORIO_DOWNLOADS"
  wget -c "$URL_WARP_TERMINAL"       -P "$DIRETORIO_DOWNLOADS"

  ## Instalando pacotes .deb baixados na sessão anterior ##
  sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb

  # Instalar programas no apt
  for nome_do_programa in ${PROGRAMAS_PARA_INSTALAR[@]}; do
    if ! dpkg -l | grep -q $nome_do_programa; then # Só instala se já não estiver instalado
      apt install "$nome_do_programa" -y
    else
      echo "[INSTALADO] - $nome_do_programa"
    fi
  done

  ## Configurando o shell padrão

  mkdir -p ${HOME}/.config/fish
  wget ${URL_FISH_CONFIG} -O ${HOME}/.config/fish/config.fish

  chsh -s /usr/bin/fish

  Instalando Linux Homebrew
  if [ $enable_homebrew="S" ] || [ $enable_homebrew="s" ] || [ $enable_homebrew="" ]
  then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  ## Instalando pacotes Snap  ##
  sudo snap install spotify
  sudo snap install obsidian --classic

  # Instalando pacotes Homebrew
  brew install docker
  brew install gh
  brew install go
  brew install starship
  brew install n

  ## Download customizações gnome
  THEMES_FOLDER="$HOME/.themes"
  ICONS_FOLDER="$HOME/.icons"
  FONTS_FOLDER="$HOME/.fonts"
  TMP_FOLDER="$HOME/Downloads/tmp"
  mkdir -p ${THEMES_FOLDER}
  mkdir -p ${ICONS_FOLDER}
  mkdir -p ${FONTS_FOLDER}

  cd ${TMP_FOLDER}

  git clone ${URL_FLATERY_ICONS}
  mv Flatery/Flatery ${ICONS_FOLDER}

  wget -c ${URL_DRACULA_THEME}
  tar -xf Dracula.tar.xz
  mv Dracula ${THEMES_FOLDER}

  wget -c ${URL_SWEET_THEME}
  unzip Sweet-Dark-v40.zip
  mv Sweet-Dark ${THEMES_FOLDER}

  git clone ${URL_MCMOJAVE_CURSORS}
  cd McMojave-cursors
  mv dist McMojave-cursors
  mv McMojave-cursors ${ICONS_FOLDER}

  wget -c ${URL_JETBRAINS_MONO}
  unzip -d JetBrainsMono.zip JetBrainsMono
  mv JetBrainsMono ${FONTS_FOLDER}

  fc-cache -fv

  cd ${HOME}
  sudo rm -rf ${TMP_FOLDER}

  ## Configurando ambiente dev
  mkdir -p ${HOME}/www
  mkdir -p ${HOME}/www/projects
  mkdir -p ${HOME}/www/studies

  # ----------------------------- PÓS-INSTALAÇÃO ----------------------------- #
  ## Finalização, atualização e limpeza##
  sudo apt update && sudo apt dist-upgrade -y
  flatpak update
  brew autoremove
  sudo apt autoclean
  sudo apt autoremove -y
  # ---------------------------------------------------------------------- #
}

configure