#!/bin/bash


# From:
# http://stackoverflow.com/questions/2564634/
# bash-convert-absolute-path-into-relative-
# path-given-a-current-directory

function relpath() {
    if [[ "$1" == "$2" ]]
    then
        echo "."
        exit
    fi

    IFS="/"

    current=($1)
    absolute=($2)

    abssize=${#absolute[@]}
    cursize=${#current[@]}

    while [[ ${absolute[level]} == ${current[level]} ]]
    do
        (( level++ ))
        if (( level > abssize || level > cursize ))
        then
            break
        fi
    done

    for ((i = level; i < cursize; i++))
    do
        if ((i > level))
        then
            newpath=$newpath"/"
        fi
        newpath=$newpath".."
    done

    for ((i = level; i < abssize; i++))
    do
        if [[ -n $newpath ]]
        then
            newpath=$newpath"/"
        fi
        newpath=$newpath${absolute[i]}
    done

    echo "$newpath"
}

fatal() {
    echo "fatal: $*" >&2
    exit 1
}

warn() {
    echo "warning: $*" >&2
}

function source-after() {
    local filename="$1"
    local target="$(abs $profilepath)/$2"
    echo "Sourcing $target after $filename"
    cd $HOME
    (echo; echo "source $target") >> $(eval echo $filename)
}

function link-file() {
    local destfile="$1"
    local src="$2"

    if [[ -n "$src" ]]; then
        local profilefile="$profilepath/$src";
    else
        local profilefile="$profilepath/$(basename $destfile)";
    fi

    #echo $HOME/$(basename $destfile):

    if [[ -e $HOME/$(basename $destfile) || -h $HOME/$(basename $destfile) ]]; then
        echo "file exists. should rm $HOME/$(basename $destfile)";
        rm "$HOME/$(basename $destfile)";
    fi

    if [[ ! -e $profilefile ]]; then
        echo "linking file $destfile"
        ln -s $(relpath $HOME $profilefile) $HOME/$(basename $destfile)
    else
        warn "$profilefile exists. skipping."
    fi
}

process-link-files() {
    for file in `cat $1`; do
        link-file $file
    done
}
