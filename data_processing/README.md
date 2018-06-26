# Data Preparation

This folder is collecting code for preparing HT token count data (via the Extracted Features library) for ingest into Bookworm.

Earlier indexing was done using a combination of Python scripting and GNU Parallel. For a more coherent process, as much as possible is
being done within Python now, use `ipyparallel` as the preferred multi-processing environment. If using any code with ipyparallel in it,
first start engines for it with `ipcluster start -n NUM`.

The ideal approach will be to use the bw-docker containers, to set up the environment properly. `bw-indexing` is the container definition
that is being customized for this, but it is not yet complete enough to document.

## Processing Steps

There are two main processing steps in this folder: 
    1. creating a wordlist of the most-common words,
    2. then re-encoding books by filtering only to the wordlist words and encoding words as numer ids

## Wordlist Generation

Step #2 is the important one, but Step #1 was undertaken to ensure that Bookworm doesn't drop many important words from its vocabulary.

If recreating HathiTrust+Bookworm on a multi-lingual, multi-century corpus, *don't bother creating a new wordlist*, just 
ask HTRC for theirs! The amount of processing probably isn't useful. If the word-frequencies-per-language doesn't suit you,
Google's NGrams Datset offers word-frequencies-per-year, for free download at http://storage.googleapis.com/books/ngrams/books/datasetsv2.html. 

At the HTRC, we wanted to differentiate between tail words in popular languages (undesired) and common words in less-represented languages (desired).

To create the wordlist, HTRC Extracted Features files were processed in batches.

- [1-1_BookwormWordlist.ipynb](./1-1_BookwormWordlist.ipynb) saves big DataFrames of `language/token/count` in H5 format.
  To be more threadsafe, I avoid the issue by having each thread saving to it's own H5 file. The language counts are in
  '/tf/corpus' within the file. (Note, this notebook also saves per book token counts, noted below) 
- [1-2_BookwormFoldWordList.ipynb](1-2_BookwormFoldWordList.ipynb) takes the individual batch H5s and merged the token counts by
    language, first internally, then into their own stores, and finally sorted. Here are counts of unique tokens for the top languages:

```/eng    79005095
/ger    30446373
/fre    17440715
/lat    13691932
/rus    10851839
/jpn     8333906
/ita     7069154
/spa     7027856
/chi     5210120
/und     4886094
```

- [1-3_CreateWordlist.ipynb](1-3_CreateWordlist.ipynb) uses the big lists of all token frequencies per language to select a vocabulary.

## ID Encoding Books

For speed (and to better prep for how Bookworm stores data internally), id-encode all books as volume-id/token-id/count.
The numeric token ids are simply the index number from the final wordlist (see above). The volume id keys are generated
by Bookworm after metadata is inserted in it.

- [1-1_BookwormWordlist.ipynb](./1-1_BookwormWordlist.ipynb) processes each volume and saves DataFrames of id/token/count.
  - id/token/count