#FROM kohirens/circleci-aws-iac-tf:0.2.0 AS dev
FROM hashicorp/terraform:1.10.2 AS dev
ARG REPO
ARG USER_NAME

COPY --chmod=0775 .docker/start.sh /usr/local/bin/

RUN apk update \
 && apk add aws-cli

#WORKDIR /home/${USER_NAME}/src/${REPO}
WORKDIR /${USER_NAME}/src/${REPO}
ENTRYPOINT [ "start.sh" ]
CMD []
