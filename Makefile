 
part=06
blockSize=300M

# FILE PATHS
logPath=/data/raid3/htrc/logs
processedFeaturePath=bw-input
tmpPath=/data/scratch/bookwormtmp/

# Listing of Extracted Features files to process
featureFileList=/data/datasets/htrc-feat-extract/pd/pd-file-listing.txt.$(part)

# Log location

all: BookwormDB paths features

paths:
	mkdir -p $(logPath)
	mkdir -p $(processedFeaturePath)

BookwormDB:
	git submodule init
	git submodule update
	$(MAKE) -C BookwormDB files/targets

update:
	git submodule update

mostlyclean:

clean:

pristineclean:

features:

$(processedFeaturePath)/pd-features-$(part):
	cat $(featureFileList) | sed "s:^/data/features/extracted/:/data/datasets/htrc-feat-extract/pd/:g" | parallel --joblog $(logPath)/pd-features-$(part)-joblog.log --eta --progress -n100 -j95% python BookwormDB/scripts/htrc_featurecount_stream.py --logpath $(logPath)/featurecount$(part).log | gzip >$(processedFeaturePath)/pd-features-$(part).txt.gz


BookwormDB/files/texts/wordlist/wordlist-$(part).txt:
	BookwormDB/scripts/fast_featurecounter.sh $(processedFeaturePath)/pd-features-$(part).txt.gz $(tmpPath) $(blockSize) $@

BookwormDB/files/targets/encoded: BookwormDB/files/texts/wordlist/wordlist.txt
#builds up the encoded lists that don't exist yet.
#I "Make" the catalog files rather than declaring dependency so that changes to 
#the catalog don't trigger a db rebuild automatically.
	$(MAKE) -C BookwormDB files/metadata/jsoncatalog_derived.txt
	$(MAKE) -C BookwormDB files/texts/textids.dbm
	$(MAKE) -C files/metadata/catalog.txt
	#$(textStream) | parallel --block-size $(blockSize) -u --pipe bookworm/tokenizer.py
	cd BookwormDB
	cat unigrams.txt | parallel --block-size $(blockSize) -u --pipe bookworm/ingestFeatureCounts.py encode --log-level debug
	cd ../
	touch BookwormDB/files/targets/encoded


