# Copyright 2019-2020 The OpenEBS Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This Dockerfile builds upgrade
#
FROM golang:1.13 as build

ARG TARGETPLATFORM

ENV GO111MODULE=on \
  DEBIAN_FRONTEND=noninteractive \
  PATH="/root/go/bin:${PATH}"

WORKDIR /go/src/github.com/openebs/upgrade/

RUN apt-get update && apt-get install -y make git

COPY . .

RUN export GOOS=$(echo ${TARGETPLATFORM} | cut -d / -f1) && \
  export GOARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) && \
  GOARM=$(echo ${TARGETPLATFORM} | cut -d / -f3 | cut -c2-) && \
  make buildx.upgrade

FROM alpine:3.11.5

ARG DBUILD_DATE
ARG DBUILD_REPO_URL
ARG DBUILD_SITE_URL
LABEL org.label-schema.name="upgrade"
LABEL org.label-schema.description="upgrades openebs components"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$DBUILD_DATE
LABEL org.label-schema.vcs-url=$DBUILD_REPO_URL
LABEL org.label-schema.url=$DBUILD_SITE_URL

# copy the latest binary
COPY --from=build /go/src/github.com/openebs/upgrade/bin/upgrade /usr/local/bin/upgrade

ENTRYPOINT ["upgrade"]