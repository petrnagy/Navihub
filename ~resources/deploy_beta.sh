#!/bin/bash

echo "Starting deployment..."

wwwuser="www-data"
current_dir=`pwd`
project_dir="/var/www/beta.navihub.net"

echo "Updating files permissions #1..."
sudo chmod -R 770 $project_dir/

cd $project_dir
changed_dir=`pwd`

if [ "$changed_dir" == "$project_dir" ]
then
	echo "OK: Directory switched to $project_dir"
else
	echo "ERROR: Directory change failed"
	exit 1
fi

# TODO: New bundles may have been installed. If so, deployment will incorrectly end with
# 'Could not start maintenance mode'
echo "Shutting down application..."
maintenance_status=`rake maintenance:start reason="We're sorry, but the page is currently unavailable because of short maintenance window.<br><br>Stay tuned! This should not take more than a few seconds."`
if [[ "$maintenance_status" == *"Created tmp/maintenance.yml"* ]]
then
	echo "OK: Application halted!"
else
	echo "ERROR: Could not start maintenance mode"
	exit 1
fi

git_branch=`git branch | grep '* devel'`
echo "Checking proper branch"
if [ -z "$git_branch" ]
then
	echo "ERROR: Not on branch devel, cannot continue"
    echo "FATAL: Application is NOT running !"
    exit 1
fi

fetch_status=`git fetch --all`
if [ "Fetching origin" != "$fetch_status" ]
then
	echo "ERROR: Fetching failed, result: $fetch_status"
    echo "FATAL: Application is NOT running !"
	exit 1
fi

### TODO: Proper if-else control ! ! !

echo "Reseting repository..."
git reset --hard origin/devel

#echo "Updating bundles..."
#sudo bundle update

echo "Installing bundles..."
sudo bundle install

echo "Starting database migration..."
sudo rake db:migrate RAILS_ENV=test

echo "Deleting cached files..."
rake tmp:cache:clear

echo "Precompiling assets..."
rake assets:precompile

echo "Updating files permissions #2..."
sudo chmod -R 770 $project_dir/

echo "Changing owner and group..."
sudo chown -R $wwwuser:$wwwuser "$project_dir/"

echo "Removing maintenance mode..."
sudo chown jenkins tmp/maintenance.yml
maintenance_end_status=`rake maintenance:end`
if [[ "$maintenance_end_status" == *"Deleted tmp/maintenance.yml"* ]]
then
	echo "OK: Maintenance mode disabled, application is running again"
else
	echo "FATAL: Could not disable maintenanace mode, application is NOT running"
	exit 1
fi

echo "Finished, yay!"

exit 0
