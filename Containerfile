FROM scratch AS context
COPY build_files /build_files

FROM quay.io/centos-bootc/centos-bootc:c10s

RUN --mount=type=tmpfs,dst=/opt \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=tmpfs,dst=/usr/share/rpm \
    --mount=type=bind,from=context,source=/,target=/run/context \
    /run/context/build_files/build.sh

RUN bootc container lint
