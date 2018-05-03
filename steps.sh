#!/bin/bash

# Create a new directory and switch into it
mkdir new-project && cd new-project

# Start with initializing git version control
git init && git commit --allow-empty -m 'Initial commit'

# Add .gitignore
cat ../source/.gitignore
cat ../source/.gitignore > .gitignore
git add . && git commit -m 'Add .gitignore'

# That is how we started a few months ago
# composer require typo3/cms ^8.7

# We now require individual packages only
composer require typo3/cms-core ^8.7 --no-update
git add . && git commit -m "Add composer.json"

# Move most things out of the web server's document root
composer config extra.typo3/cms.web-dir 'public'
composer install
git add . && git commit -m "Add composer.lock"

ls -al
# OK, nice, but what about Resources/Private?
ls -al public/typo3/sysext/core/Resources/
# Hm, private resources still in document root
git clean -dffx # clean up everything. We can do better.

# Configure a "private" directory, which will be the place where your TYPO3 installation lives
composer config extra.typo3/cms.root-dir 'private'

# To activate / evaluate the new settings and generate the public folder/files, require this package
composer require helhum/typo3-secure-web
git add . && git commit -m "Add helhum/typo3-secure-web"
ls -al public/typo3/sysext/core/Resources/
# Ahh, much better now

# Add some little dev helper packages
composer require --dev typo3-console/php-server-command
composer require --dev helhum/dotenv-connector
git add . && git commit -m "Add dev helper packages"

# Add a package which adds TYPO3 Console convenience to your composer execution (similar to minimum distribution)
# You will be asked for mysql credentials and other TYPO3 setup things in this step
composer require typo3-console/composer-auto-setup

# Commit current state
git add . && git commit -m "Add typo3-console/composer-auto-setup"

typo3cms server:run # Let's see if it worked

# Here is how I recommend to handle project specific packages/extensions
cp -r ../source/packages . # Add a private package to packages folder
composer config repositories.local path 'packages/*' # make them installable vi composer
composer require helhum/site-package @dev # require one local package
git add . && git commit -m "Add project specific site package"

composer config repositories.ter composer https://composer.typo3.org/ # Make TER packages available via Composer
composer update --lock
git add composer.json && git commit -m "Make TER packages available"

# One more thing! Configuration handling
cp -r ../source/conf . # copy basic configuration structure
git add . && git commit -m "Add basic config file"
mkdir -p var/log # add var directory (TYPO3 9 style)
cp private/typo3conf/LocalConfiguration.php ../source/ # save current state of configuration
composer require helhum/typo3-config-handling # require the package
mv ../source/LocalConfiguration.php private/typo3conf/ # restore current project configuration
typo3cms settings:extract # write project configuration into conf/config.yml
typo3cms settings:dump # Use config from conf/

typo3cms server:run # Everything still works
