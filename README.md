# clingo-docker

Build image with:

    $ docker build --build-arg http_proxy=$HTTP_PROXY --build-arg https_proxy=$HTTPS_PROXY -t svidela/clingo:4.5.4 .

Compiled binaries for gringo, clingo (with python, lua and multi-threading) and reify are available in the system path. Miniconda (python 2.7) is installed and pyclingo (through the python module `gringo`) is also available.
