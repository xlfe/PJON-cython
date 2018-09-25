#!/bin/bash

PYTHON="python3"

$PYTHON setup.py clean --all
$PYTHON setup.py build_ext --force
$PYTHON setup.py nosetests --with-doctest --doctest-extension=md