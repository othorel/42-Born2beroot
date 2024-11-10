# Born2beroot Bonuses

For the Born2beroot bonuses, we have to install WordPress with Lighttpd, MariaDB and PHP. We also have to install another service of our own choice, and justify that choice.

There is a [VM installation guide](https://github.com/Benjamin-poisson/42-Born2beroot/blob/main/guide/installation_debian.md) and a [configuration guide](https://github.com/Benjamin-poisson/42-Born2beroot/blob/main/guide/configuration_debian.md), as well.

## Installing WordPress

### Installing PHP

To get the latest version of PHP (8.1 at the time of this writing), we need to add a different APT repository, Sury's repository.

```bash
$ sudo apt update
$ sudo apt install curl
$ sudo curl -sSL https://packages.sury.org/php/README.txt | sudo bash -x
$ sudo apt update 
```

Install PHP version 8.1:
```bash
$ sudo apt install php8.1
$ sudo apt install php-common php-cgi php-cli php-mysql
```

Check php version:
```bash
$ php -v
```

### Installing Lighttpd

Apache may be installed due to PHP dependencies. Uninstall it if it is to avoid conflicts with lighttpd:

```bash
$ systemctl status apache2
$ sudo apt purge apache2
```

Install lighttpd:

```bash
$ sudo apt install lighttpd
```

Chack version, start, enable lighttpd and check status:

```bash
$ sudo lighttpd -v
$ sudo systemctl start lighttpd
$ sudo systemctl enable lighttpd
$ sudo systemctl status lighttpd
```

Next, allow http port (port 80) through UFW:
```bash
$ sudo ufw allow http
$ sudo ufw status
```

And forward host port 8080 to guest port 80 in VirtualBox:

* Go to VM >> ```Settings``` >> ```Network``` >> ```Adapter 1``` >> ```Port Forwarding```
* Add rule for host port ```8080``` to forward to guest port ```80```

To test Lighttpd, go to host machine browser and type in address ```http://127.0.0.1:8080``` or ```http://localhost:8080```. You should see a Lighttpd "placeholder page".

Back in VM, activate lighttpd FastCGI module:
```bash
$ sudo lighty-enable-mod fastcgi
$ sudo lighty-enable-mod fastcgi-php
$ sudo service lighttpd force-reload
```

To test php is working with lighttpd, create a file in ```/var/www/html``` named ```info.php```. In that php file, write:
```php
<?php
phpinfo();
?>
```

Save and go to host browser and type in the address ```http://127.0.0.1:8080/info.php```. You should get a page with PHP information.

### Installing MariaDB

Install MariaDB:
```bash
$ sudo apt install mariadb-server
```

Start, enable and check MariaDB status:
```bash
$ sudo systemctl start mariadb
$ sudo systemctl enable mariadb
$ systemctl status mariadb
```

Then do the MySQL secure installation:
```bash
$ sudo mysql_secure_installation
```

Answer the questions like so (root here does not mean root user of VM, it's the root user of the databases!):
```
Enter current password for root (enter for none): <Enter>
Switch to unix_socket authentication [Y/n]: Y
Set root password? [Y/n]: Y
New password: 101Asterix!
Re-enter new password: 101Asterix!
Remove anonymous users? [Y/n]: Y
Disallow root login remotely? [Y/n]: Y
Remove test database and access to it? [Y/n]:  Y
Reload privilege tables now? [Y/n]:  Y
```

Restart MariaDB service:
```bash
$ sudo systemctl restart mariadb
```

Enter MariaDB interface:
```bash
$ mysql -u root -p
```

Enter MariaDB root password, then create a database for WordPress:
```mysql
MariaDB [(none)]> CREATE DATABASE wordpress_db;
MariaDB [(none)]> CREATE USER 'admin'@'localhost' IDENTIFIED BY 'WPpassw0rd';
MariaDB [(none)]> GRANT ALL ON wordpress_db.* TO 'admin'@'localhost' IDENTIFIED BY 'WPpassw0rd' WITH GRANT OPTION;
MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> EXIT;
```

Check that the database was created successfully, go back into MariaDB interface:
```bash
$ mysql -u root -p
```

And show databases:
```mysql
MariaDB [(none)]> show databases;
```

You should see something like this:
```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| wordpress_db       |
+--------------------+
```
If the database is there, everything's good!

### Installing WordPress

We need to install two tools:
```bash
$ sudo apt install wget
$ sudo apt install tar
```

Then download the latest version of Wordpress, extract it and place the contents in ```/var/www/html/``` directory. Then clean up archive and extraction directory:
```bash
$ wget http://wordpress.org/latest.tar.gz
$ tar -xzvf latest.tar.gz
$ sudo mv wordpress/* /var/www/html/
$ rm -rf latest.tar.gz wordpress/
```

Create WordPress configuration file:
```bash
$ sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
```

Edit ```/var/www/html/wp-config.php``` with database info:
```php
<?php
/* ... */
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress_db' );

/** Database username */
define( 'DB_USER', 'admin' );

/** Database password */
define( 'DB_PASSWORD', 'WPpassw0rd' );

/** Database host */
define( 'DB_HOST', 'localhost' );
```

Change permissions of WordPress directory to grant rights to web server and restart lighttpd:
```bash
$ sudo chown -R www-data:www-data /var/www/html/
$ sudo chmod -R 755 /var/www/html/
$ sudo systemctl restart lighttpd
```

In host browser, connect to ```http://127.0.0.1:8080``` and finish WordPress installation.

Sure, here's the translation of the entire text into English:

---

## Installing a Minecraft Server
edit [bepoisso](https://github.com/Benjamin-poisson)

For the second bonus, I chose to install a Minecraft server that will be set up as a service on the machine and will allow you to connect to the host machine.

I recommend switching to `su` for the following steps, but make sure to keep `sudo` in the commands, or some might not work.
```bash
$ su 
```

Create a user:

We create the Minecraft user and set a password for it.

```bash
$ sudo useradd -m -d /home/minecraft minecraft
$ sudo passwd minecraft
```

Create a Minecraft group and assign it to the user:

```bash
$ sudo groupadd minecraft
$ sudo gpasswd -a minecraft minecraft
$ sudo gpasswd -a minecraft sudo
$ sudo visudo # Then add: minecraft ALL=(ALL:ALL) ALL
```

Install Java:

```bash
$ sudo apt update && sudo apt upgrade -y
$ sudo wget https://download.oracle.com/java/23/latest/jdk-23_linux-x64_bin.deb
$ sudo dpkg -i jdk-23_linux-x64_bin.deb
$ sudo rm -rf jdk-23_linux-x64_bin.deb 
```
Output:
```bash
java 23.0.1 2024-10-15
Java(TM) SE Runtime Environment (build 23.0.1+11-39)
Java HotSpot(TM) 64-Bit Server VM (build 23.0.1+11-39, mixed mode, sharing)
```

Install Minecraft Server:

```bash
$ cd /home/minecraft
$ wget https://piston-data.mojang.com/v1/objects/45810d238246d90e811d896f87b14695b7fb6839/server.jar
$ ls -la
```
Output:
```bash
drwxr-xr-x 2 xxxx xxxx     4096 Nov 10 14:23 .
drwxr-xr-x 5 xxxx xxxx     4096 Nov 10 14:20 ..
-rw-r--r-- 1 xxxx xxxx 56122038 Oct 23 14:40 server.jar
```

Before starting the server, you need to accept the End User License Agreement (EULA). You can do this by executing the following command to generate the `eula.txt` file:
```bash
$ echo "eula=true" > eula.txt
```

Start the Minecraft Server:

```bash
$ java -Xmx2G -Xms2G -jar server.jar nogui
```

Once you start this command, you should see output similar to the following:

```bash
[15:22:17] [ServerMain/INFO]: Environment: Environment[sessionHost=https://sessionserver.mojang.com, servicesHost=https://api.minecraftservices.com, name=PROD]
[15:22:18] [ServerMain/INFO]: No existing world data, creating new world
[15:22:19] [ServerMain/INFO]: Loaded 1337 recipes
[15:22:19] [ServerMain/INFO]: Loaded 1448 advancements
[15:22:19] [Server thread/INFO]: Starting minecraft server version 1.21.3
[15:22:19] [Server thread/INFO]: Loading properties
[15:22:19] [Server thread/INFO]: Default game type: SURVIVAL
[15:22:19] [Server thread/INFO]: Generating keypair
[15:22:19] [Server thread/INFO]: Starting Minecraft server on *:25565
[15:22:19] [Server thread/INFO]: Using epoll channel type
[15:22:19] [Server thread/INFO]: Preparing level "world"
[15:22:28] [Server thread/INFO]: Preparing start region for dimension minecraft:overworld
[15:22:28] [Worker-Main-2/INFO]: Preparing spawn area: 2%
[15:22:29] [Worker-Main-2/INFO]: Preparing spawn area: 2%
[15:22:29] [Worker-Main-2/INFO]: Preparing spawn area: 2%
[15:22:30] [Worker-Main-2/INFO]: Preparing spawn area: 2%
[15:22:30] [Worker-Main-2/INFO]: Preparing spawn area: 2%
[15:22:31] [Worker-Main-2/INFO]: Preparing spawn area: 2%
[15:22:31] [Worker-Main-2/INFO]: Preparing spawn area: 2%
[15:22:32] [Worker-Main-2/INFO]: Preparing spawn area: 2%
[15:22:32] [Worker-Main-2/INFO]: Preparing spawn area: 2%
[15:22:33] [Worker-Main-2/INFO]: Preparing spawn area: 2%
[15:22:33] [Worker-Main-2/INFO]: Preparing spawn area: 2%
[15:22:34] [Worker-Main-2/INFO]: Preparing spawn area: 10%
[15:22:34] [Server thread/INFO]: Time elapsed: 5796 ms
[15:22:34] [Server thread/INFO]: Done (14.683s)! For help, type "help"
```

To stop the Minecraft server:

```bash
$ stop
$ ls -la
```
Output:
```bash
total 54860
drwxr-xr-x  6 root root     4096 Nov 10 15:22 .
drwxr-xr-x  5 root root     4096 Nov 10 15:21 ..
-rw-r--r--  1 root root        2 Nov 10 15:25 banned-ips.json
-rw-r--r--  1 root root        2 Nov 10 15:25 banned-players.json
-rw-r--r--  1 root root       10 Nov 10 15:21 eula.txt
drwxr-xr-x  8 root root     4096 Nov 10 15:22 libraries
drwxr-xr-x  2 root root     4096 Nov 10 15:25 logs
-rw-r--r--  1 root root        2 Nov 10 15:25 ops.json
-rw-r--r--  1 root root 56122038 Oct 23 14:40 server.jar
-rw-r--r--  1 root root     1394 Nov 10 15:25 server.properties
-rw-r--r--  1 root root        2 Nov 10 15:25 usercache.json
drwxr-xr-x  3 root root     4096 Nov 10 15:22 versions
-rw-r--r--  1 root root        2 Nov 10 15:22 whitelist.json
drwxr-xr-x 10 root root     4096 Nov 10 15:25 world
```

Open the necessary ports:

```bash
$ sudo ufw allow 25565/tcp
$ sudo ufw reload
$ sudo ufw status
```
Output: Check if 25565/tcp is allowed:

```bash
Status: active

To                         Action      From
--                         ------      ----
4242                       ALLOW       Anywhere                  
80/tcp                     ALLOW       Anywhere                  
25565/tcp                  ALLOW       Anywhere                  
4242 (v6)                  ALLOW       Anywhere (v6)             
80/tcp (v6)                ALLOW       Anywhere (v6)             
25565/tcp (v6)             ALLOW       Anywhere (v6)  
```

Now go to VirtualBox to set up port forwarding:

- Go to VirtualBox >> `Settings` >> `Network` >> `Adapter 1` >> `Port Forwarding`
- Add a rule to forward host port `25565` to guest port `25565`

Now, we will restart the Minecraft server to verify that you can connect to the server:

```bash
$ java -Xmx2G -Xms2G -jar server.jar nogui
```

- Go to Minecraft >> `1.21.3` >> `Multiplayer` >> `Add Server` >> `Server Address` >> `localhost`

You should be able to connect to the Minecraft server. Once done, exit Minecraft and stop the server:

```bash
$ stop
```

Permissions for the server:

```bash
$ sudo chown -R minecraft:minecraft /home/minecraft
$ sudo chmod -R 755 /home/minecraft
```

Shut down the VM and restart it with the Minecraft user, then switch to `su` again.

If your shell is not the usual one when reconnecting with Minecraft, follow these instructions:

```bash
$ echo $SHELL # If you see something other than /bin/bash, continue. Otherwise, skip to the next section.
$ su
$ sudo chsh -s /bin/bash minecraft
```

Create the start script `start.sh`:

```bash
$ sudo nano start.sh
```

Then add this content:

```bash
#!/bin/bash
cd /home/minecraft/
java --Xmx2G -Xms2G -jar server.jar nogui > /home/minecraft/minecraft.log 2>&1
```

This script prevents the console from showing in the

 terminal and logs everything directly to a log file.

Now, modify your `.bashrc` to add an alias that will allow you to view the console live:

```bash
$ sudo nano /home/minecraft/.bashrc
```

Add this line:

```bash
alias mclog="tail -f /home/minecraft/minecraft.log"
```

Configure the Minecraft server as a systemd service:

```bash
$ sudo nano /etc/systemd/system/minecraft.service
```

Add this script:

```bash
[Unit]
Description=Minecraft Server
After=network.target

[Service]
ExecStart=/home/minecraft/start.sh
User=minecraft
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Now set the correct permissions:

```bash
$ sudo chown -R minecraft:minecraft /home/minecraft
$ sudo chmod -R 755 /home/minecraft
```

Finally, reload the systemd configuration and start the Minecraft service:

```bash
$ sudo systemctl daemon-reload
$ sudo systemctl enable minecraft
$ sudo systemctl start minecraft
$ sudo systemctl status minecraft
```

You should see the following line:

```bash
Active: active (running) since
```

If not, recheck your permissions.

```bash
$ mclog # With this command, you can see the console log of the Minecraft server. Press Ctrl+C to exit.
```

You have successfully started your Minecraft server as a systemd service, and you can now connect to it to verify that the server will start automatically on boot.

Remember to stop your server when done:

```bash
$ sudo systemctl stop minecraft
```

Here are some useful commands:

```bash
sudo systemctl start minecraft   # Start the server
sudo systemctl stop minecraft    # Stop the server
sudo systemctl restart minecraft # Restart the server
sudo systemctl status minecraft  # View the server's status
```

---

---
Made by mcombeau: mcombeau@student.42.fr | LinkedIn: [mcombeau](https://www.linkedin.com/in/mia-combeau-86653420b/) | Website: [codequoi.com](https://www.codequoi.com)
Update bonus by [bepoisso](https://github.com/Benjamin-poisson)
