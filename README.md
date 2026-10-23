# Hugo Cat

A web photo booth application with a grunge-style neon aesthetic.

## Description

This project features a web-based photo booth with:
- Randomly blinking neon letters on each load
- Blur effects on neon text
- Grunge-style dirty texture and rough name display
- Photo booth functionality accessible at `/fotomaton/`
- Link card to access the photo booth

## Features

- **Neon Effects**: Randomly selected letters blink with blur effects
- **Grunge Style**: Dirty texture and rough typography
- **Photo Booth**: Interactive photo capture functionality
- **Responsive Design**: Works on different screen sizes

## Project Structure

```
hugo-cat/
├── README.md
├── admin/
│   └── pull.php          # Script para actualizacion automatica
└── html/
    ├── favicon.ico
    ├── favicon.png
    ├── fondo_t4.jpg
    ├── index.html
    ├── qrmailto.png
    └── fotomaton/
        └── index.html
```

## Quick Start

To view the project locally:

1. Open `html/index.html` in your web browser
2. Access the photo booth at `html/fotomaton/index.html`

Or serve with a local HTTP server:

```bash
cd hugo-cat
python -m http.server 8000
# Then open http://localhost:8000/html/ in your browser
```

## Deployment

### Basic Deployment
To deploy to a web server:
- Upload the contents of the `html/` directory to your web server root
- Ensure all image paths are correct

### Automatic Update Endpoint (Recommended)

For **hugo.cat** domain with Apache serving from `/var/www.hugo.cat/html`:

#### 1. On your VPS:

**Create directory structure:**
```bash
sudo mkdir -p /var/www.hugo.cat/update
sudo chown www-data:www-data /var/www.hugo.cat/update
```

**Copy the update script:**
```bash
# Copy admin/pull.php from this repo to your VPS
cp admin/pull.php /var/www.hugo.cat/update/
```

**Configure authentication:**
```bash
sudo htpasswd -c /etc/apache2/.htpasswd pull-hugo-cat
# You will be prompted for a password - remember it!
```

**Set proper permissions for git:**
```bash
sudo chown -R www-data:www-data /var/www.hugo.cat/html
sudo -u www-data git config --global --add safe.directory /var/www.hugo.cat/html
```

#### 2. Configure Apache

Edit `/etc/apache2/sites-enabled/hugo.cat.conf` and add **inside your VirtualHost**:

```apache
# Add this inside your existing VirtualHost for hugo.cat
Alias /update /var/www.hugo.cat/update

<Directory /var/www.hugo.cat/update>
    AuthType Basic
    AuthName "Actualizacion de hugo.cat"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user

    # Enable PHP execution
    AddType application/x-httpd-php .php
    DirectoryIndex pull.php
</Directory>
```

**Enable required modules and reload Apache:**
```bash
sudo a2enmod authn_core auth_basic alias
sudo systemctl reload apache2
```

#### 3. Usage

Visit in your browser: **`https://hugo.cat/update`**
- Username: `pull-hugo-cat`
- Password: [the password you set with htpasswd]

The script will execute the deployment process and display the result.

#### 4. Initial Setup

First time setup on your VPS:
```bash
# Clone the repository
cd /var/www.hugo.cat
sudo -u www-data git clone https://github.com/hugo-555-ai/hugo-cat.git html

# Set correct permissions
sudo chown -R www-data:www-data html
```

### Full Redeployment Guide

If you need to redeploy from scratch or recover the site:

#### Prerequisites
1. **SSH Key Setup for www-data** (required for GitHub access):
   ```bash
   sudo mkdir -p /var/www/.ssh
   sudo ssh-keygen -t ed25519 -f /var/www/.ssh/id_ed25519 -C "www-data@hugo.cat" -N ""
   sudo chown -R www-data:www-data /var/www/.ssh
   sudo chmod 700 /var/www/.ssh
   sudo chmod 600 /var/www/.ssh/id_ed25519
   ```
   **Add public key to GitHub:** Copy `/var/www/.ssh/id_ed25519.pub` content to GitHub Settings → SSH and GPG keys

2. **Sudoers Configuration** (required for web-based updates):
   ```bash
   # For deploy.sh execution
   echo 'www-data ALL=(root) NOPASSWD: /tmp/hugo-cat-deploy-*/repo/deploy.sh' | sudo tee /etc/sudoers.d/hugo-cat-deploy
   
   # For git operations
   echo 'www-data ALL=(www-data) NOPASSWD: /usr/bin/git' | sudo tee /etc/sudoers.d/hugo-cat-git
   
   # For chmod operations
   echo 'www-data ALL=(root) NOPASSWD: /bin/chmod' | sudo tee /etc/sudoers.d/hugo-cat-chmod
   
   # Set correct permissions for all sudoers files
   sudo chmod 440 /etc/sudoers.d/hugo-cat-deploy
   sudo chmod 440 /etc/sudoers.d/hugo-cat-git
   sudo chmod 440 /etc/sudoers.d/hugo-cat-chmod
   
   # Verify no syntax errors
   sudo visudo -c
   ```

3. **Directory Structure:**
   ```bash
   sudo mkdir -p /var/www.hugo.cat/html
   sudo mkdir -p /var/www.hugo.cat/update
   sudo chown -R www-data:www-data /var/www.hugo.cat
   ```

#### Full Deployment Steps
```bash
# 1. Create backup of current site (if exists)
sudo zip -r /tmp/hugo-cat-full-backup-$(date +%Y%m%d-%H%M%S).zip /var/www.hugo.cat/

# 2. Clone repository to temporary location
cd /tmp
sudo -u www-data git clone --depth 1 git@github.com:hugo-555-ai/hugo-cat.git hugo-cat-deploy-manual

# 3. Execute deploy script
sudo chmod +x /tmp/hugo-cat-deploy-manual/deploy.sh
sudo bash /tmp/hugo-cat-deploy-manual/deploy.sh

# 4. Clean up
sudo rm -rf /tmp/hugo-cat-deploy-manual
```

#### Recovery from Backup
If deployment fails, restore from backup:
```bash
# List available backups
ls -la /tmp/hugo-cat-backup-*

# Restore from specific backup (replace timestamp)
sudo rm -rf /var/www.hugo.cat/html/*
sudo unzip /tmp/hugo-cat-backup-20261023-XXXXXX.zip -d /var/www.hugo.cat/html/
sudo chown -R www-data:www-data /var/www.hugo.cat/html
```

## Credits

Created with the help of AI assistants.

---

Generated by Mistral Vibe.
