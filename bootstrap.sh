#!/bin/zsh

set -e
set -o pipefail

helpFunction()
{
  echo ""
  echo "Usage: $0 -f"
  echo -e "\t-f Force install of everything"
  echo -e "\t-h show this help"
  exit 1 # Exit script after printing help
}

while getopts "f:h:" opt; do
  case "$opt" in
    f ) 
      forceInstall=true 
      echo "Force re-install"
      ;;
    h ) 
      helpFunction # Print helpFunction in case parameter is non-existent
      ;;
  esac
done

HOMEBREW_PATH="/opt/homebrew/bin/brew"
ANSIBLE_PATH="/opt/homebrew/bin/ansible"

# First install HomeBrew, we do this first so that Xcode command line tools are installed
# and we dont require some funky install script to do it quietly

if [ ! -f "$HOMEBREW_PATH" ] || [ "$forceInstall" = true ]; then
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  export PATH="/opt/homebrew/bin:$PATH"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' > ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo "Homebrew now installed!"
else
  echo "Homebrew seems to be installed already, to reinstall run bootstrap with -f"
fi

# Then we install Rosetta 2 if not intel mac
export processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string | grep -o "Intel")
if [[ -n "$processor" ]]; then
  echo "$processor processor installed. No need to install Rosetta."
else
# Check for Rosetta "oahd" process. If not found,
# perform a non-interactive install of Rosetta.
  if /usr/bin/pgrep oahd >/dev/null 2>&1; then
    echo "Rosetta is already installed and running. Nothing to do."
  else
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    if [[ $? -eq 0 ]]; then
      echo "Rosetta has been successfully installed."
    else
      echo "Rosetta installation failed!"
      exitcode=1
    fi
  fi
fi

# Update Pip to latest, this normally gives a warning that you are using out of
# date version once its update but thats fine.
echo "Updating Pip"
pip3 install --upgrade pip

if [ ! -f "$ANSIBLE_PATH" ] && [  ! "$forceInstall" = true ]; then
  echo "Installing Ansible"
  brew install ansible
  echo "Ansible now installed!"
elif [ "$forceInstall" = true ]; then
  echo "Reinstalling ansible"
  brew reinstall ansible
  echo "Ansible now installed!"
else
  echo "Ansible seems to be installed already, to reinstall run bootstrap with -f"
fi

if [ ! -d "/tmp/devops-mac-ansible" ] && [ ! "$forceInstall" = true ]; then
  cd /tmp
  echo "Clone ansible Playbook repo"
  git clone https://github.com/wonderphil/devops-mac-ansible.git
  cd /tmp/devops-mac-ansible
  echo "Installing requirements"
  ansible-galaxy install -r requirements.yml
  echo "requirements installed"
elif [ "$forceInstall" = true ]; then
  echo "Force install is active, re-downloading repo"
  cd /tmp
  rm -rf /tmp/devops-mac-ansible
  echo "Clone ansible Playbook repo"
  git clone https://github.com/wonderphil/devops-mac-ansible.git
  cd devops-mac-ansible
  echo "Installing requirements"
  ansible-galaxy install -r requirements.yml --force
  echo "requirements installed"
elif [ -d "/tmp/devops-mac-ansible" ]; then
  cd /tmp/devops-mac-ansible
  echo "Installing requirements"
  ansible-galaxy install -r requirements.yml --force
  echo "requirements installed"
fi

echo "cleaning up"
rm -rf /tmp/devops-mac-ansible
