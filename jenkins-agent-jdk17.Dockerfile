FROM jenkins/inbound-agent:latest-jdk17

USER root

RUN apt-get update \
    && apt-get --yes --no-install-recommends install sudo wget curl pylint nodejs gpg \
    && apt-get clean \
    && rm -rf /tmp/* /var/cache/* /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -


ENV HELM_VERSION v3.7.1
RUN set -xe \
    && curl -LO https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && tar -xzf helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64 /usr/local/share/helm-${HELM_VERSION} \
    && ln -s /usr/local/share/helm-${HELM_VERSION}/helm /usr/local/bin

RUN curl -LO https://dl.k8s.io/release/v1.22.0/bin/linux/amd64/kubectl  \
    && chmod 755 kubectl \
    && mv kubectl /usr/bin/kubectl


RUN apt-get update \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

RUN echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN usermod -aG docker jenkins && usermod -aG sudo jenkins
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN mkdir -p /var/run/docker && chmod 777 /var/run/docker

USER jenkins
LABEL \
    com.thermofisher.repository.name="dsbu-devops-util" \
    com.thermofisher.repository.branch="KMSDEVOPS-649" \
    com.thermofisher.team="ThisIsFine"

COPY dockerd-entrypoint.sh /usr/local/bin/dockerd-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/dockerd-entrypoint.sh"]
