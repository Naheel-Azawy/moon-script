#!/bin/sh

SIZE='1080'
END=14

if [ "$1" ]; then
    [ "$1" = -c ] && {
        rm -rf out
        exit
    }
    XCF="$1"
else
    BIN=$(basename "$0")
    echo "usage: $BIN XCF_FILE"
    echo "       $BIN -c"
    exit 1
fi

rm -rf out

mkdir -p out
mkdir -p out/frames
mkdir -p out/4s

for i in $(seq 1 $END); do
    N=$(printf '%02d' "$i")
    echo "CONVERTING LAYER #$N"
    convert "${XCF}[$i]" \
            -resize "${SIZE}x${SIZE}" \
            "./out/frames/$N.jpg" \
            2>/dev/null || break
done

echo 'BUILDING GIF'
convert ./out/frames/*.jpg \
        -set delay 10 \
        -reverse ./out/frames/*.jpg \
        -set delay 10 \
        -loop 0 \
        ./out/moon.gif

echo 'BUILDING MP4'
# https://unix.stackexchange.com/a/294892/183147
ffmpeg -i ./out/moon.gif \
       -movflags faststart \
       -pix_fmt yuv420p \
       -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
       ./out/moon.mp4

echo 'BUILDING 4S'
(
    cd out/frames
    m() {
        O="$1"; shift
        montage "$@" \
                -resize "${SIZE}x${SIZE}" \
                -mode Concatenate \
                -tile 2x \
                "$O";
    }
    m '../4s/1.jpg' 01.jpg 02.jpg 03.jpg 04.jpg
    m '../4s/2.jpg' 05.jpg 06.jpg 07.jpg 08.jpg
    m '../4s/3.jpg' 09.jpg 10.jpg 11.jpg 12.jpg
    m '../4s/4.jpg' 13.jpg 14.jpg 01.jpg 01.jpg
)

