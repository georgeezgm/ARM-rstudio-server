#!/bin/bash
# This script installs R and builds RStudio Desktop for ARM Chromebooks running debian stretch

# Install R; Debian stretch has latest version
sudo apt-get update
sudo apt-get install -y r-base r-base-dev
sudo apt-get install -y git
# Set RStudio version
#VERS=v0.99.473

# Download RStudio source
cd ~/Documents/
git clone https://github.com/georgeezgm/rstudio
cd rstudio

#wget -O $VERS https://github.com/rstudio/rstudio/tarball/$VERS
#mkdir ~/Downloads/rstudio-$VERS
#tar xvf ~/Downloads/$VERS -C ~/Downloads/rstudio-$VERS --strip-components 1
#rm ~/Downloads/$VERS

# Run environment preparation scripts
sudo apt-get install -y openjdk-11-jdk openjdk-11-jdk cmake qt6* qt5*
cd ~/Documents/rstudio/dependencies/linux/
./install-dependencies-debian --exclude-qt-sdk
./install-dependencies-jammy --exclude-qt-sdk


# Run common environment preparation scripts

# No arm build for pandoc, so install outside of common script
apt-get install -y pandoc
apt-get install -y libcurl4-openssl-dev

cd ~/Downloads/rstudio-$VERS/dependencies/common/
./install-common
./install-cef
./install-crashpad
./install-node
./install-npm-dependencies
./install-quarto
./install-dictionaries
./install-mathjax
./install-boost
./install-pandoc
./install-sentry-cli
./install-yaml-cpp
./install-yarn-linux-aarch64
./install-yarn
./install-packages

./install-soci
./install-boost

# Add pandoc folder to override build check
mkdir ~/Downloads/rstudio-$VERS/dependencies/common/pandoc

# Get Closure Compiler and replace compiler.jar
cd /home/jorge/rstudio
wget https://dl.google.com/closure-compiler/compiler-20200719.zip
unzip compiler-20200719.zip
rm compiler-20200719.zip
sudo mv closure-compiler*.jar /src/gwt/tools/compiler/compiler.jar

# Configure cmake and build RStudio
cd ~/Documents/rstudio/
mkdir build
sudo cmake -DRSTUDIO_TARGET=Server -DCMAKE_BUILD_TYPE=Release
sudo make install

# Additional install steps
sudo useradd -r rstudio-server
sudo cp /usr/local/extras/init.d/debian/rstudio-server /etc/init.d/rstudio-server
sudo chmod +x /etc/init.d/rstudio-server 
sudo ln -f -s /usr/local/bin/rstudio-server /usr/sbin/rstudio-server
sudo chmod 777 -R /usr/local/lib/R/site-library/
# Setup locale
sudo apt-get install -y locales
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
export LANG=es_ES.UTF-8
export LANGUAGE=es_ES.UTF-8
#echo 'export LANG=es_ES.UTF-8' >> ~/.bashrc
#echo 'export LANGUAGE=es_ES.UTF-8' >> ~/.bashrc

# Clean the system of packages used for building
sudo apt-get autoremove -y cabal-install ghc openjdk-7-jdk pandoc libboost-all-dev
sudo rm -r -f ~/Downloads/rstudio-$VERS
sudo apt-get autoremove -y

# Start the server
sudo rstudio-server start

# Go to localhost:8787
