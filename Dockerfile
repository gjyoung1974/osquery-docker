FROM ubuntu:18.04

# Copy a custom osquery package
COPY osquery_4.4.0-23-gfe2c5a16-1.linux_amd64.deb	/

# Get Current
RUN apt-get update \
  && apt-get install -y software-properties-common \
  && apt-get install -y apt-transport-https curl

# Install a customized osquery package
RUN apt-get -y install /osquery_4.4.0-23-gfe2c5a16-1.linux_amd64.deb

# debconf: delaying package configuration, since apt-utils is not installed
# do we need it? ¯\_(ツ)_/¯

# Base configuration
COPY osquery.example.conf /etc/osquery/osquery.conf
COPY extensions.load /etc/osquery/extensions.load
ADD ./fluentd.sh   /
ADD ./fluentd.conf   /
RUN bash -c "/fluentd.sh"

# Compliance checks for linux
COPY it-compliance.conf /etc/osquery/it-compliance.conf
# OSSEC RootKit checks translated to OSQuery
COPY ossec-rootkit.conf /etc/osquery/ossec-rootkit.conf
# Harvest vulnerabilties from pods at runtime
COPY vuln-management.conf /etc/osquery/vuln-management.conf
# File Integrity Monitoring for Linux Hosts
COPY file-integrity.conf /etc/osquery/file-integrity.conf

# Clean up packages
RUN rm /osquery_4.4.0-23-gfe2c5a16-1.linux_amd64.deb

# TODO: add the fluentd daemon
# RUN fluentd -c /fluentd.conf -v
# bespoke configuration ^^

# RunOSQuery
CMD ["/usr/bin/osqueryd", "--config_path=/etc/osquery/osquery.conf", "--verbose"]
