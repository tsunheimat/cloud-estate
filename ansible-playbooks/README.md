<h1 align="center">Ansible Playbooks</h1>
<p align="center">
    <em>Declare Configuration as Code</em>
</p>
<p align="center">
    <a href="https://t.me/pve_zh">
        <img src="https://img.shields.io/badge/join-us%20on%20proxmox%20group-gray.svg?longCache=true&logo=proxmox&colorB=orange" alt="join-us-on-proxmox-group"/>
    </a>
    <a href="https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html">
        <img src="https://img.shields.io/badge/ansible-playbooks-gray.svg?longCache=true&logo=ansible&colorB=red" alt="ansible-playbooks"/>
    </a>
    <a href="https://t.me/joinchat/7AG3aEQ5I00wY2Q5">
        <img src="https://img.shields.io/badge/join-us%20on%20telegram-gray.svg?longCache=true&logo=telegram&colorB=blue" alt="join-us-on-telegram"/>
    </a>
    <a href="https://github.com/TechProber/cloud-estate">
        <img src="https://img.shields.io/github/last-commit/TechProber/cloud-estate" alt="lastcommit"/>
    </a>
</p>

## Table of Contents

- [SSH Configuration](https://github.com/TechProber/cloud-estate/blob/master/playbooks/docs/ssh-configuration.md)
- [Components made up Ansible](#components-made-up-ansible)
- [Automation and Orchestration](#automation-and-orchestration)
- [Installation](#installation)
- [Playbook](#playbook)
- [Task](#task)
- [Tools](#tools)
- [Reference Links](#reference-links)

## Components made up Ansible

- `inventory` (list of devices that we will be controlling)
- `roles` (core components that define the automation tasks)
- `playbook` (automation task definition)
- `module` (pre-defined task template that can be called upon automation)
- `variable` (user-defined custom variables that can be injected to Ansible automation)
- `ansible.cfg` (modify default behavior and settings that Ansible uses)

## Project File Structure

```
./
├── ansible.cfg
├── docs
│   └── ssh-configuration.md
├── examples
│   └── encrypted_example.txt
├── inventory
│   ├── local.yml
│   ├── main.yml
│   ├── proxmox-lxc
│   └── proxmox.yml
├── playbooks
│   ├── apt
│   ├── container
│   ├── local-maintenance
│   ├── maintenance
│   ├── minio
│   ├── pacman
│   └── proxmox
├── README.md
├── requirements.yml
├── roles
│   ├── apt.ops
│   ├── containerd.ops
│   ├── containerd-rootless.ops
│   ├── docker.ops
│   ├── homebrew.ops
│   ├── lxc.ops
│   ├── maintenance.ops
│   ├── minio.ops
│   ├── pacman.ops
│   ├── proxmox.ops
│   └── proxmox.packer.vm.ops
├── scripts
│   ├── arch-update
│   ├── brew-bootstrap
│   ├── brew-update
│   └── gpg_vault_pass.sh
└── vars
    ├── kevin-proxmox-lxc.yml
    └── proxmox-lxc.yml
```

Notes:

- All the playbooks are stored under `./playbooks/`
- All the playable roles are stored under `./roles/`
- Sample inventory definition can be found under `./inventory/`

## Automation and Orchestration

- Automation refers to a single task
- Orchestration refers to the management of many automated tasks
- Often a complicated ordering with dependencies

## Installation

```bash
# osx
brew install ansible
# archlinux
sudo pacman -S ansible

# verify installation
ansible --version
```

## Playbook

#### Run a normal playbook against the default hosts

```bash
ansible-playbook [playbook path]
```

#### Run a playbook against an inventory list

```bash
ansible-playbook -i [inventory path] [role path]
```

#### Run a playbook against an inventory list but with limited host

```bash
ansible-playbook -i [inventory path] -l [limited hosts] [role path]
```

#### Run a pre-defined module against hosts

E.g. Run the ping module

```bash
ansible [hostfile path] -m ping
```

#### Run a task in dry-run mode - Ansible check

Check mode is just a simulation. It will not generate output for tasks that use conditionals based on registered variables (results of prior tasks). However, it is great for validating configuration management playbooks that run on one node at a time. To run a playbook in check mode:

```bash
ansible-playbook foo.yml --check
```

#### Run a task with sudo – Ansible become

sudo is to execute a task as a root user, in other words, we call it as privileged execution. If you want to execute a certain task as the root user using ansible just `become` is sufficient

Consider the following playbook where I want to install and restart the apache httpd server and I have used only the become method cause I know the default `become_user` is root and it does not have to be mentioned

```yaml
---
- name: Playbook
  ...
  become: yes
  ...
```

#### Ansible become with password

reference: https://www.middlewareinventory.com/blog/ansible-sudo-ansible-become-example/

Consider the same playbook given below for this the only difference we are going to do is passing the password as a parameter while invoking the playbook

How to pass the password as a parameter. ansible-playbook gives you to two options or parameters to pass while you are invoking the playbook

`-K` or `--ask-become-pass`

```bash
ansible-playbook -K [playbook path]
```

An alternative way to run playbook with `-e ansible_become_pass=$ANSIBLE_PASSWORD` but without the need to explicitly type `become` password

```bash
export $ANSIBLE_PASSOWRD=<become password goes here>
ansible-playbook \
  -e ansible_become_pass=$ANSIBLE_PASSWORD \
  [playbook path]
```

#### Enable verbose mode while running the playbook

To understand what is happening when you run the playbook, you can run it with the verbose `-v` option. Every extra v will provide the end-user with more debug output.

`-v` or `--verbose`

```bash
ansible-playbook -v [playbook path]
```

## Task

#### Execute a task if it caused a change

Set the `changed_when` parameter as `yes` as the following:

```yaml
changed_when: yes
```

#### Ensure all tasks must complete one one server before proceeding to the next server

Set the `serial` parameter to `1` as the following:

```yaml
serial: 1
```

#### Continuation of the play on a host

For Continuation of the play on a host, without waiting for other hosts, set the `strategy` parameters to the `free` option as the following:

```yaml
strategy: option
```

## Ansible Galaxy

#### Install a collection from Galaxy

reference: https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#installing-a-collection-from-galaxy

```bash
ansible-galaxy collection install community.general --upgrade
```

Alternatively you can include the collection in a `requirements.yml` file and then run `ansible-galaxy collection install -r requirements.yml --upgrade`. Here is an example of `requirements.yml` file:

```yaml
collections:
  - name: kewlfft.aur
  - name: community.general
```

## Tools

### Ansible Lint

```bash
# install with brew
brew install ansible-lint
# install with pip
pip install ansible-lint
# install with pacman
sudo pacman -S ansible-lint
# verify installation
ansible-lint --version
# linting
ansible-lint .
```

---

### Ansible Vault

#### Encryption/Decryption utility for Ansible data files

```bash
# prepare a secret key and write it to ~/.vault_key
echo "<your secret string>" > ~/.vault_key

# ecrypt a file with vault_key
ansible-vault encrypt --vault-password-file ~/.vault_key <target file>

# decrypt a file with vault_key
ansible-vault decrypt --vault-password-file ~/.vault_key <target file>

# edit an encrypted file without decryting it
ansible-vault edit --vault-password-file ~/.vault_key <target file>

# view an encrypted file without decryting it
ansible-vault view --vault-password-file ~/.vault_key <target file>
```

Notes: you may omit the `--vault-password-file` flag if you specify the location of the `vault_key` in `ansible.cfg`

```yaml
[defaults]
vault_password_file=~/.vault_key
```

#### Advanced encryption option with `GPG`

Reference: https://disjoint.ca/til/2016/12/14/encrypting-the-ansible-vault-passphrase-using-gpg/

One of the neat things you can do with `GPG` is encrypt your ansible-vault passphrase file. This works very nicely with hardware security keys such as `Yubikey`.

To start off, you will probably want to generate a new Vault passphrase and re-key all your already-encrypted Vault files.

##### Generate a complicated passphrase with `pwgen`

```bash
pwgen -n -s -y -c 32 -C | head -n1 | gpg --armor --recipient <your email identity> --encrypt --output ~/.vault_key.gpg
```

The above command will generate a `32` length of passphrase including numerical numbers, characters, and symbols. It will feed the `stdout` to gpg and output the encrypted passphrase to `~/.vault_key.gpg` using your `GPG private key` (stored in Yubikey)

To view that actual vault passphrase:

```bash
gpg --batch --use-agent --decrypt ~/.vault_key.gpg
```

Now that you have the new passphrase ready to go, re-key all your already-encrypted Vault files.

```bash
grep -rl '^$ANSIBLE_VAULT.*' . | xargs -t ansible-vault rekey
```

This command will ask you for the `old` and `new` vault passphrases and then attempt to re-key all the files that begin with the string `$ANSIBLE_VAULT` (usually indicative of an Ansible Vault encrypted file).

##### Create an executable file to make use of gpg decryption with your gpg private key

gpg_vault_pass.sh

```bash
#!/bin/sh
gpg --batch --use-agent --decrypt ~/.vault_key.gpg
```

Grant executable permission

```bash
chmod +x gpg_vault_pass.sh
```

##### Invoke ansible-vault manually and make sure that the re-keying worked as expected

```bash
ansible-vault --vault-password-file=gpg_vault_pass.sh view <target file>
```

Alternatively (recommended):

You could also make your life slightly easier by adding this to your `ansible.cfg`, in which case you could omit the `--vault-password-file` argument

```yaml
[defaults]
vault_password_file=gpg_vault_pass.sh
```

## Reference Links

- [Ansible Pre-baked Modules](https://docs.ansible.com/ansible/2.9/modules/modules_by_category.html)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [Ansible sudo – ansible become example](https://www.middlewareinventory.com/blog/ansible-sudo-ansible-become-example/)
- [Ansible AUR Module](https://github.com/kewlfft/ansible-aur)
