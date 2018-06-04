#!/bin/bash

if [ "$TRAVIS_OS_NAME" != "osx" ]; then #
  cd ..
  wget "$HDF5_RELEASE_URL/hdf5-${HDF5_VERSION%.*}/hdf5-$HDF5_VERSION/src/hdf5-$HDF5_VERSION.tar.gz"
  tar -xzf "hdf5-$HDF5_VERSION.tar.gz"
  cd "hdf5-$HDF5_VERSION"
  ./configure --prefix=/usr/local
  sudo make install
  cd ../seurat
fi

# install python
if [[ $TRAVIS_OS_NAME == "linux" ]]; then
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
elif [[ $TRAVIS_OS_NAME == "osx" ]]; then
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O miniconda.sh
fi

bash miniconda.sh -b -p $HOME/miniconda
export PATH="$HOME/miniconda/bin:$PATH"
export RETICULATE_PYTHON="$HOME/miniconda/bin/python"
hash -r
conda config --set always_yes yes --set changeps1 no
conda update -q conda
conda info -a
pip install --upgrade pip
pip install phate
# Scanpy dependencies
conda install seaborn scikit-learn statsmodels numba
pip install scanpy
