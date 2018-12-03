FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

# =============================================================================
# Dependencies
# =============================================================================
RUN apt-get -y update && \
    apt-get -y install sudo git wget curl nano supervisor build-essential \
               python-pip python-dev zip zlib1g-dev libssl-dev

# =============================================================================
# Watson IoT Statsd Connector module dependencies
# =============================================================================
RUN pip install ibmiotf==0.2.3 statsd bottle

# =============================================================================
# Install NodeJS for statsd
# =============================================================================
RUN curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash - && \
    apt-get install -y nodejs

# =============================================================================
# Install StatsD
# =============================================================================
RUN git clone https://github.com/etsy/statsd.git /src/statsd && \
    cd /src/statsd && \
    git checkout v0.8.0

# =============================================================================
# Install IoTF Connector for StatsD
# =============================================================================
ADD connector /opt/connector-statsd/

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
