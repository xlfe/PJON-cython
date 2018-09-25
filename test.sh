#!/bin/bash

$(which python) setup.py clean --all
$(which python) setup.py build_ext --force
$(which python) setup.py nosetests --with-doctest --doctest-extension=md