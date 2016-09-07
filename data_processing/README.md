# Data Preparation

This folder is collecting code for preparing HT token count data (via the Extracted Features library) for ingest into Bookworm.

Earlier indexing was done using a combination of Python scripting and GNU Parallel. For a more coherent process, as much as possible is
being done within Python now, use `ipyparallel` as the preferred multi-processing environment. If using any code with ipyparallel in it,
first start engines for it with `ipcluster -n NUM`.

The ideal approach will be to use the bw-docker containers, to set up the environment properly. `bw-indexing` is the container definition
that is being customized for this, but it is not yet complete enough to document.
