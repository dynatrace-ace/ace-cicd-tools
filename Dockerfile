# 
# Builder
# 
FROM alpine:latest as builder

ARG JMETER_VERSION="5.4.3"
ARG HELM_VERSION="3.7.2"
ARG KEPTN_VERSION="0.17.0"
ARG YQ_VERSION="4.26.1"
ARG MONACO_VERSION="1.6.0"
ARG KUBECTL_VERSION="1.24.3"

RUN apk add --update --no-cache curl

# Download Keptn CLI
RUN curl -sLO https://github.com/keptn/keptn/releases/download/${KEPTN_VERSION}/keptn-${KEPTN_VERSION}-linux-amd64.tar.gz && \
tar -xvf keptn-${KEPTN_VERSION}-linux-amd64.tar.gz && \
mv keptn-${KEPTN_VERSION}-linux-amd64 keptn && \
chmod +x keptn

# Download Helm CLI
RUN curl -sLO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
tar -xvf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
mv linux-amd64/helm helm && \
chmod +x helm

# Download YQ
RUN curl -sLO https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 && \
mv yq_linux_amd64 yq && \
chmod +x yq

# Download kubectl
RUN curl -sLO https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
chmod +x kubectl

# Download JMeter
RUN rm -rf /var/cache/apk/* && \
curl -sLO https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && \
tar -xvf apache-jmeter-${JMETER_VERSION}.tgz && \
mv apache-jmeter-${JMETER_VERSION} apache-jmeter

# Download Monaco
RUN curl -sLO https://github.com/dynatrace-oss/dynatrace-monitoring-as-code/releases/download/v${MONACO_VERSION}/monaco-linux-amd64 && \
mv monaco-linux-amd64 monaco && \
chmod +x monaco

# 
# Runner
# 
FROM alpine:latest
LABEL version="2.2.0"
LABEL maintainer="Dynatrace ACE team<ace@dynatrace.com>"

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
    wget \
    libc6-compat \
    gettext

# Copy bins from builder
COPY --from=builder /keptn /usr/bin/keptn
COPY --from=builder /helm /usr/bin/helm
COPY --from=builder /yq /usr/bin/yq
COPY --from=builder /kubectl /usr/bin/kubectl
COPY --from=builder /monaco /usr/bin/monaco
COPY --from=builder /apache-jmeter /opt/apache-jmeter

# Add JMeter bin to path
ENV	JMETER_BIN /opt/apache-jmeter/bin
ENV PATH $PATH:$JMETER_BIN

CMD ["/bin/bash", "-l", "-c"]
ENTRYPOINT ["/bin/bash", "-l", "-c"]
