#!/bin/bash
set -e

DEST="${DESTDIR}/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2"
DOC="${DESTDIR}/usr/share/doc/docbook-xsl-nons-1.79.2"

install -v -m755 -d "$DEST"

cp -v -R VERSION assembly common eclipse epub epub3 extensions fo \
    highlighting html htmlhelp images javahelp lib manpages params \
    profiling roundtrip slides template tests tools webhelp website \
    xhtml xhtml-1_1 xhtml5 \
    "$DEST"

ln -svf VERSION "$DEST/VERSION.xsl"

install -v -m644 -D README "$DOC/README.txt"
install -v -m644 RELEASE-NOTES* NEWS* "$DOC"

install -v -d -m755 "${DESTDIR}/etc/xml"
if [ ! -e "${DESTDIR}/etc/xml/catalog" ]; then
    xmlcatalog --noout --create "${DESTDIR}/etc/xml/catalog"
fi

for uri in \
    "http://cdn.docbook.org/release/xsl-nons/1.79.2" \
    "https://cdn.docbook.org/release/xsl-nons/1.79.2" \
    "http://cdn.docbook.org/release/xsl-nons/current" \
    "https://cdn.docbook.org/release/xsl-nons/current" \
    "http://docbook.sourceforge.net/release/xsl/current"
do
    xmlcatalog --noout --add "rewriteSystem" \
        "$uri" \
        "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
        "${DESTDIR}/etc/xml/catalog"

    xmlcatalog --noout --add "rewriteURI" \
        "$uri" \
        "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
        "${DESTDIR}/etc/xml/catalog"
done
