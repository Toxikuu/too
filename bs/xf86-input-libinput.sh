#!/bin/bash
upstream="http://xorg.freedesktop.org/"
description="libinput wrapper for xorg",
dependencies=("libinput" "xorg-server") 

NAME="xf86-input-libinput"
VERSION="1.4.0"
URL="https://www.x.org/pub/individual/driver/xf86-input-libinput-1.4.0.tar.xz"
HASH="b52a1fc7456cf6595a9a1004287551a3"
HASH_TYPE="md5"

EXTENSION=$(t-getext "$URL")
XTAR="$NAME-$VERSION"
TARBALL="$XTAR.$EXTENSION"
FXTAR="/t/src/$XTAR"

pushd /t/src/ > /dev/null
pull() {
  t-msg "Pulling $TARBALL from $URL..."
  wget "$URL" -O "$TARBALL" || t-die "Failed to pull $TARBALL from $URL"
}

setup() {
  t-msg "Running setup steps for $XTAR..."
  t-detar "$TARBALL" "$HASH" "$HASH_TYPE" "$XTAR" || t-die "Failed to detar $TARBALL"
}

configure() {
  cd "$FXTAR"
  t-msg "Running configuration steps for $XTAR..."
  ./configure $XORG_CONFIG || t-die "Configuration failed for $XTAR"
}

build() {
  cd "$FXTAR"
  t-msg "Running build steps for $XTAR..."
  make || t-die "Build failed for $XTAR"
}

check() {
  cd "$FXTAR"
  t-msg "Running check steps for $XTAR..."
  t-msg "Tests not implemented for $XTAR"
}

install() {
  cd "$FXTAR"
  if t-installcheck "$NAME" > /dev/null; then
    t-die "$XTAR already installed"
  else
    t-msg "Running install steps for $XTAR..."
    make install || t-die "Install failed for $XTAR"
    echo "$NAME" >> /t/meta/installed.too
  fi
}

cleanup() {
  cd "$FXTAR"/..
  t-msg "Running cleanup steps for $XTAR..."
  rm -rv "$XTAR"
}

remove() {
  t-msg "Running removal steps for $XTAR..."
  if t-installcheck "$NAME"; then
    rm -v /usr/include/xorg/libinput-properties.h
    rm -v /usr/share/man/man4/libinput.4
    rm -v /usr/share/X11/xorg.conf.d/40-libinput.conf
    rm -v /usr/lib/pkgconfig/xorg-libinput.pc
    sed -i "/\b$NAME\b/d" /t/meta/installed.too
  else
    t-die "Removal failed for $XTAR"
  fi
}

update() {
  cd "$FXTAR"
  t-msg "Running update steps for $XTAR..."
  cleanup
  remove && pull && setup && configure && build && check && install && cleanup
}

while getopts "pscbkiCru" opt; do
  case $opt in
    p) pull      || t-die "Exiting because of errors" ;;
    s) setup     || t-die "Exiting because of errors" ;;
    c) configure || t-die "Exiting because of errors" ;;
    b) build     || t-die "Exiting because of errors" ;;
    k) check     || t-die "Exiting because of errors" ;;
    i) install   || t-die "Exiting because of errors" ;;
    C) cleanup   || t-die "Exiting because of errors" ;;
    r) remove    || t-die "Exiting because of errors" ;;
    u) update    || t-die "Exiting because of errors" ;;        
    \?) echo "Invalid option: -$OPTARG" ;;
  esac
done
shift $((OPTIND - 1))
popd > /dev/null
