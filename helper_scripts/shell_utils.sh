# Copyright (c) 2012 Plone Foundation. Licensed under GPL v 2.
#
# Utilities meant to be sourced into a shell script


# untar ()
# unpack a tar archive, decompressing as necessary.
# this function is meant to isolate us from problems
# with versions of tar that don't support .gz or .bz2.
untar () {
    case "$1" in
        *.tar)
            tar -xf "$1" >> "$INSTALL_LOG"
            ;;
        *.tgz | *.tar.gz)
            gunzip -c "$1" | tar -xf - >> "$INSTALL_LOG"
            ;;
        *.tar.bz2)
            bunzip2 -c "$1" | tar -xf -  >> "$INSTALL_LOG"
            ;;
        *)
            echo "Unable to unpack $1; extension not recognized."
            exit 1
    esac
    if [ $? -gt 0 ]; then
        seelog
    fi
}


# functions to check xslt or xml2 versions.
#
# config_version xml2/xslt 2.7.8
# returns 0 if good; 1 if not
#
# if config_version xml2 "2.7.8"; then
#     echo "Yes, xml2-config exists, and version is >= 2.7.8"
# else
#     echo "No, xml2-config doesn't exist, or version is < 2.7.8"
# fi

config_version () {
    CONFIG="$1-config"

    REF_MAJOR=`echo $2 | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\1/'`
    REF_MINOR=`echo $2 | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\2/'`
    REF_MICRO=`echo $2 | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\3/'`

    which $CONFIG > /dev/null
    if [ $? -gt 0 ]; then
        return 1
    fi

    VERSION=`$CONFIG --version`
    major_version=`echo $VERSION | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\1/'`
    minor_version=`echo $VERSION | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\2/'`
    micro_version=`echo $VERSION | sed 's/^\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\3/'`

    if [ $major_version -gt $REF_MAJOR ]; then
        return 0
    elif [ $major_version -eq $REF_MAJOR ]; then
        if [ $minor_version -gt $REF_MINOR ]; then
            return 0
        elif [ $minor_version -eq $REF_MINOR ]; then
            if [ $micro_version -ge $REF_MICRO ]; then
                return 0
            fi
        fi
    fi
    return 1
}

# for NEED_XML2 in 1.9.0 2.7.7 2.7.8 2.7.9 2.7.11 2.8.0; do
#     if config_version xml2 $NEED_XML2; then
#         echo "Yes, xml2-config exists, and version is >= $NEED_XML2"
#     else
#         echo "No, xml2-config doesn't exist, or version is < $NEED_XML2"
#     fi
# done

# for NEED_XSLT in 1.0.25 1.1.25 1.1.26 1.1.27 1.2.0 3.0.0; do
#     if config_version xslt $NEED_XSLT; then
#         echo "Yes, xslt-config exists, and version is >= $NEED_XSLT"
#     else
#         echo "No, xslt-config doesn't exist, or version is < $NEED_XSLT"
#     fi
# done
