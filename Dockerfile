FROM gcc:4.9

MAINTAINER Santiago Videla <santiago.videla@gmail.com>

### copied from https://hub.docker.com/r/continuumio/miniconda/

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion
    
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -O miniconda.sh && \
    /bin/bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh
    
RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean
    
ENV PATH /opt/conda/bin:$PATH 

# http://bugs.python.org/issue19846 
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK. 
ENV LANG C.UTF-8 

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]

###

ENV CLINGO_VERSION="5.0.0"
ENV CLINGO_FILE="v$CLINGO_VERSION.tar.gz"
ENV CLINGO_URL="https://github.com/potassco/clingo/archive/$CLINGO_FILE"
ENV CLINGO_SRC="/clingo-$CLINGO_VERSION"

RUN wget $CLINGO_URL 
RUN tar zxvf $CLINGO_FILE && rm $CLINGO_FILE

RUN apt-get update && apt-get install -y bison re2c lua5.1 liblua5.1-dev libtbb-dev && conda install -y scons

COPY release.py $CLINGO_SRC/build/release.py

RUN /opt/conda/bin/scons -C $CLINGO_SRC --build-dir=release
RUN cp $CLINGO_SRC/build/release/python/clingo.so /opt/conda/lib/python2.7/site-packages/ && \
    cp $CLINGO_SRC/build/release/gringo $CLINGO_SRC/build/release/clingo $CLINGO_SRC/build/release/reify /usr/bin/ && \
    rm -fr $CLINGO_SRC

