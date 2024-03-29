#!/bin/bash

# Name:         slug (Set Up Laptop Gracefully)
# Version:      0.1.0
# Release:      1
# License:      CC-BA (Creative Commons By Attribution)
#               http://creativecommons.org/licenses/by/4.0/legalcode
# Group:        System
# Source:       N/A
# URL:          N/A
# Distribution: UNIX
# Vendor:       Lateral Blast
# Packager:     Richard Spindler <richard@lateralblast.com.au>
# Description:  Script to set up Mac

# Set up some version variables

RUBY_VERSION="2.6.3"
PYTHON_VERSION="3.7.3"

# Get the path the script starts from

app_file="$0"
app_path=$(dirname "$app_file")
app_base=$(basename "$app_file")

# Get the script info from the script itself

app_vers=$(grep "^# Version" "$0" |awk '{print $3}')
app_name=$(grep "^# Name" "$0" |awk '{for (i=3;i<=NF;++i) printf $i" "}' |sed 's/ $//g')
app_same=$(grep "^# Name" "$0" |awk '{print $3}')
app_pkgr=$(grep "^# Packager" "$0" |awk '{for (i=3;i<=NF;++i) printf $i" "}')
app_help=$(grep -A1 " [A-Z,a-z])$" "$0" |sed "s/[#,\-\-]//g" |sed '/^\s*$/d')

args=$@

# Install brew

install_brew () {
  if [ ! -e "/usr/local/bin/brew" ] ; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew doctor
  fi
  brew update
  brew upgrade
  #brew tap caskroom/cask
  brew tap homebrew/cask
}

update_brew () {
  brew update
  brew upgrade
}

# Make some dirs

if [ ! -d "$HOME/Code" ] ; then
  mkdir "$HOME/Code"
fi

# Setup bash and zsh environment

setup_shells () {
  touch "$HOME/.bashrc"
  if [ ! -e "$HOME/.bash_profile" ] ; then
    ln -s "$HOME/.bashrc" "$HOME/.bash_profile"
  fi
  for lib in openssl readline sqlite imagemagick@6 icu4c ncurses libffi ; do
    for line in "export CPPFLAGS=\"\$CPPFLAGS -I/usr/local/opt/$lib/include\"" \
      "export LDFLAGS=\"\$LDFLAGS -L/usr/local/opt/$lib/lib\"" \
      "export PKG_CONFIG_PATH=\"\$PKG_CONFIG_PATH:/usr/local/opt/$lib/lib/pkgconfig\"" \
      "export PATH=\"/usr/local/opt/$lib/bin:\$PATH\"" \
      "export PATH=\"/usr/local/opt/$lib/sbin:\$PATH\"" ; do
        if [ ! "`grep \"$line\" $HOME/.bashrc`" ]; then
          echo "$line" >> "$HOME/.bashrc" 
        fi
        if [ ! "`grep \"$line\" $HOME/.zshrc`" ]; then
          echo "$line" >> "$HOME/.zshrc" 
        fi
    done
  done
  for line in "export GOPATH=\"\$HOME/.go\"" \
    "export GOROOT=\"\$(brew --prefix golang)/libexec\"" \
    "export PATH=\"\$PATH:\$GOPATH/bin:\$GOROOT/bin\"" \
    "export PATH=\"/usr/local/bin:\$PATH\"" \
    "export PATH=\"/usr/local/sbin:\$PATH\"" \
    "eval \"\$(rbenv init -)\"" \
    "eval \"\$(pyenv init -)\"" ; do
      if [ ! "`grep \"$line\" $HOME/.bashrc`" ]; then
        echo "$line" >> "$HOME/.bashrc" 
      fi
      if [ ! "`grep \"$line\" $HOME/.zshrc`" ]; then
        echo "$line" >> "$HOME/.zshrc" 
      fi
  done

  for lib in openssl readline sqlite imagemagick@6 icu4c ncurses libffi ; do
    export LDFLAGS="$LDFLAGS -L/usr/local/opt/$lib/lib"
    export CPPFLAGS="$CPPFLAGS -I/usr/local/opt/$lib/include"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/opt/$lib/lib/pkgconfig"
    export PATH="/usr/local/opt/$lib/bin:$PATH"
    export PATH="/usr/local/opt/$lib/sbin:$PATH"
  done
  export PATH="/usr/local/bin:$PATH"
  export PATH="/usr/local/sbin:$PATH"
  export GOPATH="${HOME}/.go"
  export GOROOT="$(brew --prefix golang)/libexec"
  export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"
}

# Install packages via brew

install_brew_packages () {
  # Install some development tools from cask
  for pkg in phantomjs vagrant adoptopenjdk ; do
    brew cask install $pkg
  done
  # Install some programming tools
  for pkg in pyenv rbenv go npm git ant mercurial ; do
    brew install $pkg
  done
  # Install some general tools
  for pkg in mas git ansible amtterm awscli libiconv imagemagick@6 ffmpeg packer dockutil pwgen shellcheck ; do
    brew install $pkg
  done
  # Install some web and other tools
  for pkg in lftp wget geckodriver screen tmux c-kermit minicom ; do
    brew install $pkg
  done
}

# Set up ruby

setup_ruby () {
  # Setup rbenv
  if [ -e "/usr/local/bin/rbenv" ] ; then
    eval "$(rbenv init -)"
    if [ ! "`rbenv versions |grep \"$RUBY_VERSION\"`" ] ; then
      rbenv install $RUBY_VERSION  
      rbenv global $RUBY_VERSION
    fi
  fi
  # Install Ruby modules
  current=$(gem list)
  for module in versionomy rdoc mechanize selenium-webdriver phantomjs getopt builder \
    parseconfig netaddr json fileutils ssh-config nokogiri iconv hex_string \
    terminal-table unpack enumerate prawn prawn-table; do
    if [ ! "`echo \"$current\" |grep \"$module\"`" ] ; then
      gem install $module
    fi
  done
}

# Setup python

setup_python () {
  # Setup pyenv
  if [ -e "/usr/local/bin/pyenv" ] ; then
    eval "$(pyenv init -)"
    if [ ! "`pyenv versions |grep \"$PYTHON_VERSION\"`" ] ; then
      pyenv install $PYTHON_VERSION
      pyenv global $PYTHON_VERSION
    fi
  fi
  # Install Python modules
  current=$(pip list)
  pip install pip --upgrade
  for module in selenium bs4 npm; do
    if [ ! "`echo \"$current\" |grep \"$module\"`" ] ; then
      pip install $module
    fi
  done
}

# Set up go

setup_go () {
  go get golang.org/x/tools/cmd/godoc
  go get github.com/golang/lint/golint
}

# Install brew cask apps

install_brew_cask_packages () {
  # Install general apps
  brew_list=$(brew cask list)
  for pkg in iterm2 firefox zoom cyberduck whatsapp xquartz the-unarchiver slack spectacle transmission rcdefaultapp ; do
    if [ ! "`echo \"$brew_list\" |grep -i $pkg`" ] ; then
      brew cask install --appdir="/Applications" "$pkg"
    fi
  done
  # Install Microsoft apps
  for pkg in visual-studio-code microsoft-office skype ; do
    if [ ! "`echo \"$brew_list\" |grep -i $pkg`" ] ; then
      brew cask install --appdir="/Applications" "$pkg"
    fi
  done
  # Install Google apps
  for pkg in google-chrome mkchromecast ; do
    if [ ! "`echo \"$brew_list\" |grep -i $pkg`" ] ; then
      brew cask install --appdir="/Applications" "$pkg"
    fi
  done
  # Install Virtualisation apps
  for pkg in virtualbox virtualbox-extension-pack vmware-fusion docker ; do
    if [ ! "`echo \"$brew_list\" |grep -i $pkg`" ] ; then
      brew cask install --appdir="/Applications" "$pkg"
    fi
  done
}

# Install Google Noto font pack

install_google_noto_fonts () {
  if [ ! -e "/Library/Fonts/NotoColorEmoji.ttf" ] ; then
    if [ ! -e "$HOME/Noto-unhinted.zip" ] ; then
      cd "$HOME/Downloads" || exit
      curl -O https://noto-website-2.storage.googleapis.com/pkgs/Noto-unhinted.zip
    fi
    if [ ! -d "$HOME/Downloads/google-noto-fonts" ] ; then
      mkdir "$HOME/Downloads/google-noto-fonts"
      cd "$HOME/Downloads/google-noto-fonts" || exit 
      unzip -q "$HOME/Downloads/Noto-unhinted.zip"
    fi
    cd "$HOME/Downloads/google-noto-fonts" || exit
    cp ./*.ttf /Library/Fonts
    cd .. || exit
    rm -rf "$HOME/Downloads/google-noto-fonts"
  fi
}

# Install other packages not in brew, the App store, etc

install_others_packages () {
  # Install RDM
  if [ ! -d "/Applications/RDM.app" ] ; then
    cd "$HOME/Downloads" || exit
    if [ ! -e "$HOME/Downloads/RDM-2.2.pkg" ] ; then
      curl - O http://avi.alkalay.net/software/RDM/RDM-2.2.pkg
      sudo installer -pkg "$HOME/Downloads/RDM-2.2.pkg" -target /
    fi
  fi
}

# Install Applications from the Apps store

install_app_store_packages () {
  for pkg in Serial OmniGraffle wipr ; do 
    if [ ! -d "/Applications/$pkg.app" ] ; then
      mas install "$(mas search $pkg |head -1 |awk '{print $1}')"
    fi
  done
}

# Setup zsh

setup_zsh () {
  for pkg in zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting gnu-sed ; do
    brew install $pkg
  done
  for line in "fpath=(/usr/local/share/zsh-completions \$fpath)" \
    "source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
    "source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
    "export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters" ; do
    if [ ! "`grep \"$line\" $HOME/.zshrc`" ] ; then
      echo "$line" >> "$HOME/.zshrc"
    fi
  done
  # Install oh my zsh
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo Y |sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  fi
  # Install powerline fonts
  if [ ! -d "$HOME/Code/powerline-fonts" ] ; then
    cd "$HOME/Code" || exit
    git clone https://github.com/powerline/fonts.git powerline-fonts --depth=1
    cd powerline-fonts || exit
    ./install.sh
  fi
  if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ] ; then
    git clone https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
  fi
  gsed -ie 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' "$HOME/.zshrc"
}

# System defaults - Needs checking some of these no longer seem correct on updated Mac OS

setup_defaults () {
  # Increase window resize speed for Cocoa applications
  defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
  # Expand save panel by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
  # Expand print panel by default
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
  # Save to disk (not to iCloud) by default
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  # Check for software updates daily, not just once per week
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
  # Increase sound quality for Bluetooth headphones/headsets
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
  # Save screenshots to the Pictures/Screenshots
  mkdir "${HOME}/Pictures/Screenshots"
  defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
  # Disable shadow in screenshots
  defaults write com.apple.screencapture disable-shadow -bool true
  # Enable subpixel font rendering on non-Apple LCDs
  defaults write NSGlobalDomain AppleFontSmoothing -int 2
  # Finder: disable window animations and Get Info animations
  defaults write com.apple.finder DisableAllAnimations -bool true
  # Show icons for hard drives, servers, and removable media on the desktop
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
  # Finder: show path bar
  defaults write com.apple.finder ShowPathbar -bool true
  # Finder: allow text selection in Quick Look
  defaults write com.apple.finder QLEnableTextSelection -bool true
  # Disable the warning when changing a file extension
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  # Avoid creating .DS_Store files on network volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  # Transmission.app                                                            
  # Use "~/Documents/Torrents" to store incomplete downloads
  defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
  defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Documents/Torrents"
  # Don’t prompt for confirmation before downloading
  defaults write org.m0k.transmission DownloadAsk -bool false
  # Trash original torrent files
  defaults write org.m0k.transmission DeleteOriginalTorrent -bool true
  # Hide the donate message
  defaults write org.m0k.transmission WarningDonate -bool false
  # Hide the legal disclaimer
  defaults write org.m0k.transmission WarningLegal -bool false
  # Google Chrome & Google Chrome Canary   
  # Use the system-native print preview dialog
  defaults write com.google.Chrome DisablePrintPreview -bool true
  defaults write com.google.Chrome.canary DisablePrintPreview -bool true
  # Expand the print dialog by default
  defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
  defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true
  # Safari
  # Enable the Develop menu and the Web Inspector in Safari
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
  # Add a context menu item for showing the Web Inspector in web views
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
  # Prevent Safari from opening ‘safe’ files automatically after downloading
  defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
  # Show the full URL in the address bar (note: this still hides the scheme)
  defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
  # Press Tab to highlight each item on a web page
  defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true
  # Privacy: don’t send search queries to Apple
  defaults write com.apple.Safari UniversalSearchEnabled -bool false
  defaults write com.apple.Safari SuppressSearchSuggestions -bool true
  # Mission Control
  # Speed up Mission Control animations
  defaults write com.apple.dock expose-animation-duration -float 0.1
  # Show the ~/Library folder
  chflags nohidden "$HOME/Library"
  # Use list view in all Finder windows by default
  # Four-letter codes for the other view modes: "icnv", "clmv", "Flwv"
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
}

do_all () {
  install_brew
  update_brew
  setup_shells
  install_brew_packages
  setup_ruby
  setup_python
  setup_go
  install_app_store_packages
  setup_zsh
  setup_defaults
  install_brew_cask_packages
}

do_brew () {
  install_brew
  update_brew
  install_brew_packages
  install_brew_cask_packages
}

do_other_packages () {
  install_app_store_packages
  install_others_packages
}

do_shells () {
  setup_shells
  setup_zsh
}

do_ruby () {
  setup_ruby
}

do_python () {
  setup_python
}

do_go () {
  setup_go
}

# List packages

do_list_packages () {
  cat "$0" |grep pkg | grep "do$" |awk '{for(i=4;i<=NF-1;++i)print $i}'  |cut -f1 -d";" |tr ' ' '\n' |grep -v "^$" 
}

do_version () {
  echo "$app_vers"
}

# Install fonts

do_fonts () {
  install_google_noto_fonts
}

# Print some help

print_help() {
  echo "$app_name $app_vers"
  echo "$app_pkgr"
  echo ""
  echo "Usage Information:"
  echo ""
  echo "$app_help"
  echo ""
  return
}

# If given no command line arguments print usage information

if [ `expr "$args" : "\-"` != 1 ]; then
  print_help
  exit
fi

# Handle versions

while getopts ":abcfszrpdgVl" args ; do
  case $args in
    a)
      # Do everything
      do_all
      ;;
    b)
      # Install brew package
      do_brew
      ;;
    c)
      # Install brew cask packages
      install_brew_cask_packages
      ;;
    l)
      # List packages
      do_list_packages
      ;;
    f)
      # Install fonts
      do_fonts
      ;;
    s)
      # Install other packages
      do_other_packages
      ;;
    z)
      # Setup shells
      do_shells
      ;;
    r)
      # Install Ruby
      do_ruby
      ;;
    p)
      # Install Python
      do_python
      ;;
    d)
      # Set OS X defaults
      do_defaults
      ;;
    g)
      # Install go
      do_go
      ;;
    V)
      # Display version
      do_version
      ;;
    *)
      # Display help
      print_help
      ;;
  esac
done

