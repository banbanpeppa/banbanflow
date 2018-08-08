FROM tensorflow/tensorflow:1.8.0

RUN python -m ipykernel.kernelspec

# include service account key
RUN mkdir /home/tensorflow
RUN apt-get update -y && apt-get install -y wget
RUN wget -P /home/tensorflow/MNIST_data http://pbqsx8kpd.bkt.clouddn.com/t10k-images-idx3-ubyte.gz
RUN wget -P /home/tensorflow/MNIST_data http://pbqsx8kpd.bkt.clouddn.com/t10k-labels-idx1-ubyte.gz
RUN wget -P /home/tensorflow/MNIST_data http://pbqsx8kpd.bkt.clouddn.com/train-images-idx3-ubyte.gz
RUN wget -P /home/tensorflow/MNIST_data http://pbqsx8kpd.bkt.clouddn.com/train-labels-idx1-ubyte.gz

# show python logs as they occur
ENV PYTHONUNBUFFERED=0

# include version and bucket as arguments to docker build
ARG version=1
ENV VERSION=$version

# run MNIST.py with included arguments
ADD MNIST.py /home/tensorflow
WORKDIR /home/tensorflow
ENTRYPOINT /usr/bin/python /home/tensorflow/MNIST.py --version $VERSION