# RANCID in Docker and Kubernetes

This is a [Docker](https://www.docker.com/) container to run the
[RANCID](http://www.shrubbery.net/rancid/) software, which periodically
collects Cisco router and switch configurations and uploads them into
a source control repository.

All three version control systems supported by RANCID (CVS, SVN, and GIT) are
installed within this image, and can be used by setting up RANCID
appropriately.

This image also contains [ssmtp](https://wiki.debian.org/sSMTP), the extremely
simple MTA.

This project is designed to be used as a Kubernetes CronJob.

## Configuration

This container is configured in a non-standard way compared to most Docker
environments, but this software was never designed to be cloud-native anyway.
We use a single git repository to store all configuration, as well as the
router backups.

* Create a **private repository** on [Github](https://github.com/).
* Read the [Github Deploy Key Documentation](https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys).
* Generate an ssh key to be used as a Github deploy key, using this command:

    ssh-keygen -C rancid -f rancid < /dev/null

* Your ssh public key is in `rancid.pub`. This is the Github deploy key.
* Your ssh private key is in `rancid`. This is **not** uploaded to Github.
* Upload the Github deploy key to Github. Select the `Allow write access` check box.

* Create a local checkout of your Github repository:

    git clone git@github.com:username/repository.git

* Within your local checkout, create this directory structure:

    ├── .cloginrc           # <-- this file contains passwords for RANCID
    ├── .gitignore          # <-- ignore any files you want (optional)
    ├── rancid.conf         # <-- main RANCID configuration file
    ├── README.md           # <-- anything you want! (optional)
    ├── .ssh                # <-- ssh configuration directory
    │   ├── config          # <-- ssh configuration file (see example below)
    │   ├── id_rsa          # <-- ssh private key (copy of "rancid" ssh key file)
    │   └── id_rsa.pub      # <-- ssh public key (copy of "rancid.pub" ssh key file)
    └── ssmtp.conf          # <-- ssmtp configuration file (see example)

* Create one directory for each RANCID group, with the contents:

    mkdir $GROUP
    mkdir $GROUP/configs
    touch $GROUP/router.db

* Following the RANCID documentation, configure each switch or router in the
  `router.db` file.

* Commit everything and push it up to Github.

## Example `.cloginrc`

* Documentation: <https://www.shrubbery.net/rancid/man/cloginrc.5.html>

The example below shows you how to set up RANCID to fetch data from all
switches and routers which have a hostname `*.example.com`. The username
will be `myusername`. The unprivileged password will be `unprivilegedpassword`.
The privileged password (AKA "enable password") will be `privilegedpassword`.
All devices will be accessed using `ssh`.

    add user *.example.com myusername
    add password *.example.com {unprivilegedpassword} {privilegedpassword}
    add method *.example.com {ssh}

You should customize this example for your environment.

## Example `rancid.conf`

* Documentation: <https://www.shrubbery.net/rancid/man/rancid.conf.5.html>

The example below shows you the minimum necessary for this container to work:

    TERM=network;export TERM
    LC_COLLATE="POSIX"; export LC_COLLATE
    uid=`perl -e 'print "$>"'`
    test "$uid" -eq 0 && echo "Do not run $0 as root!" && exit 1
    umask 027
    PERL5LIB="/usr/lib/rancid"; export PERL5LIB
    TMPDIR=/tmp; export TMPDIR
    BASEDIR=/var/rancid; export BASEDIR
    PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin; export PATH
    SENDMAIL="/usr/sbin/sendmail"
    CVSROOT=$BASEDIR/github ; export CVSROOT
    LOGDIR=/var/log/rancid; export LOGDIR
    RCSSYS=git; export RCSSYS
    ACLSORT=YES; export ACLSORT
    FILTER_PWDS=NO; export FILTER_PWDS
    PAR_COUNT=8; export PAR_COUNT
    LIST_OF_GROUPS=""

Be sure and configure your `LIST_OF_GROUPS` according to the documentation.

## Example `ssmtp.conf` for Google GMail for Business

The example below shows you how to configure ssmtp to work with your
Google GMail for Business email account.

    TLS_CA_FILE=/etc/pki/tls/certs/ca-bundle.crt
    root=your-email@example.com
    mailhub=smtp.gmail.com:587
    rewriteDomain=example.com
    hostname=rancid.example.com
    useSTARTTLS=YES
    FromLineOverride=YES

    AuthUser=your-email@example.com
    AuthPass=your-password
    AuthMethod=LOGIN

## Run this container

    git clone git@github.com:username/repository.git myrepository
    docker run --rm -it -v $PWD/myrepository:/var/rancid irasnyd/rancid rancid-run -m "your-email@example.com"

You can adapt this example for use as a Kubernetes CronJob.
