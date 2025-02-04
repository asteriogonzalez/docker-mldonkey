FROM debian:buster AS builder

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends git build-essential \
        autoconf wget libz-dev libbz2-dev libmagic-dev libnatpmp-dev \
        libupnp-dev libgd-dev ca-certificates ocaml camlp4 ocaml-compiler-libs ocaml-nox \
        libminiupnpc-dev librsvg2-dev libgtk2.0-dev liblablgtk2-ocaml-dev liblablgtk2-gl-ocaml-dev liblablgtk2-gnome-ocaml-dev && \
    git clone https://github.com/carlonluca/mldonkey.git && \
    cd mldonkey && \
    #git checkout no-cl-dup && \
    mkdir -p patches && \
    ./configure --prefix=$PWD/out --enable-batch --enable-upnp-natpmp --disable-gnutella --disable-gnutella2 --enable-gui=newgui2 && \
    make -j1 && \
    make install

FROM debian:buster

RUN \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install --no-install-recommends -y \
        zlib1g libbz2-1.0 libmagic1 libgd3 netcat \
        libnatpmp1 libupnp13 libminiupnpc17 librsvg2-2 librsvg2-common \
        libgtk2.0-0 libgtk2.0-common \
        liblablgtk2-ocaml liblablgtk2-gl-ocaml liblablgtk2-gnome-ocaml && \
    apt-get -y --purge autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/mldonkey && \
    rm -rf /var/lib/mldonkey && \
    mkdir -p /var/lib/mldonkey && \
    mkdir /usr/lib/mldonkey/

RUN useradd -ms /bin/bash mldonkey

COPY --from=builder /mldonkey/out/bin/* /usr/bin/
COPY --from=builder /mldonkey/distrib/mldonkey_command /usr/lib/mldonkey/

ENV MLDONKEY_DIR=/var/lib/mldonkey LC_ALL=C.UTF-8 LANG=C.UTF-8
VOLUME ["/var/lib/mldonkey", "/var/lib/mldonkey/temp"]
EXPOSE 4000 4001 4080 19040 19044
ADD entrypoint.sh /
CMD /entrypoint.sh
