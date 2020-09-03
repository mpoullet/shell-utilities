#!/bin/bash
############################################################
### Shell script to uninstall Mac Os X packages          ###
### Based on pkgutil.                                    ###
### Created by Adam Wallner <adam.wallner at gmail.comu> ###
### V1.0.1                                               ###
############################################################
IFS=$'\n'

function get_pkgid {
    local c=`pkgutil --pkgs | grep -i -c "$1"`
    if [ $c -eq 0 ]; then
        echo "Package not found!"
        exit 1
    fi
    if [ $c -gt 1 ]; then
        pkgid=$(pkgutil --pkgs | grep -i -m1 ".*$1\$")

        if [ $? -ne 0 ]; then
            pkgutil --pkgs | grep -i "$1"
            echo "We've found $c packages matching '$1'. You need to specify the exact package name or part of it only matches one package!"
            exit 1
        fi
        return
    fi
    pkgid=$(pkgutil --pkgs | grep -i "$1")
    if [ $? -ne 0 ]; then
        echo "Cannot find package id '$1'!"
        exit 3;
    fi;
    echo "Package ID: $pkgid"
}


function get_root_dir {
    # Get volume
    volume=`pkgutil --pkg-info "$pkgid" | grep "volume:" | cut -d " " -f 2`
    echo "Volume: $volume"
    cd "$volume" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "The volume '$volume' not found!"
        exit 6
    fi

    # Get root
    receiptdir=""
    location=`pkgutil --pkg-info "$pkgid" | grep "location:" | cut -d " " -f 2`
    if [ "$location" == "(null)" ]; then
        echo -n "The location was not stored in package db, so we need to find it in receipts. Please wait..."
        # We need to search in /Library/Receipts
        for info in `ls -1 /Library/Receipts/*.pkg/Contents/Info.plist`; do
            # Get receipt dir
            pushd "$PWD" >/dev/null
            receiptdir="`dirname "$info"`/../"
            cd "$receiptdir"
            receiptdir="$PWD"
            popd >/dev/null

            # Get bundle id
            info="`dirname "$info"`/Info"
            bundleid=`defaults read "$info" CFBundleIdentifier 2>/dev/null`
            if [ "$bundleid" == "" ]; then
                bundleid=`basename "$receiptdir"`
                bundleid="${bundleid%.*}"
            fi

            # If bundle id is the same as package id, we found it
            if [ "$bundleid" == "$pkgid" ]; then
                # Get location
                location=`defaults read "$info" IFPkgRelocatedPath`
                echo "Ok."
                echo "Receipt Directory: $receiptdir"
                break
            fi

            echo -n "."
        done
    fi
    # Still null?
    if [ "$location" == "(null)" ]; then
        echo "Not found."
        echo "Cannot find root directory of package!"
        read -p "Do you want to continue with system root? (Y/N) " -n 1
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            read -p "Do you want to forget this package ($pkgid)? (Y/N) " -n 1
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit;
            fi
            forget
            exit;
        fi
        location="/"
    fi

    echo "Location: $location"
    # Go to the root directory
    cd "$location" 2>/dev/null
    if [ $? -ne 0 ]; then
        location=${location/.\//$volume}
        cd "$location" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "The root directory doesn't exist! This package is likely to be removed."
            read -p "Do you want to forget this package ($pkgid)? (Y/N) " -n 1
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit;
            fi
            forget
            exit;
        fi
    else
        echo "Root directory: $PWD"
    fi
    echo ""
}


function forget {
    # Forget package
    sudo pkgutil --forget "$pkgid" 2>/tmp/pkguninst.err
    err=`cat /tmp/pkguninst.err`
    rm /tmp/pkguninst.err
    #echo $out
    if [ "$err" != "" ]; then
        echo "Package forget was not possible."
    fi
    if [ "$receiptdir" != "" ]; then
        echo -n "Trying to remove receipt directory..."
        sudo rm -r "$receiptdir" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Ok."
        else
            echo "Not found."
        fi
    fi
    echo -n "Trying to remove from old bom directory..."
    sudo rm "/Library/Receipts/boms/$pkgid.bom" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Ok."
    else
        echo "Not found."
    fi
}


function list {
    echo "*** Files ***"
    pkgutil --only-files --files "$pkgid"
    echo -e "\n*** Directories ***"
    pkgutil --only-dirs --files "$pkgid"
}

function info {
    # Get package id
    get_pkgid "$1"
    # Get the root directory and change actual dir to that
    get_root_dir
    # Show list of files to confirm
    list
}


function remove {
    echo ""
    echo "Please check the above file and directory lists. Only the files and directories become empty will be deleted."
    read -p "Are you sure you want to remove all files and all empty directories of package '$pkgid'? (Y/N) " -n 1
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        read -p "Even so do you want to forget this package ($pkgid)? (Y/N) " -n 1
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit;
        fi
        forget
        exit
    fi

    # Remove files
    echo -n "Removing files..."
    pkgutil --only-files --files "$pkgid" | tr '\n' '\0' | xargs -n 1 -0 sudo rm 2>/dev/null
    echo "Ready."
    # Remove directories in reverse order to be sure only remove empty directories
    echo -n "Removing empty directories..."
    # If the directory is symlnk it is a regular file to delete - It is not safe!!!
    #pkgutil --only-dirs --files "$pkgid" | tail -r | tr '\n' '\0' | xargs -n 1 -0 sudo rm 2>/dev/null
    # Delete directory if it is empty
    pkgutil --only-dirs --files "$pkgid" | tail -r | tr '\n' '\0' | xargs -n 1 -0 sudo rmdir 2>/dev/null

    echo "Ready."
    # Remove the install root directory
    if [ "$location" != "/" ]; then
        echo -n "Removing intall root directory (if it is empty)..."
        cd "$volume"
        sudo rmdir "$location" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Removed."
        else
            echo "Not removed."
        fi
    fi
}


### Process command line switches ####
if [ "$1" != "" ]; then
    # Ininstall package
    if [ "$1" == "-u" ]; then
        info "$2"
        remove
        forget
        exit
    fi
    # Information of matched package
    if [ "$1" == "-i" ]; then
        info "$2"
        exit
    fi
    # List of matched packages
    if [ "$1" == "-p" ]; then
        if [ "$2" == "" ]; then
            pkgutil --pkgs
        else
            pkgutil --pkgs | grep -i "$2"
        fi
        exit
    fi
    # Batch uninstall
    if [ "$1" == "-b" ]; then
        echo "Batch operation started."
        for pkgname in `pkgutil --pkgs | grep -i "$2"`; do
            echo -e "=================================================\n"
            "$0" -u "$pkgname"
            if [ $? -ne 0 ]; then
                echo "Some error occured while batch operation. Exiting..."
                exit 2
            fi
        done
        echo "================================================="
        echo "Ready."
    fi
else
    # Show usage informations
    echo "Usage: pkguninst [-u|-p|-i|-b] [pkgname]"
    echo "  -p   List all matching packages or all packages if no pkgname was specified."
    echo "  -i   Shows all information of package matching pkgname. If more then one pkgname matches then just list all of them."
    echo "  -u   Shows information, remove files and directories after confirmation, then forget package."
    echo "  -b   Uninstall all matched packages one by one. You need to confirm every package."
fi
