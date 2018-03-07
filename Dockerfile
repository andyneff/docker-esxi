FROM fedora:27 as stage

ADD VMware-VMvisor-Installer-201701001-4887370.x86_64.iso /esxi.iso

SHELL ["/usr/bin/bash", "-euxvc"]

RUN dnf install -y p7zip-plugins glibc.i686 zlib.i686 xz; \
    dnf clean all

RUN 7z x /esxi.iso -o/esxi_gzip; \
    # Apparently gzip is super stupid
    zforce /esxi_gzip/* || :; \
    # Uses someone else's name!
    gunzip -N /esxi_gzip/VSANHEAL.V00.gz; \
    mv /esxi_gzip/vsanhealth.vtar /esxi_gzip/vsanheal.vtar; \
    # Extract, using the original names or use zip filename
    gunzip -N /esxi_gzip/*.gz || gunzip /esxi_gzip/*.gz

RUN for x in /esxi_gzip/*-psigned; do \
      cp ${x} ${x%-psigned}; \
      truncate -s -284 ${x%-psigned}; \
    done

RUN for x in /esxi_gzip/*.vxz; do \
      xzcat "${x}" > "${x%.*}.vtar"; \
    done

ADD extract_vmtar.py /
RUN python3 extract_vmtar.py /esxi_gzip/vmvisor-sys-boot.vtar bin/vmtar /usr/bin/vmtar; \
    chmod 755 /usr/bin/vmtar

RUN mkdir -p /esxi_tar/; \
    for x in /esxi_gzip/*.vtar; do \
      vmtar -x "${x}" -o "/esxi_tar/$(basename "${x%.*}").tar"; \
    done

RUN mkdir -p /esxi; \
    cd /esxi; \
    for x in /esxi_gzip/*.TGZ /esxi_tar/*.tar; do \
      tar xf "${x}"; \
    done

FROM scratch

COPY --from=stage /esxi /

ENV MAIL=/var/mail/root \
    PATH=/bin:/sbin \
    TERMINFO=/usr/share/terminfo \
    TERM=xterm-256color \
    TMOUT=0

ENTRYPOINT []

CMD /bin/sh
