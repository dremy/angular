#! /bin/bash
# Automated script to build Angular core
#
# In general, if you are just kickstarting a new instance or updating
# your existing installation, this is the file to start with.
#
# Usage
#
# ./build.sh ../path/to/directory
#

source config/*


#########################################################
#            OK, don't edit anything below...           #
#########################################################

# This is a helper function we run after running drush make
# to make sure the make file is working properly.  If not,
# we want to prematurely kill the script to save us time.
#
# Easy way to use this function, insert the line below:
# exitcode $?
exitcode()
{
  if [ $1 -ne 0 ]; then
    echo
    echo
    echo '--> Something went wrong with your make file!'
    echo '--> To prevent damage to the site, we killed the script.'
    echo '--> Please investigate the errors and try again.'
    echo
    echo '--> For now, we killed the working directory.'
    chmod -R 777 $TARGET_PATH;
    rm -rf $TARGET_PATH;
    echo '--> Build cancelled!  Sorry about that!'
    echo
    exit;
  fi
}

echo

# If target directory argument is blank, instruct the user
#   to execute the command properly
if [ $# -eq 0 ]; then
  echo "Usage:  ./build.sh -[rd] [LOCATION]"
  echo "Example: ./build.sh -d ../html"
  echo
  exit 1
fi

# Define default variables
COREMAKE='drupal-org-core.make'
DEVMAKE="angular-dev.make"
RELEASEMAKE="angular-release.make"

# Drush options.
DRUSH_OPTS="--yes --no-cache --concurrency=4"

# Default environment
ENV="DEV"

# Target directory we want to install the site on.
TARGET=$1

# Repository directory (the current one you're in)
CURDIR=`pwd -P`
CALLPATH=`dirname "$0"`
ABS_CALLPATH=`cd "$CALLPATH"; pwd -P`

# Directory one level up from the repository and site repo.
BASE=`cd ../; pwd -P`

# Set some configuration variables based on options
# TODO: This can probably be handled with something like getopts
if [ $# -eq 2 ]; then
  case $1 in
    "-d") # DEV
      DRUSH_OPTS='--working-copy --no-gitinfofile'
      ENV="DEV"
      TARGET=$2
      ;;
    "-r") # RELEASE
      ENV="RELEASE"
      TARGET=$2
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      echo "Please choose either -d (dev) or -r (release)"
      exit 1
      ;;
  esac
fi


# We are going to install the site in a temporary directory first
#   to make sure the existing one stays live, then make the switchover.
#   We instantiate and establish their locations here.
if [ ! -e "$ORIGINAL" ]; then
  mkdir "$TARGET"
  ORIGINAL=`cd $TARGET; pwd -P`
  rmdir "$TARGET"
else
  ORIGINAL=`cd $TARGET; pwd -P`
fi;
ORIGINAL=${ORIGINAL%/}
TARGET="${TARGET%/}_tmp"


# Logging messsage to let user know which environment they are in
case $ENV in
  DEV) echo '--> Makefile for DEV environment selected' ;;
  RELEASE) echo '--> Makefile for RELEASE environment selected' ;;
esac


# Let's build the site!
echo
echo '===================================='
echo '||     _______  _____   ___       ||'
echo '||    /__  __/ / ___/  / . \      ||'
echo '||      / /   / /__   / ___ \     ||'
echo '||     / /   / ___/  / /   \ \    ||'
echo '||    /_/   /_/     /_/     \_\   ||'
echo '||                                ||'
echo '||        Teach for America       ||'
echo '===================================='

echo "--> Building to target directory: $ABS_CALLPATH"
echo
echo


# Build Drupal Core onto target location
echo "--> Building Drupal core..."
drush cc drush
drush make --prepare-install $DRUSH_OPTS "$ABS_CALLPATH/make/$COREMAKE" "$TARGET"


# Define target path location
TARGET_PATH=`cd "$TARGET"; pwd -P`
TARGET_PATH=${TARGET_PATH%/}

# Switch to newly created installation, install environment-specific make file
cd "$TARGET"

# Install development-specific modules
if [ "$ENV" = "DEV" ]; then
  echo
  echo "--> Installing development modules..."
  drush make --no-core $DRUSH_OPTS "$ABS_CALLPATH/make/$DEVMAKE"
  exitcode $?
  echo "--> Complete!"
fi


# Install site modules
echo
echo "--> Installing release modules..."
drush make --no-core $DRUSH_OPTS "$ABS_CALLPATH/make/$RELEASEMAKE"
exitcode $?
echo "--> Complete!"


# Installing profiles
echo
echo "--> Porting over site's profile(s)..."
ln -s "$CURDIR/profiles/angular" $TARGET_PATH/profiles/angualr
echo "--> Complete!"


# Installing robot.txt
echo
echo "--> Installing robot.txt..."
rm $TARGET_PATH/robots.txt
ln -s "$CURDIR/robots.txt" $TARGET_PATH/robots.txt
echo "--> Complete!"


# settings.php is included in the repo with default configurations.
#   If settings.local.php (environment-specific settings) does not exist
#   we want to drop a sample from the repo to the environment.
#   (adjacent to the build directory)
if [ ! -e "$(dirname $CURDIR)/settings.local.php" ]; then
  echo
  echo "--> No settings.local.php file found."
  echo "--> Copying sample local file over."
  cp $CURDIR/settings.local.php $(dirname $CURDIR)
  echo
  echo "--> Complete.  Please edit settings.local.php to your environment's specifications."
fi

# Generate a drushrc settings file
if [ ! -e "$(dirname $CURDIR)/drushrc.local.php" ]; then
  echo
  echo "--> No drushrc.local.php file found."
  echo "--> Copying sample local file over."
  cp $CURDIR/drushrc.local.php $(dirname $CURDIR)
  echo
  echo "--> Complete.  Please edit drushrc.local.php to your environment's specifications."
fi


# Set up a files directory (public) outside the project directory for the site to reference in future builds
if [ ! -d "$(dirname $CURDIR)/files" ]; then
  echo
  echo "--> Creating public files directory"
  mkdir "$(dirname $CURDIR)/files"
  echo "--> Complete"
fi


# Set up a files directory (private) outside the project directory for the site to reference in future builds
if [ ! -d "$(dirname $CURDIR)/private_files" ]; then
  echo
  echo "--> Creating private files directory"
  mkdir "$(dirname $CURDIR)/private_files"
  echo "--> Complete"
fi


# Create symlink to files/
echo
echo "--> Connecting to local files directory..."
rm -rf $TARGET_PATH/sites/default/files
ln -s $(dirname $CURDIR)/files $TARGET_PATH/sites/default/
echo "--> Complete!"


# Copy settings.php over to sites/default
echo
echo "--> Copying settings.php over to sites/default..."
rm $TARGET_PATH/sites/default/settings.php
ln $CURDIR/settings.php $TARGET_PATH/sites/default
echo "--> Complete!"


# Create symlink to settings.local.php
echo
echo "--> Connecting to local settings file..."
ln -s $(dirname $CURDIR)/settings.local.php $TARGET_PATH/sites/default/settings.local.php
echo "--> Complete!"


# Copy drushrc.php over to sites/default
echo
echo "--> Copying drushrc.php over to sites/default..."
cp $CURDIR/drushrc.php $TARGET_PATH/sites/default
echo "--> Complete!"


# Create symlink to drushrc.local.php
echo
echo "--> Connecting to local drushrc file..."
ln -s $(dirname $CURDIR)/drushrc.local.php $TARGET_PATH/sites/default/drushrc.local.php
echo "--> Complete!"

# For a multi-site installation, seek out the sites/ directory adjacent to the site's
#   root directory for other multisite instances.  Generate symlinks in /sites if it
#   exists.

# Cycle through all directories.  Auto-generate any files that doesn't exist yet.
echo
if [ -d "$BASE/sites" ]; then
  SITE=`cd $BASE/sites; pwd -P`

  # Link settings.base.php to sites/ directory
  if [ -e "$SITE/settings.base.php" ]; then
    echo
    echo "--> Linking settings.base.php to sites/ directory"
    ln $SITE/settings.base.php $TARGET_PATH/sites/settings.base.php
    chmod 644 $TARGET_PATH/sites/settings.base.php
    echo '--> Complete!'
  fi

  # Link sites.php to the sites/ directory
  if [ -e "$SITE/sites.php" ]; then
    echo
    echo "--> Linking sites.php to sites/ directory"
    ln $SITE/sites.php $TARGET_PATH/sites/sites.php
    chmod 644 $TARGET_PATH/sites/sites.php
    echo '--> Complete!'
  fi

  # If the required assets and configurations don't exist
  # Automatically create them!
  #
  # To spin up a new site, simply create a new directory in the sites directory.
  for i in $( ls $SITE ); do
    if [ -d "$SITE/$i" ]; then
      # Copy over settings.local.php
      if [ ! -e "$SITE/$i/settings.local.php" ]; then
        echo
        echo "--> Creating settings.local.php for regional site $i..."
        cp $CURDIR/settings.local.php $SITE/$i
        chmod 644 $SITE/$i/settings.local.php
        echo '--> Complete!'
      fi

      # Copy over settings.local.php
      if [ ! -e "$SITE/$i/drushrc.local.php" ]; then
        echo
        echo "--> Creating drushrc.local.php for regional site $i..."
        cp $CURDIR/drushrc.local.php $SITE/$i
        chmod 644 $SITE/$i/drushrc.local.php
        echo '--> Complete!'
      fi

      # Symlink settings.php if it doesn't exist.
      if [ ! -e "$SITE/$i/settings.php" ]; then
        echo
        echo "--> Linking settings.php for regional site $i..."
        ln $CURDIR/settings.php $SITE/$i/settings.php
        chmod 644 $SITE/$i/settings.php
        echo '--> Complete!'
      fi

      # Create arbitrary public files directory.
      # NOTE FOR TFA: You probably want to ditch this and create a symlink
      # to a gfs mount for files.
      if [ ! -d "$SITE/$i/files" ]; then
        echo
        echo "--> Creating public files directory..."
        mkdir $SITE/$i/files
        chmod -R 755 $SITE/$i/files
        echo '--> Complete!'
      fi

      # Create arbitrary private files directory.
      # NOTE FOR TFA: You probably want to ditch this and create a symlink
      # to a gfs mount for files.
      if [ ! -d "$SITE/$i/private_files" ]; then
        echo
        echo "--> Creating files directory..."
        mkdir $SITE/$i/private_files
        chmod -R 755 $SITE/$i/private_files
        echo '--> Complete!'
      fi

      # Set up the symlink to the new site root.
      echo
      echo "--> Linking $i to the sites directory..."
      # Set up the symbolic links.
      ln -s $SITE/$i $TARGET/sites/$i
      echo '--> Complete!'

      # If a sites.php file exists, link that.
      if [ ! -e "$SITE/sites.php" ]; then
        echo
        echo "--> Linking sites.php to the sites directory..."
        # Set up the symbolic links.
        ln -s $SITE/sites.php $TARGET/sites/sites.php
        echo '--> Complete!'
      fi
    fi
  done
fi


# Remove target directory if it already exists
if [ -e "$ORIGINAL" ]; then
  # If user cancels, we delete all our progress and terminate the script
  echo
  while true; do
    read -p "--> A directory already exists at this location ($ORIGINAL).  Are you sure you want to delete this directory? (Y/n) " yn
    case $yn in
      [Y] ) break;;
      [Nn] ) chmod -R 777 $TARGET_PATH; rm -rf $TARGET_PATH; echo "--> Build cancelled."; echo; exit;;
      * ) echo "--> Please answer [Y]es or [n]o.";;
    esac
  done

  if [ "$ENV" = "DEV" ]; then
    # No need to keep the current directory...
    echo
    echo '--> Removing old build directory...'
    chmod -R 777 $ORIGINAL
    rm -rf "$ORIGINAL"
    echo '--> Directory removed!'
  else
    # We assume that if this is a release build, we want to keep a backup in case things go awry...
    echo
    echo '--> Relocating old directory...'
    DATE=`date '+%Y-%m-%d_%H:%M:%S'`
    BACKUP=$ORIGINAL'_archive_'$DATE
    mv $ORIGINAL $BACKUP
    echo '--> Directory moved!'
    echo "--> If something goes awry, you can restore $BACKUP"
  fi
fi


# Adjust permissions of settings file
echo
echo "--> Changing settings file permissions..."
chmod 755 $TARGET_PATH/sites/default/
chmod 777 $TARGET_PATH/sites/default/files
chmod 644 $TARGET_PATH/sites/default/settings.php
chmod 644 $TARGET_PATH/sites/default/settings.local.php
chmod 644 $TARGET_PATH/sites/default/drushrc.php
chmod 644 $TARGET_PATH/sites/default/drushrc.local.php
echo "--> Complete!"


# Move our newly established build to the original location
echo
echo "--> Moving directory..."
mv $TARGET_PATH $ORIGINAL
echo "--> Complete!"


# Set up behat local configurations if environment is being built in dev mode
if [ "$ENV" = "DEV" ]; then
  if [ ! -e "$(dirname $CURDIR)/behat.local.yml" ]; then
    echo
    echo "--> No behat.local.yml found"
    echo "--> Setting up behat.local.yml..."
    cp $CURDIR/behat/behat.local.yml.sample $(dirname $CURDIR)/behat.local.yml
    echo "--> Complete!  Please edit behat.local.yml to your environment's specifications."
  fi
  echo "--> Grabbing dependency files for behat testing..."
  cd "$CURDIR/behat/"
  php composer.phar install
  echo "--> Complete!"
fi

echo
echo
echo '--> Build completed successfully!'
echo
