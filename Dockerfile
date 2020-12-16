FROM sigost/openhub:openhub_base
ARG GH_TOKEN
ENV GH_TOKEN $GH_TOKEN

USER root
RUN /setup_files.sh

USER serv-deployer
WORKDIR $APP_HOME