#!/bin/zsh

function print_msg () {
    local level="$1"
    local message="$2"

    case "$level" in
        log)
            echo -e "\x1b[1m\x1b[32m\x1b[40m [B3AHEH/dotfiles]  \x1b[0m\x1b[1m\x1b[30m\x1b[42m ${message}\x1b[0m"
            ;;
        error)
            echo -e "\x1b[1m\x1b[31m\x1b[40m [B3AHEH/dotfiles] \x1b[0m\x1b[1m\x1b[30m\x1b[41m ${message}\x1b[0m"
            ;;
    esac
}
# Install xCode cli tools
print_msg "log" "Installing commandline tools..."
xcode-select --install

# Install Brew
print_msg "log" "Installing Brew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

# Brew Taps
print_msg "log" "Installing Brew Formulae..."
brew tap FelixKratz/formulae
brew tap koekeishiya/formulae

# Brew Formulae
brew install git
brew install mas
brew install neovim
brew install tree
brew install wget
brew install jq
brew install gh
brew install ripgrep
brew install rename
brew install bear
brew install neofetch
brew install ifstat
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install skhd
brew install yabai
brew install borders
brew install ranger
brew install sketchybar
brew install switchaudio-osx
brew install lazygit
brew install btop

# Brew Casks
print_msg "log" "Installing Brew Casks..."
brew install --cask monitorcontrol
brew install --cask sloth
brew install --cask skim
brew install --cask hex-fiend
brew install --cask font-hack-nerd-font
brew install --cask vlc

# Installing zsh
print_msg "log" "Installing Zsh..."
if ! command -v zsh &> /dev/null; then
    brew install zsh
fi

# Installing Oh My Zsh
print_msg "log" "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Installing Powerlevel10k
print_msg "log" "Installing Powerlevel10k theme..."
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
fi

# macOS Settings
print_msg "log" "Changing macOS defaults..."
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.spaces spans-displays -bool false
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock "mru-spaces" -bool "false"
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write com.apple.LaunchServices LSQuarantine -bool false
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain _HIHideMenuBar -bool true
defaults write NSGlobalDomain AppleHighlightColor -string "0.7961 0.6510 0.9686"
defaults write NSGlobalDomain AppleAccentColor -int 7
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.Finder AppleShowAllFiles -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder ShowStatusBar -bool false
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool YES
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

print_msg "log" "Installing configuration files..."
git clone --recurse-submodules git@github.com:B3AHEH/dotfiles.git $HOME/.dotfiles-temp

folders=("btop" "kitty" "neofetch" "nvim" "ranger" "sketchybar" "skhd" "yabai")

for folder in "${folders[@]}"; do
  target_dir="$HOME/.config/$folder"
  config_dir="$HOME/.config"
  if [ ! -d "$config_dir" ]; then 
    mkdir -p "$config_dir"
    print_msg "log" "Created directory: $config_dir"
  fi
  if [ -d "$HOME/.dotfiles-temp/$folder" ]; then
    if [ -d "$target_dir" ]; then
      mv "$target_dir" "${target_dir}.backup"
      print_msg "log" "Existing directory moved to backup: ${target_dir}.backup"
    fi

    mv "$HOME/.dotfiles-temp/$folder" "$target_dir"
    print_msg "log" "Moved: $folder"
  else
    print_msg "error" "Directory $folder does not exist in .dotfiles-temp."
  fi
done

if [ -f "$HOME/.zshrc" ]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi
mv "$HOME/.dotfiles-temp/.zshrc" "$HOME/.zshrc"

rm -rf "$HOME/.dotfiles-temp"
print_msg "log" "Directory: $HOME/.dotfiles-temp removed"

# Remving NeoVim cache
print_msg "log" "Removing NeoVim cache.."
if [ -d "$HOME/.local/share/nvim" ]; then 
  rm -rf "$HOME/.local/share/nvim"
fi

# Installing Fonts
git clone https://github.com/ryanoasis/nerd-fonts.git --depth 1 --filter=blob:none --sparse /tmp/Nerd_Fonts
cd /tmp/Nerd_Fonts
git sparse-checkout add patched-fonts/JetBrainsMono/Ligatures
cp -r patched-fonts/JetBrainsMono/Ligatures/* $HOME/Library/Fonts/
rm -rf /tmp/Nerd_Fonts

curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.4/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

source $HOME/.zshrc

# Start Services
print_msg "log" "Starting Services (grant permissions)..."
brew services start skhd
brew services start yabai
brew services start sketchybar

csrutil status
print_msg "log" "Add sudoer manually:\n '$(whoami) ALL = (root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | awk "{print \$1;}") $(which yabai) --load-sa' to '/private/etc/sudoers.d/yabai'"
print_msg "log" "Installation complete..."
