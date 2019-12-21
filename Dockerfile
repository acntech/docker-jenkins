FROM jenkins/jenkins

MAINTAINER Thomas Johansen "thomas.johansen@accenture.com"

# Build args
ARG MAVEN_VERSION="3.6.3"
ARG NODE_MAIN_VERSION="12"
ARG DOCKER_COMPOSE_VERSION="1.25.0"

# Environment variables
ENV MAVEN_HOME "/opt/maven/default"
ENV M2_HOME "${MAVEN_HOME}"
ENV PATH "${PATH}:${MAVEN_HOME}/bin"

# Run the following commands as root
USER root

# Install common tools
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    curl

# Install Apache Maven
RUN curl -L "https://www.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
         -o /tmp/maven.tar.gz && \
    curl -L "https://www.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz.asc" \
         -o /tmp/maven.tar.gz.asc && \
    curl -L "https://www.apache.org/dist/maven/KEYS" -o /tmp/maven.KEYS && \
    gpg --import /tmp/maven.KEYS && \
    gpg --verify /tmp/maven.tar.gz.asc /tmp/maven.tar.gz && \
    mkdir /opt/maven && \
    tar -xzvf /tmp/maven.tar.gz -C /opt/maven/ && \
    cd /opt/maven && \
    ln -s apache-maven-${MAVEN_VERSION}/ default && \
    rm -f /tmp/maven.* && \
    update-alternatives --install "/usr/bin/mvn" "mvn" "/opt/maven/default/bin/mvn" 1 && \
    update-alternatives --set "mvn" "/opt/maven/default/bin/mvn"

# Install NodeJS
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    add-apt-repository "deb https://deb.nodesource.com/node_${NODE_MAIN_VERSION}.x $(lsb_release -cs) main" && \
    add-apt-repository "deb https://dl.yarnpkg.com/debian stable main" && \
    apt-get update && \
    apt-get -y install nodejs yarn

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get -y install docker-ce

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
         -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Add jenkins user to docker group
RUN usermod -a -G docker jenkins

# Change back to application user
USER jenkins
