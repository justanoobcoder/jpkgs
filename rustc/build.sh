#!/bin/bash
set -e

cat << EOF > bootstrap.toml
change-id = 148795

[llvm]
link-shared = true
targets = "X86"

[build]
description = "for BLFS 13.0"
docs = false
locked-deps = true
tools = ["cargo", "clippy", "rustdoc", "rustfmt", "src"]

[install]
prefix = "/opt/rustc-1.93.1"
docdir = "share/doc/rustc-1.93.1"

[rust]
channel = "stable"
lto = "thin"
codegen-units = 1
llvm-bitcode-linker = false

[target.x86_64-unknown-linux-gnu]
llvm-config = "/usr/bin/llvm-config"
EOF

export LIBSSH2_SYS_USE_PKG_CONFIG=1
export LIBSQLITE3_SYS_USE_PKG_CONFIG=1

./x.py build

./x.py install

ln -svfn rustc-1.93.1 "$DESTDIR/opt/rustc"

rm -fv "$DESTDIR/opt/rustc-1.93.1/share/doc/rustc-1.93.1"/*.old
install -vm644 README.md "$DESTDIR/opt/rustc-1.93.1/share/doc/rustc-1.93.1"

install -vdm755 "$DESTDIR/usr/share/zsh/site-functions"
ln -sfv /opt/rustc/share/zsh/site-functions/_cargo \
        "$DESTDIR/usr/share/zsh/site-functions/_cargo"

mkdir -p "$DESTDIR/usr/share/bash-completion/completions"
mv -v "$DESTDIR/etc/bash_completion.d/cargo" \
      "$DESTDIR/usr/share/bash-completion/completions/cargo"

mkdir -p "$DESTDIR/etc/profile.d"
cat > "$DESTDIR/etc/profile.d/rustc.sh" << "PROFILE"
# Begin /etc/profile.d/rustc.sh
pathprepend /opt/rustc/bin PATH
# End /etc/profile.d/rustc.sh
PROFILE
