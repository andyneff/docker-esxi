FROM fedora:27 as stage

SHELL ["/usr/bin/bash", "-euxvc"]

RUN dnf install -y p7zip-plugins glibc.i686 zlib.i686 xz libxml2.i686; \
    dnf clean all

ARG ISO_IMAGE=VMware-VMvisor-Installer-201701001-4887370.x86_64.iso
ADD ${ISO_IMAGE} /esxi.iso

# Extract all the files from the ISO, and gunzip all the zip files 
RUN 7z x /esxi.iso -o/esxi_gzip; \
    # Apparently gzip is super stupid
    zforce /esxi_gzip/* || :; \
    mkdir -p /esxi_gunzip; \
    for x in /esxi_gzip/*.gz; do \
      name="$(gzip -l -N --quiet "${x}" | sed 's| *[0-9]* *[0-9]* *[0-9%.]* ||')"; \
      if [ "${name}" = "/esxi_gzip/" ]; then \
        zcat "${x}" > "/esxi_gunzip/$(basename "${x%.*}")"; \
      else \
        zcat "${x}" > "/esxi_gunzip/$(basename "${x%.*}").$(basename ${name##*.})"; \
      fi; \
    done

# Remove signatures, they just get in the way
RUN for x in /esxi_gunzip/*-psigned; do \
      [ -e "$x" ] || continue; \
      cp ${x} ${x%-psigned}; \
      truncate -s -284 ${x%-psigned}; \
    done

RUN for x in /esxi_gunzip/*.vxz; do \
      [ -e "$x" ] || continue; \
      xzcat "${x}" > "${x%.*}.vtar"; \
    done

ADD extract_vmtar.py /
RUN set +e; \
    for vtar in /esxi_gunzip/S.V00.vtar /esxi_gunzip/S?.V00.vtar; do \
      [ -e "$vtar" ] || continue; \
      python3 extract_vmtar.py "${vtar}" bin/vmtar /usr/bin/vmtar; \
      python3 extract_vmtar.py "${vtar}" sbin/vmtar /usr/bin/vmtar; \
      python3 extract_vmtar.py "${vtar}" lib/libvmlibs.so /lib/libvmlibs.so; \
      python3 extract_vmtar.py "${vtar}" lib/libgcc_s.so.1 /lib/libgcc_s.so.1; \
    done; \
    chmod 755 /usr/bin/vmtar

RUN mkdir -p /esxi_tar/; \
    for x in /esxi_gunzip/*.vtar; do \
      vmtar -x "${x}" -o "/esxi_tar/$(basename "${x%.*}").tar"; \
    done

RUN mkdir -p /esxi; \
    cd /esxi; \
    for x in /esxi_gunzip/*.TGZ /esxi_tar/*.tar; do \
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
