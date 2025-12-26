FROM scratch AS ctx
COPY build_files /build_files

FROM quay.io/centos-bootc/centos-bootc:c10s

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/build.sh

RUN rm -rf /var/* && mkdir -m 1777 -p /var/tmp

RUN bootc container lint
