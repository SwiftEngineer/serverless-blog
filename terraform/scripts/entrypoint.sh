#!/bin/sh
wait-for-it.sh ${API_TARGET} -- "$@"