FROM ubuntu:16.04
MAINTAINER Binded <info@binded.com>

# Update packages and install basics
RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  git \
  python3 \
  python3-pip \
  cmake \
  pkg-config \
  libjpeg8-dev \
  libtiff5-dev \
  libjasper-dev \
  libpng12-dev \
  libatlas-base-dev \
  gfortran \
  python3.5-dev \
  libopenblas-dev \
  liblapacke-dev \
  swig

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
#  /usr/local/lib/python3.5/dist-packages/cv2.cpython-35m-x86_64-linux-gnu.so \
#  /usr/local/lib/python3.5/dist-packages/cv2.so

# Install Facebook Faiss library
WORKDIR /opt
# until this is merged: https://github.com/facebookresearch/faiss/pull/146
#ENV FAISS_BRANCH=master
#RUN git clone https://github.com/facebookresearch/faiss.git && \
#  git checkout "${FAISS_BRANCH}"
ENV FAISS_BRANCH=python-cflags
RUN git clone --depth 1 https://github.com/olalonde/faiss.git -b "${FAISS_BRANCH}"
ENV BLASLDFLAGS="/usr/lib/libopenblas.so.0"
ENV PYTHONCFLAGS="-I/usr/include/python3.5m/ -I/usr/local/lib/python3.5/dist-packages/numpy/core/include"
RUN cd faiss && \
  cp example_makefiles/makefile.inc.Linux makefile.inc && \
  make -j $(nproc) && \
  make py && \
  cp *py /usr/local/lib/python3.5/dist-packages/ && \
  cp _swigfaiss.so /usr/local/lib/python3.5/dist-packages/