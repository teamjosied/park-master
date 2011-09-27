#!/bin/sh

getnames () {
    grep "<string" "$1" | grep "name=" | sed "s/^.*<string\(-array\)*\s*name\s*=\s*\"\([^\"]*\)\".*$/\2/"
}

finddiffs () {
    echo "Missing translations for language '$1':" > $1.missing
    diff -y en.str $1.str > tmp.str
    echo "Only in values/strings.xml (this doesn't mean, that everything has to be translated):" >> $1.missing
    grep "<\||" tmp.str | cut -d " " -f 1 | while read s; do
        grep "<string" ../../res/values/strings.xml | grep "name=\"$s\""
    done >> $1.missing
    echo "Only in values-$1/strings.xml:" >> $1.missing
    grep ">\||" tmp.str | sed "s/^/x/;s/\s\s*/ /g" | cut -d " " -f 3 | while read s; do
        grep "<string" ../../res/values-$1/strings.xml | grep "name=\"$s\""
    done >> $1.missing
    rm tmp.str
    # 5 lines means 3 comments + contributors + changelog
    [ `cat $1.missing | wc -l` -lt 6 ] && rm $1.missing
}

cd `dirname "$0"`

echo processing en...
getnames ../../res/values/strings.xml > en.str
for l in `find ../../res/values-* -name "strings.xml" | sed "s/^.*values-\(..\).*$/\1/"`; do
    echo processing $l...
    getnames ../../res/values-$l/strings.xml > $l.str
    finddiffs $l
done
rm *.str
echo "missing translations:"
# Do not count 3 comments + contributors + changelog
wc -l *.missing | sed "s/\.missing//" | awk '{print $1-5" "$2}'
