#!/usr/bin/env python
## Note: Written in python2.
import sys
import urllib2
import os

# input file should contain one column with a list of NCBI bioproject IDs
# if no input file is supplied, uses stdin
if len(sys.argv) < 2:
    print "Usage: python get-fasta-by-bioproject.py [inputfile=stdin]"
    exit

# open input file or stdin
if len(sys.argv) == 2:
    inpath = sys.argv[1]
    i = open(inpath,"rb")
else:
    i = sys.stdin
x=0
for line in i.readlines():
    x = x + 1
    if x % 10 == 0:
        print("on line " + str(x))
    try:
        bioprojectId = line.strip() # remove newline
        if os.path.exists(bioprojectId + '.fa'):
            print(bioprojectId + ' already downloaded')
            next
#        bioprojectUrl = "https://www.ncbi.nlm.nih.gov/nuccore/" + bioprojectId # create URL to get redirected
#        conn = urllib2.urlopen(bioprojectUrl) # open URL
#        nuccoreId = conn.url.split("/")[-1] # retrieve nuccore ID from redirected URL
#       conn.close() # close URL
        nuccoreUrl = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id="+bioprojectId+"&rettype=fasta" # create URL for FASTA file
        conn = urllib2.urlopen(nuccoreUrl) # open URL
        fasta = conn.read() # get FASTA text
        conn.close() # close URL
        outpath = bioprojectId + ".fa" # create file path to write FASTA 
        with open(outpath,"wb") as o: # auto-close file after done
            o.write(fasta) # write FASTA text to file
    except urllib2.HTTPError:
        print "Unable to retrieve genome for bioproject " + bioprojectId

i.close() # close input file