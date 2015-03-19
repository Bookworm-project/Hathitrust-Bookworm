 
part=06

# FILE PATHS
logPath=/data/raid3/htrc/logs
processedFeaturePath=bw-input
tmpPath=/data/scratch/bookwormtmp/

# Listing of Extracted Features files to process
featureFileList=/data/datasets/htrc-feat-extract/pd/pd-file-listing.txt.$(part)

# Log location

all: paths features

paths:
	mkdir -p $(logPath)
	mkdir -p $(processedFeaturePath)

BookwormDB:
	git submodule add https://github.com/Bookworm-project/BookwormDB.git BookwormDB
	git submodule init
	git submodule update

update:
	git submodule update

mostlyclean:

clean:

pristineclean:

features:

$(processedFeaturePath)/pd-features-$(part):
	cat $(featureFileList) | sed "s:^/data/features/extracted/:/data/datasets/htrc-feat-extract/pd/:g" | parallel --joblog $(logPath)/pd-features-$(part)-joblog.log --eta --progress -n100 -j95% python $(BookwormDBpath)/scripts/htrc_featurecount_stream.py --logpath $(logPath)/featurecount$(part).log | gzip >$(processedFeaturePath)/pd-features-$(part).txt.gz


BookwormDB/files/texts/wordlist/wordlist-$(part).txt:
	BookwormDB/scripts/fast_featurecounter.sh $(processedFeaturePath)/pd-features-$(part) $(tmpPath) $(blockSize) $@
