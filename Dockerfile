FROM 300288021642.dkr.ecr.eu-west-2.amazonaws.com/ch-serverjre:2.0.0 AS builder

ARG ARTIFACTORY_URL
ARG ARTIFACTORY_USERNAME
ARG ARTIFACTORY_PASSWORD

ENV EAI_HOME=/eai \
    ARTIFACTORY_BASE_URL=${ARTIFACTORY_URL}/virtual-release

# Add an eai user and home directory
RUN useradd -d ${EAI_HOME} -m -s /bin/bash eai

USER eai

# Copy over scripts and properties
COPY --chown=eai eaidaemon ${EAI_HOME}/

# Download the Staffware libs and set permissions on scripts
RUN mkdir -p ${EAI_HOME}/libs && \
    cd ${EAI_HOME}/libs && \
    curl -L -u "${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}" ${ARTIFACTORY_BASE_URL}/oracle/AQ/unknown/AQ-unknown.jar -o aqapi12.jar && \
    curl -L -u "${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}" ${ARTIFACTORY_BASE_URL}/uk/gov/companieshouse/chips-aqbridge/1.104.0-rc1/chips-aqbridge-1.104.0-rc1.jar -o aqbridge.jar && \
    curl -L -u "${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}" ${ARTIFACTORY_BASE_URL}/log4j/log4j/1.2.14/log4j-1.2.14.jar -o log4j.jar && \
    curl -L -u "${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}" ${ARTIFACTORY_BASE_URL}/com/oracle/database/jdbc/ojdbc11/23.9.0.25.07/ojdbc11-23.9.0.25.07.jar -o ojdbc11.jar && \
    curl -L -u "${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}" ${ARTIFACTORY_BASE_URL}/com/oracle/weblogic/wlthint3client/14.1.2.0/wlthint3client-14.1.2.0.jar -o wlthint3client.jar && \
    chmod 500 ${EAI_HOME}/*.sh

FROM 300288021642.dkr.ecr.eu-west-2.amazonaws.com/ch-serverjre:2.0.0

ENV EAI_HOME=/eai

# Install binaries as root
RUN yum -y install gettext && \
    yum clean all && \
    rm -rf /var/cache/yum

# Add an eai user
RUN useradd -d ${EAI_HOME} -m -s /bin/bash eai

# Copy over the home directory from the builder
COPY --from=builder --chown=eai ${EAI_HOME} ${EAI_HOME}/

USER eai
WORKDIR ${EAI_HOME}

CMD ["bash"]
