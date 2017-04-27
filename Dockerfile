FROM acntechie/maven:latest
MAINTAINER Thomas Johansen "thomas.johansen@accenture.com"


ARG JENKINS_VERSION=2.46.2
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war
ARG JENKINS_SHA=33a3f4d983c6188a332291e1d974afa0a2ee96a0ae3cb6dd4f2098086525f9f1
ARG JENKINS_USER=jenkins
ARG JENKINS_GROUP=jenkins
ARG JENKINS_UID=1000
ARG JENKINS_GID=1000
ARG TINI_VERSION=0.14.0
ARG TINI_SHA=6c41ec7d33e857d4779f14d9c74924cab0c7973485d2972419a3b7c7620ff5fd
ARG TINI_URL=https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64
ARG JENKINS_DOCKER_URL=https://raw.githubusercontent.com/jenkinsci/docker/master


ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SHARE /usr/share/jenkins
ENV JENKINS_SLAVE_AGENT_PORT 50000
ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_VERSION ${JENKINS_VERSION}
ENV COPY_REFERENCE_FILE_LOG ${JENKINS_HOME}/copy_reference_file.log


ADD ${JENKINS_DOCKER_URL}/jenkins-support /usr/local/bin/jenkins-support
ADD ${JENKINS_DOCKER_URL}/jenkins.sh /usr/local/bin/jenkins.sh
ADD ${JENKINS_DOCKER_URL}/plugins.sh /usr/local/bin/plugins.sh
ADD ${JENKINS_DOCKER_URL}/install-plugins.sh /usr/local/bin/install-plugins.sh
ADD ${JENKINS_DOCKER_URL}/init.groovy ${JENKINS_SHARE}/ref/init.groovy.d/tcp-slave-agent-port.groovy


RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y git curl && \
    rm -rf /var/lib/apt/lists/*

RUN wget --no-cookies \
         --no-check-certificate \
         ${TINI_URL} \
         -O /bin/tini

RUN echo "${TINI_SHA} /bin/tini" | sha256sum -c -

RUN groupadd -g ${JENKINS_GID} ${JENKINS_GROUP} && \
    useradd -d ${JENKINS_HOME} -u ${JENKINS_UID} -g ${JENKINS_GID} -m -s /bin/bash ${JENKINS_USER}

RUN mkdir -p ${JENKINS_SHARE}/ref/init.groovy.d

RUN wget --no-cookies \
         --no-check-certificate \
         ${JENKINS_URL} \
         -O ${JENKINS_SHARE}/jenkins.war

RUN echo "${JENKINS_SHA} ${JENKINS_SHARE}/jenkins.war" | sha256sum -c -

RUN chown -R ${JENKINS_USER}:${JENKINS_GROUP} \
          ${JENKINS_HOME} \
          ${JENKINS_SHARE} \
          /usr/local/bin/jenkins-support \
          /usr/local/bin/jenkins.sh \
          /usr/local/bin/plugins.sh \
          /usr/local/bin/install-plugins.sh

RUN chmod +x /bin/tini \
             /usr/local/bin/jenkins-support \
             /usr/local/bin/jenkins.sh \
             /usr/local/bin/plugins.sh \
             /usr/local/bin/install-plugins.sh


USER ${JENKINS_USER}


EXPOSE 8080 50000


WORKDIR ${JENKINS_HOME}


VOLUME ${JENKINS_HOME}


ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
