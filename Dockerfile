FROM ubuntu:16.04

# Get add-apt-repository
RUN apt-get update \
  && apt-get install -y software-properties-common \
  && apt-get install apt-transport-https

ENV OSQUERY_GPG_KEY=1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys $OSQUERY_GPG_KEY
RUN add-apt-repository -y 'deb [arch=amd64] https://pkg.osquery.io/deb deb main'
RUN apt-get -y update
RUN apt-get -y install osquery curl

# debconf: delaying package configuration, since apt-utils is not installed
# do we need it? ¯\_(ツ)_/¯

# Copy the default osquery.conf (However, a custom conf should be specified
# with `docker run -v osquery.conf:/etc/osquery.conf ...`

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
# RUN fluentd -c /fluentd.conf -v
# bespoke configuration ^^

# RunOSQuery
CMD ["/usr/bin/osqueryd", "--config_path=/etc/osquery/osquery.conf", "--verbose"]