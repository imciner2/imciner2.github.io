import json
import bibtexparser
import scholarly
import sys

from scholarly import scholarly as sc
from bibtexparser.bparser import BibTexParser

def get_author_citations(scholar_id):
    aut = sc.search_author_id(scholar_id)
    sc.fill(aut, sections=['publications'])

    # Extract the ID and the number of citations for the paper
    citations = {}
    for pub in aut['publications']:
        citations[pub['author_pub_id']] = pub['num_citations']

    return citations


def get_publication_citations(citations, biblibrary, folder):
    pubcites = {}
    shield_dict = {}
    for pub in biblibrary.entries:
        bib_id = pub['ID']

        if 'scholar_id' in pub:
            scholar_id = pub['scholar_id']
            num_cites = citations[scholar_id]

            print("{key} with ID {gsid} has {num} citations".format(key=bib_id, gsid=scholar_id, num=num_cites))
            pubcites[bib_id] = num_cites

            shield_dict[bib_id] = num_cites
        else:
            print("Skipping {key}".format(key=bib_id))

    json_object = json.dumps(shield_dict, indent=4)

    with open("{folder}/citation_count.json".format(folder=folder), "w") as outfile:
        outfile.write(json_object)

    return pubcites

######################################
# Main body of the script
######################################
if len(sys.argv) == 3:
    filename = sys.argv[1]
    outpath = sys.argv[2]
else:
    filename = "./content/bibliographies/Papers.bib"
    outpath = "./content"

with open(filename) as bibtex_file:
    parser = BibTexParser()
    parser.ignore_nonstandard_types = False
    biblibrary = bibtexparser.load(bibtex_file, parser)

print("Loaded file {fname}".format(fname=filename))

autcites = get_author_citations('FhYROr4AAAAJ')
pubcites = get_publication_citations(autcites, biblibrary, outpath)
