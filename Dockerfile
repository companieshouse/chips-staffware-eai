FROM 300288021642.dkr.ecr.eu-west-2.amazonaws.com/ch-serverjre:1.2.5

RUN yum -y install gettext && \
    yum clean all && \
    rm -rf /var/cache/yum

ENV EAI_HOME=/eai \
    ARTIFACTORY_BASE_URL=https://artifactory.companieshouse.gov.uk/artifactory/virtual-release

# Add an sso user and home directory
RUN mkdir -p ${EAI_HOME} && \
    useradd -d ${EAI_HOME} -m -s /bin/bash eai && \
    chown eai ${EAI_HOME}

USER eai
WORKDIR ${EAI_HOME}

# Copy over scripts and properties
COPY --chown=eai eaidaemon ${EAI_HOME}/

# Download the Staffware libs and set permission on script
RUN mkdir -p ${EAI_HOME}/libs && \
    cd ${EAI_HOME}/libs && \
    curl ${ARTIFACTORY_BASE_URL}/oracle/AQ/unknown/AQ-unknown.jar -o aqapi12.jar && \
    curl ${ARTIFACTORY_BASE_URL}/uk/gov/companieshouse/chips-aqbridge/1.104.0-rc1/chips-aqbridge-1.104.0-rc1.jar -o aqbridge.jar && \
    curl ${ARTIFACTORY_BASE_URL}/log4j/log4j/1.2.14/log4j-1.2.14.jar -o log4j.jar && \
    curl ${ARTIFACTORY_BASE_URL}/com/oracle/ojdbc8/12.2.1.4/ojdbc8-12.2.1.4.jar -o ojdbc8.jar && \
    curl ${ARTIFACTORY_BASE_URL}/com/oracle/weblogic/wlthint3client/12.2.1.4/wlthint3client-12.2.1.4.jar -o wlthint3client.jar && \
    chmod 750 ${EAI_HOME}/*.sh

CMD ["bash"]
