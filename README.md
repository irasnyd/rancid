RANCID in Docker
================

This is a Docker container to run [RANCID](http://www.shrubbery.net/rancid/),
the Really Awesome New Cisco config Differ. This container runs a minimal
installation of the [Postfix](http://www.postfix.org/) mail server so that it
can send email. This container also runs a cron daemon which runs RANCID once
per hour.

All three version control systems supported by RANCID (CVS, SVN, and GIT) are
installed within this image, and can be used by setting up RANCID
appropriately.

Configuration
=============

This container is configured both by environment variables and by configuration
files which must be written by hand.

Environment Variables
---------------------

- **`POSTFIX_HOSTNAME`** - Hostname used by Postfix (default: `rancid.example.com`).
- **`POSTFIX_ORIGIN`** - Origin used by Postfix (default: `rancid.example.com`).
- **`POSTFIX_RELAYHOST`** - Relay host used by Postfix (default: `example.com`).
- **`MAIL_RCPT`** - Recipient of all RANCID emails (default: `rancid@example.com`).

Configuration Files
-------------------

- `/etc/rancid/rancid.conf` - Main RANCID configuration file (required).
- `/var/rancid/.cloginrc` - RANCID Cisco Login details configuration file (required).
- `/var/rancid/.ssh/config` - RANCID SSH configuration (optional).

Data Directories
================

You may wish to mount the following data directories on a persistent Docker volume.

- `/var/rancid` - RANCID working directory.
