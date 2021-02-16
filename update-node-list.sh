#!/bin/bash
#
# AllStarLink extnodes generator
# 
# Copyright (C) 2018-2021, AllStarLink, Inc.
# 
# Written by:
# Tim Sawyer, WD6AWP 
# Rob Vella, KK9ROB (send patch diff instead of full file)
# Steve N4IRS
#
# See http://allstarlink.org for more information about
# this project. Please do not directly contact
# any of the maintainers of this project for assistance;
# the project provides a web site, and mailing lists
# for your use.
#
# This program is free software, distributed under the terms of
# the GNU General Public License Version 3. See the LICENSE file
# at the top of the source tree.

TOPDOMAIN=allstarlink.org
SUBDOMAINS="nodes1 nodes2 nodes3 nodes4"
URI="diffnodes.php"
FILEPATH=/var/lib/asterisk
EXTNODES=$FILEPATH/rpt_extnodes
EXTNODESTMP=/tmp/rpt_extnodes-temp
USERAGENT="UpdateNodeList/2.0.0-beta.4"

RUNONCE=$1

WGET=$(which wget)
CP=$(which cp)
MV=$(which mv)
RM=$(which rm)
CHMOD=$(which chmod)
GREP=$(which grep)
CAT=$(which cat)
DATE=$(which date)
RSYNC=$(which rsync)

# Diagnostics
# Enable this for debugging
verbose=0
long_sleep=300
sleep=60
short_sleep=5
dry_run=0
downloads=0
retries=0
last_hash=$(grep SHA1 $EXTNODES | cut -d "=" -f 2)

debugLog() {
  if [ $verbose -ne 0 ]; then
    echo $@
  fi
}

errorLog() { echo "$@" 1>&2; }

checkRunOnce() {
  if [ "${RUNONCE}" == "once" ]; then
    debugLog "Exiting due to RUNONCE"
    exit 0
  fi
}

getNodes() {
  for i in $SUBDOMAINS; do
    res=0

    while [ $res -eq 0 ]; do
      url=http://$i.$TOPDOMAIN/$URI

      if [ "${last_hash}" != '' ]; then
        url+="?hash=${last_hash}"
        last_hash=""
      fi

      $WGET --user-agent="$USERAGENT" -q -O $EXTNODESTMP $url

      res=$?

      if [ $res -eq 0 ]; then
        debugLog "$($DATE)"

        # Determine if differential
        $GREP -q ";Full" $EXTNODESTMP

        if [ $? -eq 0 ]; then
          # Full Download
          downloads=$((downloads + 1))
          retries=0
          last_hash=$(grep SHA1 $EXTNODESTMP | cut -d "=" -f 2)
          debugLog "File Hash: $last_hash"

          if [ $dry_run -eq 0 ]; then
            $CHMOD 700 $EXTNODESTMP
            $CP $EXTNODESTMP ${EXTNODES}-temp
            $MV -f ${EXTNODES}-temp ${EXTNODES}
          else
            $CAT $EXTNODESTMP
          fi

          debugLog "Retrieved node list from $i.$TOPDOMAIN"

          checkRunOnce

          if [ $dry_run -eq 0 ]; then
            sleep $sleep
          else
            sleep $short_sleep
          fi

        else
          $GREP -q ";Diff" $EXTNODESTMP

          if [ $? -eq 0 ]; then
            # This is a differential
            debugLog "Retrieved differential patch from $i.$TOPDOMAIN"
            debugLog "$(patch $EXTNODES $EXTNODESTMP)"

            checkRunOnce

            debugLog "Sleeping for $sleep"
            sleep $sleep
          else
            $GREP -q ";Empty" $EXTNODESTMP

            if [ $? -eq 0 ]; then
              debugLog "Empty patch from $i.$TOPDOMAIN. Sleeping for $sleep."
              debugLog ""

              checkRunOnce

              sleep $sleep
            fi

            errorLog "Retreived garbage node list from $i.$TOPDOMAIN. Moving to next node server in list..."

            $RM -f $EXTNODESTMP
            downloads=0
            retries=$((retries + 1))

            if [ $retries -gt 50 ]; then
              sleep $long_sleep # doze to lighten network load
            else
              sleep 30
            fi

            return 2
          fi
        fi
      else
        $RM -f $EXTNODESTMP
        if [ $verbose -ne 0 ]; then
          errorLog "Problem retrieving node list from $i.$TOPDOMAIN, trying another server"
          downloads=0
          retries=$((retries + 1))
        fi
        if [ $verbose -eq 0 ]; then
          if [ $retries -gt 50 ]; then
            sleep $long_sleep # doze for a bit to lighten network load
          else
            sleep 30
          fi
        else
          debugLog "Sleeping for next subdomain"
          sleep $short_sleep
        fi
      fi
    done
  done
}

while [ 1 ]; do
  getNodes
done
