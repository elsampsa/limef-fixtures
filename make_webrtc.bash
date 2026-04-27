#!/bin/bash
ffmpeg -y -i $1 \
  -c:v libx264 \
  -profile:v baseline \
  -level:v 3.1 \
  -x264-params "constrained-intra=1:ref=1:no-8x8dct=1:bframes=0:weightp=0" \
  -pix_fmt yuv420p \
  -an \
  -bsf:v h264_mp4toannexb \
  -flags +global_header \
  $2
