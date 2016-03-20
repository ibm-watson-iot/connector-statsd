FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

# =============================================================================
# Dependencies
# =============================================================================
RUN apt-get -y update
RUN apt-get -y install git wget curl nano supervisor build-essential python-pip python-dev

# =============================================================================
# Watson IoT Statsd Connector module dependencies
# =============================================================================
RUN pip install ibmiotf statsd bottle

# =============================================================================
# Install NodeJS for statsd
# =============================================================================
RUN curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash - &&\
	apt-get install -y nodejs


# =============================================================================
# Install StatsD
# =============================================================================
RUN git clone https://github.com/etsy/statsd.git /src/statsd &&\
    cd /src/statsd &&\
    git checkout v0.7.2

# =============================================================================
# Install IoTF Connector for StatsD
# =============================================================================
ADD connector/connector-statsd.py /opt/connector-statsd/connector-statsd.py


# =============================================================================
# Configuration
# =============================================================================

# Configure StatsD
ADD statsd/config.js /src/statsd/config.js

# Configure supervisord
ADD supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# =============================================================================
# Run
# =============================================================================

CMD     ["/usr/bin/supervisord"]