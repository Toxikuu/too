#!/bin/bash
upstream="https://gitlab.freedesktop.org/libinput/libinput"
description="input device library",
dependencies=("libevdev" "mtdev")

NAME="libinput"
VERSION="1.26.2"
URL="https://gitlab.freedesktop.org/libinput/libinput/-/archive/1.26.2/libinput-1.26.2.tar.gz"
HASH="65bfce1b15c7b2375d4df4f390a9233f"
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
  mkdir build && cd build
  meson setup --prefix=$XORG_PREFIX       \
              --buildtype=release         \
              -D debug-gui=false          \
              -D tests=false              \
              -D libwacom=false           \
              -D udev-dir=/usr/lib/udev   \
              .. || t-die "Configuration failed for $XTAR"
}

build() {
  cd "$FXTAR"/build
  t-msg "Running build steps for $XTAR..."
  ninja || t-die "Build failed for $XTAR"
}

check() {
  cd "$FXTAR"/build
  t-msg "Running check steps for $XTAR..."
  t-msg "Tests not implemented for $XTAR"
}

install() {
  cd "$FXTAR"/build
  if t-installcheck "$NAME" > /dev/null; then
    t-die "$XTAR already installed"
  else
    t-msg "Running install steps for $XTAR..."
    ninja install || t-die "Install failed for $XTAR"
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
    rm -v /usr/bin/libinput
    rm -v /usr/lib/libinput.so*
    rm -rv /usr/share/libinput
    rm -v /usr/lib/udev/libinput*
    rm -rv /usr/libexec/libinput/
    rm -v /usr/include/libinput.h
    rm -rv /etc/libinput
    rm -v /usr/lib/udev/rules.d/{90-libinput-fuzz-override.rules,80-libinput-device-groups.rules}
    rm -v /usr/lib/pkgconfig/libinput.pc
    rm -v /usr/share/zsh/site-functions/_libinput
    rm -v /usr/share/man/man1/libinput*
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
