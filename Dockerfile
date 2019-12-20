FROM jenkins/jenkins

MAINTAINER Thomas Johansen "thomas.johansen@accenture.com"

# Build args
ARG MAVEN_VERSION="3.6.3"
ARG DOCKER_COMPOSE_VERSION="1.25.0"

# Environment variables
ENV MAVEN_HOME "/opt/maven/default"
ENV M2_HOME "${MAVEN_HOME}"
ENV PATH "${PATH}:${MAVEN_HOME}/bin"

# Run the following commands as root
USER root

# Install Apache Maven
RUN wget --no-cookies --no-check-certificate "https://www.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" -O /tmp/maven.tar.gz && \
    wget --no-cookies --no-check-certificate "https://www.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz.asc" -O /tmp/maven.tar.gz.asc && \
    wget --no-cookies --no-check-certificate "https://www.apache.org/dist/maven/KEYS" -O /tmp/maven.KEYS && \
    gpg --import /tmp/maven.KEYS && \
    gpg --verify /tmp/maven.tar.gz.asc /tmp/maven.tar.gz && \
    mkdir /opt/maven && \
    tar -xzvf /tmp/maven.tar.gz -C /opt/maven/ && \
    cd /opt/maven && \
    ln -s apache-maven-${MAVEN_VERSION}/ default && \
    rm -f /tmp/maven.* && \
    update-alternatives --install "/usr/bin/mvn" "mvn" "/opt/maven/default/bin/mvn" 1 && \
    update-alternatives --set "mvn" "/opt/maven/default/bin/mvn"

# Install Docker
RUN apt-get update && \
    apt-get -y install apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/docker-key; apt-key add /tmp/docker-key && \
    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" && \
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
