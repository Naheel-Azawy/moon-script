#!/bin/sh

[ ! -d out/frames ] && {
    echo 'run ./build.sh first'
    exit 1
}

DELAY=0.05

a() { jp2a --fill "$1"; }
e() { sleep "$DELAY"; printf '\033[0;0H'; }

cd out/frames
while :; do
    for f in $(ls -1); do
        a "$f"; e
    done
    for f in $(ls -1r); do
        a "$f"; e
    done
done
