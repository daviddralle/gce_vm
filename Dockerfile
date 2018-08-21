
FROM jupyter/scipy-notebook

MAINTAINER David Dralle <daviddralle@gmail.com>

USER root

RUN apt-get update && \
    apt-get install -y libfreetype6-dev pkg-config libx11-dev gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN conda clean --yes --all

RUN conda install --yes jupyterlab \
    && jupyter lab -y --generate-config

RUN apt-get update \
	&& apt-get install -y curl

RUN conda install --yes -c conda-forge \
	'pandas' \
    'geopandas' \
    'georasters' \
    'google-api-python-client' \
    'earthengine-api' 

# Install google cloud storage fuse (gcsfuse) to mount cloud storage buckets in datalab VM - specific to Ubuntu Xenial 
RUN export GCSFUSE_REPO=gcsfuse-xenial \
	&& echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list \
	&& curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
	&& apt-get update --allow-unauthenticated \
	&& apt-get install gcsfuse -y --allow-unauthenticated

### INSTALL R ###

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    tzdata \
    gfortran \
    gcc && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# R packages
RUN conda install --yes \
    'r-base=3.4.1' \
    'r-irkernel=0.8*' \
    'r-plyr=1.8*' \
    'r-devtools=1.13*' \
    'r-tidyverse=1.1*' \
    'r-shiny=1.0*' \
    'r-rmarkdown=1.8*' \
    'r-forecast=8.2*' \
    'r-rsqlite=2.0*' \
    'r-reshape2=1.4*' \
    'r-nycflights13=0.2*' \
    'r-caret=6.0*' \
    'r-rcurl=1.95*' \
    'r-crayon=1.3*' \
    'r-randomforest=4.6*' \
    'r-htmltools=0.3*' \
    'r-sparklyr=0.7*' \
    'r-htmlwidgets=1.0*' \
    'r-hexbin=1.27*' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR

# Add on packages
RUN conda install --yes -c conda-forge \
    'tqdm' \
    'pymc3'

RUN conda install --yes -c conda-forge \
	'r-rgdal' \
	'r-ncdf4'

RUN pip install ipywidgets \
  && jupyter nbextension enable --py widgetsnbextension --sys-prefix \
  && jupyter labextension install @jupyter-widgets/jupyterlab-manager

# Get google maps API and rebuild jupyterlab to correctly display widgets
RUN conda install --yes \
	'dask'

RUN jupyter lab build

EXPOSE 8888

ENTRYPOINT jupyter lab --NotebookApp.token='agroserve' --no-browser --allow-root --ip='*' --port=8888