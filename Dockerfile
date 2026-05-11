FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    wget \
    tar\
    unzip\
    make \
    python3 \
    python3-dev\
    pkg-config \
    libffi-dev \
    libgmp-dev \
    zlib1g-dev
    
WORKDIR /vcml-pydrofoil
COPY . .

#Install PyPy for Pydrofoil
RUN wget https://downloads.python.org/pypy/pypy3.11-v7.3.21-linux64.tar.bz2 && \
    tar -xjf pypy3.11-v7.3.21-linux64.tar.bz2 && \
    mv pypy3.11-v7.3.21-linux64 /opt/pypy && \
    ln -s /opt/pypy/bin/pypy3 /usr/local/bin/pypy3 && \
    rm pypy3.11-v7.3.21-linux64.tar.bz2

ENV PATH="/opt/pypy/bin:$PATH"
ENV PYTHONPATH="/vcml-pydrofoil"

#Access Pydrofoil-PyPy plugin from downloaded artifact 
RUN unzip artifact.zip -d ./artifact
RUN mkdir -p ./pypy-pydrofoil-scripting-experimental && \
    tar -xjf ./artifact/pypy-pydrofoil-scripting-experimental.tar.bz2 \
       -C ./pypy-pydrofoil-scripting-experimental --strip-components=1

#To execute the build script
RUN chmod +x build.sh
RUN ./build.sh

#To build SystemC VP
RUN mkdir -p build && cd build && \
    cmake ../sysc_vp \
        -DCMAKE_PREFIX_PATH=${SYSTEMC_HOME} \
        -DCMAKE_BUILD_TYPE=Debug && \
    make -j$(nproc)

ENV LD_LIBRARY_PATH=/vcml-pydrofoil/pypy-pydrofoil-scripting-experimental/bin:/vcml-pydrofoil:/vcml-pydrofoil/build:/vcml-pydrofoil/sysc_vp:$LD_LIBRARY_PATH


#To execute the launch script
COPY sysc_vp/launch.sh .
COPY sysc_vp/benchmark benchmark/ 
RUN chmod +x launch.sh

VOLUME ["/config_files"]
ENTRYPOINT ["./launch.sh"]

CMD ["/config_files/riscv64_ex.cfg"]
