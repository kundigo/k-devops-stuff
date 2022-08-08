#!/bin/bash

# Always set -e part or your bash scripts may silently fail
# and cause some hard to find bugs.
echo "======> set -e"
set -e

# https://stackoverflow.com/a/63442072
# echo "======>sudo apt-get --assume-yes install ubuntu-dev-tools"
# sudo apt-get --assume-yes install ubuntu-dev-tools

# In order to better understand the output of the script
# be sure to print each command
# echo "======> "

### SSH SETUP ###
# Correct permissions since they are too open by default
echo "======> chmod 0600 ~/.keys/*"
chmod 0600 ~/.keys/*
# Add the key to the ssh agent:
echo "======> ssh-add ~/.keys/*"
ssh-add ~/.keys/*

### INITIAL DEPENDECIES SETUP ###
# sem-version python 2.7
# echo "======> sem-version c 8"
# sem-version c 8
# echo "======> nvm use 12.22.5"
# nvm use 12.22.5
echo "======> gem install bundler -v '2.1.4' --no-document"
gem install bundler -v '2.1.4' --no-document
echo "======> bundle config set path 'vendor/bundle'"
bundle config set path 'vendor/bundle'
echo "======> rbenv rehash"
rbenv rehash

# We might get errors like
#  pg_dump: WARNING:  out of shared memory
#  HINT:  You might need to increase max_locks_per_transaction.
#
# NOTE: the path /var/lib/postgresql/data has been obtained using another command (see below)
echo "======> sudo mkdir /var/lib/postgresql/data"
sudo mkdir /var/lib/postgresql/data
echo "======> echo 'max_locks_per_transaction = 1024' | sudo tee - a /var/lib/postgresql/data/postgresql.conf"
echo 'max_locks_per_transaction = 1024' | sudo tee - a /var/lib/postgresql/data/postgresql.conf


### VERSIONS ####
echo "======> git --version"
git --version
echo "======> gcc --version"
gcc --version
echo "======> ruby -v"
ruby -v
echo "======> yarn --version"
yarn --version
echo "======> node --version"
node --version

### CI SETUP
echo "======> checkout --use-cache"
checkout --use-cache
echo "======> sem-service start postgres"
sem-service start postgres
echo "======> sem-service start redis"
sem-service start redis

### ENV VARIABLES
echo "======> set LAST_GIT_COMMIT_MESSAGE env variables"
export LAST_GIT_COMMIT_MESSAGE="$(git log -1 --pretty=%B)"
echo  "LAST_GIT_COMMIT_MESSAGE: \"$LAST_GIT_COMMIT_MESSAGE\""

echo "======> set VISUAL_TESTING_ADAPTER env variables"
VISUAL_TESTING_REGEXP="visual([ \-]{1})test"
if [[ $LAST_GIT_COMMIT_MESSAGE =~ $VISUAL_TESTING_REGEXP ]]; then export VISUAL_TESTING_ADAPTER="percy"; fi
echo  "VISUAL_TESTING_ADAPTER: \"$VISUAL_TESTING_ADAPTER\""

# this command returns the path to the postgresql config file"
echo "======> psql -U postgres -c 'SHOW config_file'"
psql -U postgres -c 'SHOW config_file'
echo "======> psql -U postgres -c 'SHOW max_locks_per_transaction'"
psql -U postgres -c 'SHOW max_locks_per_transaction'