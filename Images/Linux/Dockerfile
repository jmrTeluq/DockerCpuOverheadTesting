FROM ubuntu:22.04 as Base_Linux

# suppress debconf warning after 
ARG DEBIAN_FRONTEND=noninteractive

# adjusting character encoding
ENV LANG=C.utf8

# generates packages list and upgrades out of date packages
RUN apt update && apt upgrade -y

# Needs apt-utils installed and needs custom build because repo has older version
RUN apt install apt-utils -y && apt install g++ cmake -y

ARG primeSieveAdr="Outils/entiers/Linux/primesieve-7.9.tar.gz"

ARG linpackAdr="Outils/mémoire/Linux/linpack"

RUN mkdir /tests /tests/entiers /tests/flottants /tests/mémoire /résultats

COPY $primeSieveAdr /tests/entiers

WORKDIR /tests/entiers

RUN tar -xf primesieve-7.9.tar.gz

WORKDIR /tests/entiers/primesieve-7.9

RUN cmake . && make -j && make install && ldconfig

WORKDIR /

RUN rm -rf /tests/entiers/primesieve-7.9

CMD ["bash"]