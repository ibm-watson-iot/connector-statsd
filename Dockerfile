FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

# =============================================================================
# Dependencies
# =============================================================================
RUN apt-get -y update
RUN apt-get -y install git wget curl nano supervisor build-essential python-pip python-dev zip zlib1g-dev libssl-dev

# =============================================================================
# Install updated version of Python
# =============================================================================
RUN cd /usr/src && \
    wget https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz && \
    tar xzf Python-2.7.12.tgz && \
    cd Python-2.7.12 && \
    ./configure && \
    make altinstall

RUN cd /usr/src && \
    wget https://pypi.python.org/packages/source/d/distribute/distribute-0.7.3.zip#md5=c6c59594a7b180af57af8a0cc0cf5b4a && \
    unzip distribute-0.7.3.zip && \
    cd distribute-0.7.3 && \
    python2.7 setup.py install && \
    easy_install-2.7 pip


# =============================================================================
# Watson IoT Statsd Connector module dependencies
# =============================================================================
RUN pip2.7 install ibmiotf==0.2.3 statsd bottle

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
    git checkout v0.7.2

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
