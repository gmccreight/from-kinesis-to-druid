#!/bin/bash

# from-kinesis requires these packages:

sudo apt-get install gcc patch git ruby rake rubygems ruby-dev

sudo gem install aws-sdk

# to-druid requires these packages:

# Tranquility requires Java
sudo apt-get install default-jre -y

# The generate-example-metrics script is written in Python
sudo apt-get install python -y

cat << EOT > /tmp/start-tranquility.sh
#!/bin/bash

( date
  set -x
  cd /app/to-druid/tranquility-distribution-0.8.0
  pwd
  ls -l
  ls -l /app
  ls -l /app/to-druid
  bin/tranquility server -configFile ../tranquility-server-conf-from-druid-quickstart.json ) >> /var/log/tranquility.log 2>&1
EOT

sudo cp /tmp/start-tranquility.sh /usr/local/bin/start-tranquility
sudo chmod +x /usr/local/bin/start-tranquility

cat << EOT > /tmp/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

sleep 60
exec /usr/local/bin/start-tranquility
EOT

sudo cp /tmp/rc.local /etc
sudo chmod +x /etc/rc.local
