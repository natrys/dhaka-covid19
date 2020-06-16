#!/bin/mksh

# set -x
set -o pipefail

download_pdf() {
  typeset homepage
  homepage="https://www.iedcr.gov.bd/"
  pdf=$(curl -k -sL $homepage | pup 'a.btn attr{href}')
  curl -sL -O ${homepage}/${pdf}
}

daily_archive() {
  typeset root
  root=https://www.iedcr.gov.bd/website/images/files/nCoV/
  curl -k -sL $root > index
  ls -1 archive/*.pdf | sed 's|.*/||' | sort > old_list
  cat index | pup 'a attr{href}' | grep Case_dist | sort > new_list
  comm -13 old_list new_list | while read newpdf; do
    echo "Downloading ${newpdf}"
    curl -k -sL -O ${root}/${newpdf}
  done
  mv *.pdf archive/ 2>/dev/null || rm *_list index || true
}

find_broken() {
  pdftotext -f 2 -nopgbrk -layout $1 - | grep -Pv '\s.*?Dhaka City' | \
    txr find_broken.txr | tr '\n' ,
}

extract() {
  typeset pdf name
  pdf="$1"
  name=${pdf%.*}
  broken=$(find_broken $pdf)
  pdftotext -f 2 -nopgbrk $pdf - | txr format.txr > text
  awk -v broken=$broken -f fix_broken.awk text > location
  grep -P '^\d' text > infected
  paste infected location | sort -rn > ${name}.data
  rm infected location text
}

update() {
  typeset pdf name
  daily_archive
  pdf="$(fselect path from archive/ where is_book=1 order by created desc limit 1)"
  name=${pdf%.*}
  extract $pdf
  mv ${name}.data latest.data
}

"$@"
