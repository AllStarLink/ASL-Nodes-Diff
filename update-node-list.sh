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

# Diagnostics
# Enable this for debugging
verbose=0
long_sleep=300
sleep=60
short_sleep=5
dry_run=0
downloads=0
retries=0
last_hash=""

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

getLastHash() {
  last_hash=$(grep SHA1 $EXTNODESTMP | cut -d "=" -f 2 | tail -n 1)
  debugLog "New Hash: $last_hash"
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

      wget --user-agent="$USERAGENT" -q -O $EXTNODESTMP $url
      res=$?

      debugLog "$(date)"
      getLastHash

      if [ $res -eq 0 ]; then

        # Determine if differential
        grep -q ";Full" $EXTNODESTMP

        if [ $? -eq 0 ]; then
          # Full Download
          downloads=$((downloads + 1))
          retries=0

          if [ $dry_run -eq 0 ]; then
            chmod 700 $EXTNODESTMP
            cat ${EXTNODESTMP} > ${EXTNODES}
          else
            cat $EXTNODESTMP
          fi

          debugLog "Retrieved full node list from $i.$TOPDOMAIN. Sleeping."
          
          checkRunOnce

          if [ $dry_run -eq 0 ]; then
            sleep $sleep
          else
            sleep $short_sleep
          fi

        else
          grep -q ";Diff" $EXTNODESTMP

          if [ $? -eq 0 ]; then
            # This is a differential
            debugLog "Retrieved differential patch from $i.$TOPDOMAIN"

            rm -f $EXTNODESTMP.tmp*
            cp $EXTNODES $EXTNODESTMP.tmp

            patch_out=$(patch -t -s $EXTNODESTMP.tmp $EXTNODESTMP)
            patch_res=$?

            debugLog "$patch_out"
            debugLog "Patch status: $patch_res"

            if [ $patch_res -eq 0 ]; then
              cat $EXTNODESTMP.tmp > $EXTNODES
              checkRunOnce
            else
              last_hash=""
            fi

            rm -f $EXTNODESTMP.tmp*

            debugLog "Sleeping for $sleep"
            sleep $sleep
          else
            grep -q ";Empty" $EXTNODESTMP

            if [ $? -eq 0 ]; then
              debugLog "Empty patch from $i.$TOPDOMAIN. Sleeping for $sleep."

              checkRunOnce

              sleep $sleep
            else
              errorLog "Retreived garbage node list from $i.$TOPDOMAIN. Moving to next node server in list..."

              rm -f $EXTNODESTMP*

              last_hash=""
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
        fi
      else
        rm -f $EXTNODESTMP
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
