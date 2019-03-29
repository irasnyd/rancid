#!/bin/bash -x
# vim: set ts=4 sts=4 sw=4 et:

set -euo pipefail

stderr() {
    echo "$@" >&2
}

fixpermissions() {
    # make sure ssh permissions are ok
    chmod 0755 ~rancid/.ssh
    chmod 0600 ~rancid/.ssh/id_rsa
    chmod 0644 ~rancid/.ssh/id_rsa.pub

    # make sure .cloginrc permissions are correct
    chmod 0600 ~rancid/.cloginrc
}

# check that the home directory is a git directory
if [[ ! -d ~rancid/.git ]]; then
    stderr "ERROR: ~rancid/.git does not exist!" 
    stderr ""
    stderr "This project has not been configured correctly. Please read the README!"
    exit 1
fi

# make sure permissions are correct
fixpermissions

# configure git
git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"
git config push.default simple

# force the local repository to match the upstream
git fetch origin
git reset --hard origin/master

# create git commit post-commit hook to auto-push the repository
cat > ~rancid/.git/hooks/post-commit << EOF
#!/bin/bash
git push origin
EOF
chmod +x ~rancid/.git/hooks/post-commit

# instruct git to automatically ignore files if the user didn't configure it
[[ -f ~rancid/.gitignore ]] || cat > ~rancid/.gitignore << EOF
.ssh/known_hosts
.bash_history
*/routers.all
*/routers.down
*/routers.up
*/runcount
EOF

# make sure permissions are correct
fixpermissions

# and now that we're all good, run rancid itself
exec "$@"
