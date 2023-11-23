FROM kohirens/circleci-aws-iac-tf:0.2.0 AS dev

ARG REPO
ARG USER_NAME

COPY --chmod=0775 .docker/start.sh /usr/local/bin/

WORKDIR /home/${USER_NAME}/src/${REPO}

ENTRYPOINT [ "start.sh" ]
