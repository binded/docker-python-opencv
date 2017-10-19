FROM ubuntu:16.10
MAINTAINER Binded <info@binded.com>

# Update packages and install basics
RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  wget \
  unzip \
  git \
  python3.6 \
  cmake \
  pkg-config \
  libjpeg8-dev \
  libtiff5-dev \
  libjasper-dev \
  libpng-dev \
  libatlas-base-dev \
  gfortran \
  python3.6-dev \
  libopenblas-dev \
  liblapacke-dev \
  swig \
  && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3.6 /usr/local/bin/python3
RUN cd /tmp && wget https://bootstrap.pypa.io/get-pip.py && python3.6 get-pip.py

# Make sure we have latest version of pip
RUN pip3 install --upgrade pip

# Install Numpy
RUN pip3 install numpy

# Install OpenCV
ENV OPENCV_VERSION="3.2.0"
RUN mkdir -p /opt/opencv
WORKDIR /opt/opencv
RUN git clone --depth 1 https://github.com/Itseez/opencv_contrib.git -b "${OPENCV_VERSION}"
RUN git clone --depth 1 https://github.com/Itseez/opencv.git -b "${OPENCV_VERSION}"
RUN cd opencv && git checkout "${OPENCV_VERSION}"
RUN cd opencv && \
  mkdir build && \
  cd build && \
  cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D INSTALL_C_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv/opencv_contrib/modules \
    -D PYTHON_EXECUTABLE="$(which python3)" \
      .. && \
    make -j $(nproc) && \
    make install && \
    ldconfig
#RUN mv \
#  /usr/local/lib/python3.6/dist-packages/cv2.cpython-35m-x86_64-linux-gnu.so \
#  /usr/local/lib/python3.6/dist-packages/cv2.so

# Install Facebook Faiss library
WORKDIR /opt
ENV FAISS_COMMIT="6b3b743986ba79633332dde82000348fc1b0af6f"
RUN git clone https://github.com/facebookresearch/faiss.git
RUN cd faiss && git checkout "${FAISS_COMMIT}"
ENV BLASLDFLAGS="/usr/lib/libopenblas.so.0"
RUN cd faiss && \
  cp example_makefiles/makefile.inc.Linux makefile.inc && \
  echo 'PYTHONCFLAGS=-I/usr/include/python3.6m/ -I/usr/local/lib/python3.6/dist-packages/numpy/core/include' \
    >> makefile.inc && \
  make -j $(nproc) && \
  make py && \
  cp *py /usr/local/lib/python3.6/dist-packages/ && \
  cp _swigfaiss.so /usr/local/lib/python3.6/dist-packages/