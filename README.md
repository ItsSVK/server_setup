# Server Setup

A modular, idempotent, and production-grade Bash script system to provision a fresh Ubuntu/Debian server. 

### Features

- **System Update**: Updates and upgrades all apt packages.
- **Essentials**: Installs `curl`, `wget`, `git`, `ufw`, `fail2ban`.
- **User Setup**: Creates a dedicated sudo user.
- **SSH Hardening**: Configures key-based auth and disables root/password logins.
- **Security Defaults**: Enables UFW (ports 22, 80, 443) and Fail2Ban SSH protection.
- **Docker**: Installs latest Docker CE and adds the user to the docker group.
- **Optimization**: provisions a 2GB swapfile and secures the root account.

### Usage

**Direct Execution (Curl / Wget)**
You can directly run `install.sh` via curl or wget. The script will automatically detect it's missing the `lib` and `steps` folders, clone the repository to a temporary directory, and execute itself:

---

### Essential Mode (Default)
By default, the script runs in **Essential Mode**. It only installs core utilities (curl, wget, git, firewall, basic security) and creates the user automatically to be as fast as possible.


### Using curl
```bash
curl -sL "https://raw.githubusercontent.com/ItsSVK/server_setup/refs/heads/main/install.sh" | sudo bash
```

### Using wget
```bash
wget -qO- "https://raw.githubusercontent.com/ItsSVK/server_setup/refs/heads/main/install.sh" | sudo bash
```
---

### Advanced Mode (Full Installation)
If you want the script to prompt you for advanced tools (like Docker and Nginx), pass the `-f` or `--full` argument.

### Using curl
```bash
curl -sL "https://raw.githubusercontent.com/ItsSVK/server_setup/refs/heads/main/install.sh" | sudo bash -s -- -f
```

# Local Script
```bash
sudo ./install.sh -f
```

*(Note: The setup intelligently checks if these advanced tools are already installed on your system. If `nginx` or `docker` is already present, their installation steps will be automatically skipped without any errors!)*

**Manual Clone**
```bash
git clone https://github.com/itssvk/server-setup.git
cd server-setup
sudo ./install.sh
```

### Extending

Each script inside `./steps/` is idempotent and loads dependencies from `./lib/`. You can edit, remove, or add new steps (`10_myapp.sh`) effortlessly.

---

### Contributing

We welcome contributions! Whether it's adding a new setup step, fixing a bug, or improving the documentation, your help is incredibly appreciated. Feel free to open an issue or submit a pull request to make server setups cleaner and easier for everyone.

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

<p align="center">
  <b>Created with ❤️ by Shouvik Mohanta</b>
</p>
