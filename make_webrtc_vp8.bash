#!/bin/bash
ffmpeg -y -i $1 \
  -c:v vp8 \
  -an \
  $2

# -c:a libopus \
