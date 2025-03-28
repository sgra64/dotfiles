# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

echo ".zprofile"

# umask 022 permissions of new files are 644 (files) and 755 (directories)
umask 022

# set LANG environment variable (otherwise git may print German messages)
export LANG=en_US.UTF-8
