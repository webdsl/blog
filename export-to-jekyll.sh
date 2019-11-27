#!/bin/sh

EXPORTDIRNAME=jekyll-export
EXPORTDIR=$PWD/$EXPORTDIRNAME
EXPORTDIRWIKI=$EXPORTDIR/wiki
EXPORTDIRBLOG=$EXPORTDIR/blog/_posts
EXPORTWIKIURL="http://localhost:8080/blog/jekyllwiki/"
EXPORTBLOGURL="http://localhost:8080/blog/jekyllblog/"

echo "saving export in directory $EXPORTDIR"

# Create directories
if [ ! -d "$EXPORTDIR" ]; then
    mkdir $EXPORTDIR
    echo "created $EXPORTDIR"
else
    rm -r $EXPORTDIR/*
    echo "cleared old export"
fi

rm "$EXPORTDIR.zip"

mkdir $EXPORTDIRWIKI
mkdir -p $EXPORTDIRBLOG    

echo "exporting wiki"

wikigrouppagesraw=$(wget $EXPORTWIKIURL -q -O -)
IFS=$'\n' 
read -rd '' -a wikigrouppages <<<"$wikigrouppagesraw"

for wikigrouppage in "${wikigrouppages[@]}"
do
    # Get the string after the last /
    wikigroupnametemp=${wikigrouppage##*/}

    # Trim last 3 characters because of the %3A in all wiki group names
    wikigroupname=${wikigroupnametemp::${#wikigroupnametemp}-3}

    if [ -z "$wikigroupname" ]; then
        wikigroupname="index"
    fi

	echo "\texporting WikiGroup $wikigroupname"

    mkdir $EXPORTDIRWIKI/$wikigroupname
    
    # Process the pages of the wikigroup
    wikipagesraw=$(wget $wikigrouppage -q -O -)
    IFS=$'\n'
    read -rd '' -a wikipages <<<"$wikipagesraw"
    for wikipage in "${wikipages[@]}"
    do
        prefix="$wikigrouppage/$wikigroupnametemp"
        wikiname=${wikipage#$prefix}
        

        if [ -z "$wikiname" ]; then
            wikiname="index"
        fi
        echo "\t\texporting wiki $wikigroupname/$wikiname"

        wget --output-document=$EXPORTDIRWIKI/$wikigroupname/$wikiname.md $wikipage -q

    done
done

echo ""
echo "exporting blog"

postyearpagesraw=$(wget $EXPORTBLOGURL -q -O -)
IFS=$'\n' 
read -rd '' -a postyearpages <<<"$postyearpagesraw"

for postyearpage in "${postyearpages[@]}"
do
    # Get the string after the last /
    postyear=${postyearpage##*/}

    echo "\texporting blog posts year $postyear"

    mkdir $EXPORTDIRBLOG/$postyear
    
    # Process the pages of the wikigroup
    postpagesraw=$(wget $postyearpage -q -O -)
    IFS=$'\n'
    read -rd '' -a postpages <<<"$postpagesraw"
    for postpage in "${postpages[@]}"
    do
        postname=${postpage##*/}
        echo "\t\texporting post $postname"

        wget --output-document=$EXPORTDIRBLOG/$postyear/$postname.md $postpage -q
    done
done

# Set delimiter back to standard value
IFS=' '

echo "zipping exported files"

zip -rq "$EXPORTDIRNAME.zip" $EXPORTDIRNAME

echo "removing temp exported files"

rm -r $EXPORTDIR

echo "DONE, zip file: $PWD/$EXPORTDIRNAME.zip"
