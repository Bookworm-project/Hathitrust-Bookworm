FROM jupyter/datascience-notebook

MAINTAINER Peter Organisciak <organisciak@gmail.com>

USER root

RUN apt-get update -qq && \
    apt-get install -y \
	parallel

## Alias parallel so it always mutes the notice within the container
RUN echo "alias parallel='parallel --no-notice'">>/root/bash_profile

USER jovyan

RUN conda install \
	ipyparallel \
	pytables \
	dask

RUN pip install \
	htrc-feature-reader \
	tqdm

# Jupyter ports
EXPOSE 8888

WORKDIR "/notebooks"
