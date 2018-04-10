#!/usr/bin/env bash

echo $-
set -o errexit
set -o pipefail
set -o nounset
echo $-
exit

RUBY_MINOR="2.3"
CHRUBY_VERSION="0.3.9"


###
# Install dependencies
###

export DEBIAN_FRONTEND=noninteractive

sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt-add-repository ppa:chris-lea/redis-server
sudo apt-get -yqq update
sudo apt-get -yqq install \
  ruby$RUBY_MINOR ruby$RUBY_MINOR-dev \
  nodejs \
  postgresql postgresql-contrib postgis libpq-dev \
  redis-server \
  libsqlite3-dev \
  build-essential


###
# Install ruby version manager (chruby)
###

cd /tmp
wget --quiet --output-document=chruby.tar.gz "https://github.com/postmodern/chruby/archive/v$CHRUBY_VERSION.tar.gz"
tar -xzf chruby.tar.gz
cd chruby-$CHRUBY_VERSION
sudo make install


# create links to the new ruby version in /opt/rubies
# for use with chruby

RUBY_VERSION=$(ruby$RUBY_MINOR -e 'puts "#{RUBY_ENGINE}-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"')
sudo mkdir -p /opt/rubies/$RUBY_VERSION/bin
sudo chown -R $USER:$USER /opt/rubies
for command in gem irb rake ruby; do
  ln -s $(which $command$RUBY_MINOR) /opt/rubies/$RUBY_VERSION/bin/$command
done


# write chruby config to .bashrc

cat <<EOF >> ~/.bashrc

# chruby
source /usr/local/share/chruby/chruby.sh
chruby ${RUBY_VERSION}
EOF


# source .bashrc in interactive mode to init chruby
# also temporarily disable nounset and errexit

echo $-
set -i +u +e
echo $-
source ~/.bashrc
set +i -u -e
echo $-

###
# Configure PostgreSQL authentication
###

sudo -u postgres createuser --superuser --createdb entourage || true
sudo sed -i 's|^\(local .*\) peer$|\1 trust|' /etc/postgresql/*/main/pg_hba.conf
sudo sed -i 's|^\(host .*\) md5$|\1 trust|' /etc/postgresql/*/main/pg_hba.conf
sudo service postgresql reload


###
# Setup app
###

cd ~/entourage-ror
echo 'gem: --no-document' >> ~/.gemrc
gem install bundler
bundle install --binstubs --without production
rake db:drop db:create db:migrate
rake RAILS_ENV=test db:drop db:create db:migrate
