# Server Setup
Server Setup is a modular, production-grade Bash automation tool designed to provision a fresh Ubuntu or Debian server instantly. 

![Server Setup Demo](assets/server-setup.gif)

## 🤔 What problem does it solve?
Setting up a new server from scratch is highly repetitive, error-prone, and time-consuming. You typically have to manually run system updates, configure memory swap, lock down SSH, configure firewalls, and install basic dependencies every single time you deploy a new machine. 

## 🛠️ How does it work & make things easier?
This script completely automates the foundational setup of a new server. Instead of spending 30 minutes carefully copying and pasting commands, you can run a single line of code to get a fully secured, optimized, and developer-ready machine in minutes. 

It does this through an intelligent, modular system (`essentials` and `advanced` steps) that:
- Analyzes your system to optimally allocate swap memory.
- Safely installs tools only if they aren't already present.
- Hardens your server security automatically without manual intervention.
- Prompts for inputs elegantly when needed.

## ✨ Features
- **Security First:** Hardens SSH (requires key-based auth, disables root & password logins), sets up a dedicated sudo user, and configures UFW / Fail2Ban.
- **Performance Optimized:** Intelligently provisions swap space based on your server's total RAM.
- **Developer Ready:** Installs critical utilities (`curl`, `wget`, `git`) by default, with optional prompts for **Docker**, **Nginx**, and **NVM**.
- **Highly Modular:** Easily customizable by adding or modifying scripts in the `steps/` directory.

## 🚀 How to use

Once you initialize a fresh server, keep your ssh public key ready to use (ed25519 preferred). SSH into the server using a sudo user (preferably root), then run the script using `curl` or `wget`. The script will explain its actions and prompt for your preferences. After confirmation, it will execute the steps accordingly.

After the script finishes, it will prompt you to log out and log back in using the new sudo user. The new user will have sudo privileges and will be able to run the script again if needed. Password authentication will be disabled for the new user, and it'll disabled the root login completely.

### Essential Mode (Default)
Installs core utilities, configures security, and creates a new sudo user.

```bash
curl -sL "https://raw.githubusercontent.com/ItsSVK/server_setup/refs/heads/main/install.sh" | sudo bash
```

### Advanced Mode (Full)
*(Pass the `-f` flag)* Includes everything in Essential Mode, plus prompts to install Docker, Nginx, and NVM.

```bash
curl -sL "https://raw.githubusercontent.com/ItsSVK/server_setup/refs/heads/main/install.sh" | sudo bash -s -- -f
```

---

### Contributing
Contributions are always appreciated, feel free to open an issue for bugs, suggestions, or feature requests, or submit a pull request. I'll be happy to review and merge them.

### License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---
<p align="center"><b>Created with ❤️ by Shouvik Mohanta</b></p>
