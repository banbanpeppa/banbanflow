FROM ubuntu:16.04

# add TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python3 \
        python-dev \
        rsync \
        software-properties-common \
        unzip \
        wget \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# add python dependencies
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip --no-cache-dir install \
        Pillow \
        h5py \
        ipykernel \
        numpy \
        tensorflow \
        tensorflow-serving-api \
        flask \
        && \
    python -m ipykernel.kernelspec

# show python logs as they occur
ENV PYTHONUNBUFFERED=0

RUN wget -P /home/MNIST_data http://pbqsx8kpd.bkt.clouddn.com/t10k-images-idx3-ubyte.gz
RUN wget -P /home/MNIST_data http://pbqsx8kpd.bkt.clouddn.com/t10k-labels-idx1-ubyte.gz
RUN wget -P /home/MNIST_data http://pbqsx8kpd.bkt.clouddn.com/train-images-idx3-ubyte.gz
RUN wget -P /home/MNIST_data http://pbqsx8kpd.bkt.clouddn.com/train-labels-idx1-ubyte.gz

# add project files
ADD *.py /home/
ADD templates/* /home/templates/
ADD static/styles /home/static/styles/
RUN mkdir /home/static/tmp/
ADD static/scripts/ /home/static/scripts/

# start server on port 5000
WORKDIR /home/
EXPOSE 5000
ENTRYPOINT python flask_server.py