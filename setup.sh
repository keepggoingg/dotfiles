#!/bin/bash

pacman -S --needed git base-devel

# Install yay
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin && makepkg -si

nmcli device wifi
nmcli device wifi connect "Hostel WiFi" password REDACTED
sudo systemctl enable sddm.service
yes | yay -S \
  # first
  vim \
  sddm \
  sddm-theme-tokyo-night \
  sway \
  waybar \
  swaylock-effects \
  swayidle \
  rofi-lbonn-wayland \

  # sway apps
  wl-clipboard \
  cliphist \
  shotman \
  pamixer \
  brightnessctl \
  avizo \
  dunst \
  swaykbdd \
  pavucontrol \
  network-manager-applet \
  wf-recorder \
  slurp \

  # utilities
  pinentry \
  gnupg \
  openssh \
  ntfs3 \
  bolt \
  glibc \
  lib32-glibc \
  lib32-zlib \ # multilib first!
  downgrade \
  freerdp \
  openresolv \
  postgresql \
  xorg-xwayland \
  browserpass \
  browserpass-chromium \
  android-file-transfer \
  xdg-desktop-portal-wlr \

  # KVM QEMU libvirt
  qemu-full \
  libvirt \
  dnsmasq \
  openbsd-netcat \
  virt-manager \

  # cli apps
  man-db \
  tldr \
  ranger \
  z.lua \
  bat \
  exa \
  fzf \
  direnv \
  ripgrep \
  htop \
  btop \
  pass \
  docker \
  docker-compose \
  openvpn \
  openvpn-update-resolv-conf-git \
  openfortivpn \

  # gui apps
  alacritty \
  kitty \
  neovim \
  thunar \
  feh \
  obsidian \
  chromium \
  slack-desktop-wayland \
  goland \
  datagrip \
  android-studio \
  reminna \
  remmina-plugin-anydesk-git \
  anydesk-bin \
  font-manager \
  postman-bin \
  nm-connection-editor \
  cpupower \
  cpupower-gui \


  # zsh
  zsh \
  tmux \
  # zsh-antidote \ # doesnt work

  # bluetooth
  bluez \
  bluez-utils \

  # appearance
  ttf-roboto-mono-nerd \
  ttf-jetbrains-mono-nerd \
  qogir-gtk-theme \
  dracula-gtk-theme \
  papirus-icon-theme-git \

  # programming
  go \
  npm \
  rust \
  dotnet-runtime \
  nodejs-lts-hydrogen \

  firebase-tools-bin \

  # texlive
  texlive-bin \
  texlive-latexextra \
  texlive-fontsextra \
  texlive-langeuropean \

  # java
  jre8-openjdk \
  jdk11-openjd \
  jre17-openjdk \

  # android
  android-emulator \
  android-platform \
  android-platform-28 \
  android-platform-29 \
  android-platform-30 \
  android-platform-31 \
  android-platform-33 \
  android-sdk-platform-tools \
  android-sdk-build-tools \
  android-sdk-build-tools-28.0.3 \
  android-sdk-build-tools-30.0.2 \
  android-sdk-build-tools-30.0.3 \
  android-sdk-cmdline-tools-latest

echo export EDITOR=nvim | sudo tee -a /etc/environment
echo export JAVA_HOME=/usr/lib/jvm/java-11-openjdk | sudo tee -a /etc/environment

DOTFILES_REPO="git@github.com:endo000/arch_dotfiles.git"
PASS_REPO="git@github.com:endo000/pass.git"
NVIM_REPO="git@github.com:endo000/nvim.git"
OBSIDIAN_REPO="git@github.com:endo000/obsidian.git"

git clone "$DOTFILES_REPO" ~/.config

git clone "$PASS_REPO" ~/.config/pass
echo "export PASSWORD_STORE_DIR=$HOME/.config/pass" >> ~/.bashrc
echo "export PASSWORD_STORE_DIR=$HOME/.config/pass" >> ~/.config/zsh/.zshenv

git clone "$NVIM_REPO" ~/.config/nvim
cp -r ~/.config/nvim/extensions/ ~/.local/share/nvim/lazy/

git clone "$OBSIDIAN_REPO" ~/.config/obsidian

mkdir -p ~/.config/vpn/result
cp ~/mnt/usb/result.ovpn ~/.config/vpn/result/result.ovpn

echo -ne "[Theme]\nCurrent=tokyo-night-sddm" | sudo tee /etc/sddm.conf.d/theme.conf
echo -ne "[General]\nDisplayServer=wayland\n[Wayland]\nCompositorCommand=sway" | sudo tee /etc/sddm.conf.d/10-wayland.conf

# Run chromium on Wayland
echo "--ozone-platform-hint=auto" >> ~/.config/chromium-flags.conf

# We use Alacritty's default Linux config directory as our storage location here.
mkdir -p ~/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes

mkdir -p ~/.config/alacritty/kitty-themes
git clone --depth 1 https://github.com/dexpota/kitty-themes.git ~/.config/kitty/kitty-themes
#
# first, run this from an interactive zsh terminal session:
git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.config/zsh/.antidote

mkdir -p ~/.config/tmux/oh-my-tmux
git clone https://github.com/gpakosz/.tmux.git ~/.config/tmux/oh-my-tmux
ln -s ~/.config/tmux/oh-my-tmux/.tmux.conf ~/.config/tmux/tmux.conf

# git clone --depth=1 https://github.com/adi1090x/rofi.git
# cd rofi && ./setup.sh

# mkdir -p ~/.local/share/rofi/themes/
# git clone https://github.com/lr-tech/rofi-themes-collection.git
# cd rofi-themes-collection && cp themes/* ~/.local/share/rofi/themes/

sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

mkdir -p ~/.config/systemd/user/
cat > ~/.config/systemd/user/mpris-proxy.service << EOL
[Unit]
Description=Forward bluetooth media controls to MPRIS

[Service]
Type=simple
ExecStart=/usr/bin/mpris-proxy

[Install]
WantedBy=default.target
EOL
systemctl --user start mpris-proxy.service
systemctl --user enable mpris-proxy.service


mkdir -p ~/.gnupg/
cat > ~/.gnupg/gpg-agent.conf << EOL
pinentry-program /usr/bin/pinentry-gnome3

max-cache-ttl 60480000
default-cache-ttl 60480000
EOL

# 2.5.8-2
sudo downgrade openvpn

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install gcc
brew tap leoafarias/fvm
brew install fvm

fvm install 2.5.3
fvm install 3.3.5

wget -O ~/dotnet-install.sh https://dot.net/v1/dotnet-install.sh
sudo ~/dotnet-install.sh --install-dir /usr/share/dotnet -channel STS -version latest
rm ~/dotnet-install.sh

sudo usermod -aG libvirt aleksandr
sudo systemctl enable --now libvirtd.service

sudo virsh net-autostart default
sudo virsh net-start default

sudo chown aleksandr:aleksandr /opt/android-sdk

sudo systemctl enable --now docker.service
sudo usermod -aG docker aleksandr
