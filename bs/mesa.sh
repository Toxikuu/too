#!/bin/bash
upstream="https://mesa.freedesktop.org/"
description="description of package",
dependencies=("xorg-libraries" "libdrm" "mako" "pyyaml" "cbindgen" "rust-bindgen" "rustc" "glslang" "libclc" "libglvnd" "libva" "libvdpau" "llvm" "ply" "vulkan-loader" "wayland-protocols")

NAME="mesa"
VERSION="24.2.1"
URL="https://mesa.freedesktop.org/archive/mesa-24.2.1.tar.xz"
HASH="c50cf79f8ebb6740af8b7a7207310ee1"
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
  mkdir build && cd build &&
    meson setup ..           \
    --prefix=$XORG_PREFIX    \
    --buildtype=release      \
    -D platforms=x11,wayland \
    -D gallium-drivers=auto  \
    -D vulkan-drivers=auto   \
    -D valgrind=disabled     \
    -D libunwind=disabled || t-die "Configuration failed for $XTAR"
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
  t-warn "Cleaning the source directory for $XTAR will make removing it a pain in the dick."
  if t-confirm; then
    rm -rv "$XTAR"
  fi
}

remove() {
  cd "$FXTAR"/build
  t-msg "Running removal steps for $XTAR..."
  if t-installcheck "$NAME"; then
    ninja uninstall # mesa installs so much shit i dont wanna manually track
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
