Hathitrust Bookworm
----------------------

Code for setting up a Hathitrust full-text Bookworm using the HathiTrust Research Center's Extracted Features dataset, the HTRC Metadata API, and the [Hathitrust Hathifiles](http://www.hathitrust.org/hathifiles).

This repository is still in-development and being documented, for assistance setting it up contact organis2@illinois.edu.

# Process

Bookworm needs the following information for indexing:
 - *jsoncatalog.txt* : The metadata records for each document in the collection, as JSON.
 - *fielddescriptions*: The schema for the JSON metadata: why kinds of fields are they, etc.
 - *wordlist*: A numbered TSV of tokens to index, with total counts. (Format is `num_id<TAB>token<TAB>count`). Anything not in this list is not indexed, and the numbers match to the internal ids that mysql will use.
 - *raw unigrams*: The data for each book, organized as doc_name<TAB>token<TAB>count.
 - Optional: *converted unigram list*: the raw unigrams are encoded against the wordlist by Bookworm: tokens converted to their ids, and non-indexed tokens removed. Bookworm's ingestFeatureCount, developed for the first HT+BW index, is sufficient, but the sheer scale of 15million books means that this process might be more convenient earlier in the process, by lowering the disk space necessary. While disk space is cheap, the read/write IO with the hard disk is the greatest blocking factor in preparing this collection.

Because of the scale of the HathiTrust collection, most of these files need custom preparation outside of Bookworm's
general purpose indexing processes.

The general indexing process:
 - Data
   - Build wordlist. Determine what goes in and what does not.
   - Export raw token counts.
   - Encode token counts against wordlist.
 - Metadata
   - Determine metadata fields.
   - Build json Collect metadata from multiple sources. Version 1 used HTRC Solr Index and the HathiFiles.
 - Index
   - If the files are in the right place, Bookworm will handle the MYSQL indexing.
   - Save the BookwormGUI definitions file! MySQL provides a template for which fields to show in the Line Chart interface.
 - Workset integration
   - Because worksets are constantly updated, all workset metadata is added post-indexing.


# Preparing Data

There are multiple approaches possible. The approach being taken currently is #2, but it is worth thinking about both possibilities. Currently, we are saving raw token counts in HDF5 (using PyTables 'table' format through Pandas) while working on the tokenlist, then encoding the counts by iterating through the HDF5 store in chunks.

1 . Two-pass: wordlist, then pre-culled doc-token counts

Write speed is a limiting factor when saving doc-token counts, so knowing beforehand which ones we won't keep can be fast, even if it means
reading through the collection twice.

Steps
- read feature files, exporting global word frequencies along with a number to use as an ID.
- Trim wordlist to desired vocabulary. OCR errors are a huge part of the wordlist, we don't want them!
- read feature files, export token_id<TAB>token<TAB>count for only the words in the wordlist.

_this could use a global word list like from Google NGrams Dataset, and skip step 1_

2. Single pass against feature files
- Read Feature Files, saving both word list info and "raw" tokencounts (all tokens, unencoded)
- Encode tokencounts.
