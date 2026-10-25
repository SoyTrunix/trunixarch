#!/bin/bash
# Toggle gsimplecal: close it if already open, otherwise open near the clock.
if pgrep -x gsimplecal > /dev/null; then
    pkill -x gsimplecal
else
    gsimplecal &
fi
