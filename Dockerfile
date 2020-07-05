FROM debian:buster

# A custom osquery package
COPY osquery_4.4.0-23-gfe2c5a16-1.linux_amd64.deb	/

# Get Current
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https curl cron gnupg dpkg

  # Install FluentBit
RUN curl -L http://packages.fluentbit.io/fluentbit.key | apt-key add -
RUN echo "deb https://packages.fluentbit.io/debian/buster buster main" >> /etc/apt/sources.list
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y td-agent-bit

# Add the Fluentbit configuration
COPY td-agent-bit.conf /etc/td-agent-bit/td-agent-bit.conf

# Install a customized osquery package
RUN apt-get -y install /osquery_4.4.0-23-gfe2c5a16-1.linux_amd64.deb

# Copy OSQuery config
COPY osquery.example.conf /etc/osquery/osquery.conf

# Clean up packages
RUN rm /osquery_4.4.0-23-gfe2c5a16-1.linux_amd64.deb

# create the cron log
RUN touch /var/log/cron.log

# schedule osqueri as a cronjob
COPY osqueri /etc/cron.d/osqueri

# Give execution rights on the cron job
RUN chmod 0744 /etc/cron.d/osqueri

# Apply cron job
RUN crontab /etc/cron.d/osqueri

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

COPY start.sh /start.sh
# Start all the things
CMD ["/bin/bash", "-c", "/start.sh"]

# TODO: Install FluentBit OSQuery Parser
# https://github.com/hidsuzuk/fluent-plugin-osquery

# TODO: W0704 17:38:00.441542 10306 virtual_table.cpp:967] Table file_events is event-based but events are disabled
# W0704 17:38:00.441694 10306 virtual_table.cpp:974] Please see the table documentation: https://osquery.io/schema/#file_events
