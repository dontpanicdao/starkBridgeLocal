FROM ciimage/python:3.7

RUN apt update
RUN apt install -y cmake git libgmp3-dev g++ python3-pip python3.7-dev python3.7-venv npm

# Install solc and ganache
RUN curl https://binaries.soliditylang.org/linux-amd64/solc-linux-amd64-v0.6.12+commit.27d51765 -o /usr/local/bin/solc-0.6.12
RUN echo 'f6cb519b01dabc61cab4c184a3db11aa591d18151e362fcae850e42cffdfb09a /usr/local/bin/solc-0.6.12' | sha256sum --check
RUN chmod +x /usr/local/bin/solc-0.6.12
RUN npm install -g --unsafe-perm ganache-cli@6.12.2

COPY . /app/

WORKDIR /app/
RUN ./build.sh

WORKDIR /app/build/Release
RUN make all -j8

WORKDIR /app/

RUN npm install
# TODO: tag this image state as this will stay mostly static

WORKDIR /app/
# ENTRYPOINT ["/app/runner.sh"]