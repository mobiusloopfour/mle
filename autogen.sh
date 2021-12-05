#!/bin/sh
aclocal
automake --add-missing
autoreconf --install || exit 1
