#!/bin/bash
ffmpeg -y -i $1 \
  -c:v vp9 \
  -an \
  $2

# -c:a libopus \
