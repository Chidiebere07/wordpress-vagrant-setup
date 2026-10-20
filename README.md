# WordPress on Ubuntu with Vagrant

A WordPress site running on an Ubuntu 20.04 virtual machine, built with Vagrant and VirtualBox and served by Apache with a MySQL database. I built this as a hands-on DevOps practice project while studying for a Diploma in DevOps Engineering.

> **Add a screenshot here:** save a screenshot of the running site as `screenshot.png`, upload it to this repo, and replace this line with `![WordPress site](screenshot.png)`.

## What this project shows

- Creating a virtual machine from a **Vagrantfile** (`ubuntu/focal64`)
- Installing and configuring the **LAMP stack**: Apache, MySQL and PHP
- Creating a **database and a dedicated database user** for the application
- Writing an **Apache virtual host** and enabling it with `a2ensite`
- Connecting the application to the database through `wp-config.php`
- Troubleshooting a real database connection error

## Tech used

| Tool | Purpose |
|---|---|
| Vagrant + VirtualBox | Create and manage the virtual machine |
| Ubuntu 20.04 | Operating system on the VM |
| Apache 2 | Web server |
| MySQL 8 | Database |
| PHP 7.4 | Runs WordPress |
| WordPress | The application |

## How to run it

On your computer (with Vagrant and VirtualBox installed), in this folder:

```bash
vagrant up
vagrant ssh
```

Then, inside the VM, run the setup script. The project folder is shared inside the VM as `/vagrant`:

```bash
sudo bash /vagrant/setup.sh 'YourDatabasePassword'
```

Choose your own password. It must not contain the characters `|` or `&`.

Finally, open the VM's address in your browser to finish the WordPress install. Find the address with `ip a` inside the VM. If the Vagrantfile uses a private network address, it is shown there.

## What `setup.sh` does

1. Installs Apache, MySQL, PHP and the PHP extensions WordPress needs
2. Downloads WordPress to `/srv/www/wordpress`
3. Creates the Apache site `wordpress.conf` and enables it, with the `rewrite` module on
4. Creates the `wordpress` database and user, and grants access
5. Copies `wp-config-sample.php` to `wp-config.php` and fills in the database details
6. Checks the Apache config with `apache2ctl configtest`, enables the services on boot and restarts Apache

## Problems I solved

- **"Error establishing a database connection":** WordPress could not log in to MySQL. The password in `wp-config.php` did not match the MySQL user's password. I recreated the user with the right password, confirmed the login with `mysql -u wordpress -p`, and fixed the config.
- **Apache config typed into the terminal:** I pasted the virtual host text into the shell, so bash tried to run it as commands. The fix was to put it in `/etc/apache2/sites-available/wordpress.conf` and check it with `apache2ctl configtest` before reloading.
- **Stuck MySQL prompt:** a missing semicolon left MySQL waiting with the `->` prompt. `\c` cancels the unfinished command.
- **Stray text inside `wp-config.php`:** lines from another terminal got pasted into the file. I removed them, and WordPress loaded again.

## What I learned

- Read the error message first. It usually says what is wrong.
- A web app needs three parts to agree: the web server, the app config and the database user.
- Keep passwords out of Git. `wp-config.php` is created on the VM and is not stored in this repo.
- Scripts make setups repeatable, so typing commands by hand is not needed again.

## Notes and limits

- `setup.sh` leaves WordPress's default security keys in `wp-config.php`. For a real site, replace them with fresh keys from the WordPress secret-key service.
- This is a practice setup for a local VM, not a production server.
- Ubuntu 20.04 is past its standard support date, so use a newer box for anything long-lived.

## Author

**Christian Chidiebere Oburu**
GitHub: [Chidiebere07](https://github.com/Chidiebere07)
