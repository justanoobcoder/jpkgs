#!/bin/bash
set -e

DEST="${DESTDIR}/usr/share/xml/docbook/xml-dtd-4.5"
ETC="${DESTDIR}/etc/xml"

install -v -d -m755 "$DEST"
install -v -d -m755 "$ETC"

cp -v -af --no-preserve=ownership \
    catalog.xml docbook.cat *.dtd ent/ *.mod \
    "$DEST"

xmlcatalog --noout --add "rewriteSystem" \
    "http://www.oasis-open.org/docbook/xml/4.5" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    "$DEST/catalog.xml"

xmlcatalog --noout --add "rewriteURI" \
    "http://www.oasis-open.org/docbook/xml/4.5" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    "$DEST/catalog.xml"

if [ ! -e "$ETC/catalog" ]; then
    xmlcatalog --noout --create "$ETC/catalog"
fi

xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//ENTITIES DocBook XML" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/catalog.xml" \
    "$ETC/catalog"

xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//DTD DocBook XML" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/catalog.xml" \
    "$ETC/catalog"

xmlcatalog --noout --add "delegateSystem" \
    "http://www.oasis-open.org/docbook/" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/catalog.xml" \
    "$ETC/catalog"

xmlcatalog --noout --add "delegateURI" \
    "http://www.oasis-open.org/docbook/" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/catalog.xml" \
    "$ETC/catalog"

for DTDVERSION in 4.1.2 4.2 4.3 4.4; do
    xmlcatalog --noout --add "public" \
        "-//OASIS//DTD DocBook XML V${DTDVERSION}//EN" \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}/docbookx.dtd" \
        "$DEST/catalog.xml"

    xmlcatalog --noout --add "rewriteSystem" \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}" \
        "file:///usr/share/xml/docbook/xml-dtd-4.5" \
        "$DEST/catalog.xml"

    xmlcatalog --noout --add "rewriteURI" \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}" \
        "file:///usr/share/xml/docbook/xml-dtd-4.5" \
        "$DEST/catalog.xml"
done
