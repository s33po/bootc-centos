FROM scratch AS context
COPY build_files /build_files

FROM quay.io/centos-bootc/centos-bootc:c10s

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/var/tmp \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=bind,from=context,source=/,target=/run/context \
    /run/context/build_files/build.sh

RUN bootc container lint
