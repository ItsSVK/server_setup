# Server Setup

A modular, idempotent, and production-grade Bash script system to provision a fresh Ubuntu/Debian server. 

### Features

- **System Update**: Updates and upgrades all apt packages.
- **Essentials**: Installs `curl`, `wget`, `git`, `ufw`, `fail2ban`, `nginx`.
- **User Setup**: Creates a dedicated sudo user.
- **SSH Hardening**: Configures key-based auth and disables root/password logins.
- **Security Defaults**: Enables UFW (ports 22, 80, 443) and Fail2Ban SSH protection.
- **Docker**: Installs latest Docker CE and adds the user to the docker group.
- **Optimization**: provisions a 2GB swapfile and secures the root account.

### Usage

**Direct Execution (Curl / Wget)**
You can directly run `install.sh` via curl or wget. The script will automatically detect it's missing the `lib` and `steps` folders, clone the repository to a temporary directory, and execute itself:

```bash
# Using Curl
curl -sL "https://raw.githubusercontent.com/ItsSVK/server_setup/refs/heads/main/install.sh" | sudo bash

# Using Wget
wget -qO- "https://raw.githubusercontent.com/ItsSVK/server_setup/refs/heads/main/install.sh" | sudo bash
```

**Manual Clone**
```bash
git clone https://github.com/itssvk/server-setup.git
cd server-setup
sudo ./install.sh
```

### Extending

Each script inside `./steps/` is idempotent and loads dependencies from `./lib/`. You can edit, remove, or add new steps (`10_myapp.sh`) effortlessly.
