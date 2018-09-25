#!/bin/bash

if [[ -n "${PYTHON3}" ]]; then
    PIP="pip3"
    PYTHON="python3"
else
    PIP="pip2"
    PYTHON="python2"
fi

if [[ -n "${FORCE_CYTHON}" ]]; then
    "$PIP" install Cython
fi

"$PYTHON" ./setup.py test