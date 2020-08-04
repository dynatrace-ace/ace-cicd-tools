FROM alpine:latest
LABEL version="1.0" maintainer="Dynatrace ACE team <ace@dynatrace.com>"


ARG JMETER_VERSION="5.2.1"
ARG HELM_VERSION="3.2.4"
ARG KEPTN_VERSION="0.7.0"
ARG YQ_VERSION="3.3.2"
ENV HELM_BASE_URL https://get.helm.sh
ENV HELM_TAR_FILE helm-${HELM_VERSION}-linux-amd64.tar.gz
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz


# Installing tools and adding helm
# RUN apk add --update --no-cache \
#     curl \
#     jq \
#     ca-certificates \
#     bash \
#     python3 python3-dev \
#     groff \
#     gcc \
#     libc-dev linux-headers libffi-dev \
#     openssl-dev \
#     grep \
#     jpeg-dev \
#     zlib-dev \
#     freetype-dev \
#     lcms2-dev \
#     openjpeg-dev \
#     tiff-dev \
#     tk-dev \
#     tcl-dev \
#     harfbuzz-dev \
#     fribidi-dev \
#     nss \
#     openjdk8-jre \
#     unzip \
#     util-linux \
#     wget 

RUN apk add --update --no-cache \
    curl \
    jq \
    ca-certificates \
    bash \
    python3 python3-dev \
    groff \
    gcc \
    libc-dev linux-headers libffi-dev \
    openssl-dev \
    grep \
    nss \
    openjdk8-jre \
    unzip \
    util-linux \
    wget 

# Download and install keptn cli
RUN curl -LO https://github.com/keptn/keptn/releases/download/${KEPTN_VERSION}/${KEPTN_VERSION}_keptn-linux.tar && \
    tar -xvf ${KEPTN_VERSION}_keptn-linux.tar && chmod +x keptn && mv keptn /usr/bin/ 

# Download and install helm
RUN wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

# Download and install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && mv ./kubectl /usr/bin/kubectl

RUN curl -sL https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -o /usr/bin/yq
RUN chmod +x /usr/bin/yq

# Installing Jmeter
RUN rm -rf /var/cache/apk/* \
    && mkdir -p /tmp/dependencies \
    && curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
    && mkdir -p /opt \
    && tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
    && rm -rf /tmp/dependencies

#Install DT Monitoring as Code
COPY self-monitoring-1.1.0 /usr/local/bin/self-monitoring
RUN chmod +x /usr/local/bin/self-monitoring

ENV PATH $PATH:$JMETER_BIN

CMD ["/bin/bash", "-l", "-c"]
ENTRYPOINT ["/bin/bash", "-l", "-c"]
