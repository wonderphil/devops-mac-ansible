
<img  src="https://raw.githubusercontent.com/wonderphil/devops-mac-ansible/main/files/Playbook-Logo.png"  width="250"  height="250"  alt="Mac Dev Playbook Logo"  />

# Mac DevOps Ansible Playbook




## Bootstrap and run playbook

First you need to copy the raw contents of bootstrap.sh to your local. You can't clone this repo inless xcode-command line tools are installed. Part of the bootstrap is to do that and to clone this repo. Of course if you have done some manual installs already and you can just clone and skip to the running of the playbook.

Bootstrap will install homebrew, which in turn installs xcode command line tools, which is required for git commands. This script will wipe out anything in **~/.zprofile** and **~/.zshrc**

After that it will install Rosetta 2 if Mac has apple silcon.

Next it will update pip and install ansible.  After this the script will download the repo and get anything in the requirements file (`requirements.yml`), then you are ready for running the playbook.

### Bootstrap

1. First create `~/repos` folder on you mac (this can be changed but some configs will need to be updated.
2. Run `/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/wonderphil/devops-mac-ansible/main/bootstrap.sh)"`

To download manaully and add force install:

1. download script: `curl -o ~/repos/bootstrap.sh https://raw.githubusercontent.com/wonderphil/devops-mac-ansible/main/bootstrap.sh`
2. Make it executable: `chmod +x ~/repos/bootstrap.sh`
3. Run script `./bootstrap.sh` or with force install enabled `./bootstrap.sh -f true`


### Ansible Vault

This playbook requires details that you may not want in plain text, so you must create a vault and add some data, follow below to setup correctly:

1. Create empty vault `ansible-vault create vars/mysecrets.yml`
2. When prompted add password
3. New Vault will open in default editor
4. Add the following, remembering that only add for the tasks you have enabled!

Vault template:

```yaml
ansible_become_password: <SOME PASSWORD>

# SSH Private keys that have been base64 encoded to make it easier to store
ssh_private_keys:
  - file_name: id_rsa
    base64_content: <Encoded by base64 ssh private key>

# Username and password for Apple App Store
mas_email: 
mas_password: 

gpg_private_keys:
  - email: <some email address>
    base64_key: <Encoded by base64 gpg private key pem>

```

To base64 encode something just do `echo 'something' | base64`

### Control Vars

This vars basically tell ansible if some task should be run or not and you should edit this for what ever you want or need:

* `default_configure_dock` - This allows ansible to configure the mac dock with your applications.

* `mas_installed_apps` - This can be an empty list `mas_installed_apps: []` but if list is pollulated, this uses a command line tool to install apps from the app store. **important you must of purchased this apps before and be apart of the apple account that you will be promted for! even if the app is free!**

* `ruby_dev_install` - Install everything thats needed for a ruby on rails dev work

* `python_dev_install` - Install everything thats needed for python dev work, this has a sub var called `install_mi` this will install the basics for AI/MI like anaconda

* `dotnet_dev_install`- Install everything thats needed for dotnet dev work

* `react_dev_install`- Install everything thats needed for react/nodejs dev work

* `config_git` - Configure git

* `gpg_config` - configure and install private keys

* `configure_shell` - this tells ansible which shell to configure, currently only zsh and oh-my-zsh is configured in this playbook, but you could as bash or any other you wish to use.

* `config_iterm` - this will configure iterm for you, if you have configurations and profiles you'd like to use, export them to `./files/iterm` and then ansible will configure iterm for you.


### Personal Configuration

Part of this playbook will do config that is different for everyone, make sure you go through all the options in the `./vars/default.config.yml` file!
Also make sure you go through the following and update with your details:

* `./files/git` - configure git profiles
* `./files/gpg` - configure gpg agent
* `./files/iterm` - configures iterm
* `./files/shell` - configures power10k theme for oh-my-zsh

* `./templates/zshrc.j2` - configures zshrc profile file
* `./templates/vs_settings.json.j2` - configures basic visual code setting, if you use code sync to sync you vscode settings to gist, then this needs updating with gist id
* `./templates/gitconfig_main.j2` - configure the main git config - best see `git_custom_config` and `git_custom_config_block` in `./vars/default.config.yml` for the config


## Run Playbook

*Make sure you have read through this readme and configured any changes you might want before playing this playbook*

1. You should of already run the bootstrap script
2. You should of already forked this repo into your personal github and cloned to your local
3. Run through all the configuration above
4. done a git add/commit and push to your repo
5. Then lastly you can run `ansible-playbook --ask-vault-pass -i inventory main.yml`



## TODO:

* create task to configure keyboard shortcuts
* make bootstrap and playbook configurable for repos folder
