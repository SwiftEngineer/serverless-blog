#!/bin/sh
wait-for-it.sh ${API_TARGET} -- wait-for-it.sh ${UI_TARGET} -- "$@"