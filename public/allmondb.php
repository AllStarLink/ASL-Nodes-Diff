<?php
/*
 * AllStarLink Allmon Nodes list
 *
 * Copyright (C) 2018-2021, AllStarLink, Inc.
 *
 * Written by:
 * Tim Sawyer, WD6AWP 
 * Tom Hayward, KD7LXL (caching implementation)
 * Bryan Fields, W9CR (architecture/test)
 * Rob Vella, KK9ROB
 * 
 * See http://allstarlink.org for more information about
 * this project. Please do not directly contact
 * any of the maintainers of this project for assistance;
 * the project provides a web site, and mailing lists
 * for your use.
 *
 * This program is free software, distributed under the terms of
 * the GNU General Public License Version 2. See the LICENSE file
 * at the top of the source tree.
 */

$cacheFile = "/tmp/allmon.txt";
$cacheTime = 60;  // seconds
$regTime = 600;

/* Connect to database */
require_once __DIR__.'/../include/autoload.php';

// Serve from the cache if it is younger than $cachetime
if (file_exists($cacheFile) && (time() - $cacheTime < filemtime($cacheFile))) {
    $data = unserialize(file_get_contents($cacheFile));
    $genTime = filemtime($cacheFile);
    $servedFromCache = "Yes";
} else {
    $genTime = time();
    $timeout = $genTime - $regTime;
    $servedFromCache = "No";
    $queryStart = microtime(true);
    $data['rows'] = getNodes();
    $data['queryTime'] = microtime(true) - $queryStart;

    // cache getNodes() result and make $queryTime persist for wget.
    file_put_contents($cacheFile, serialize($data));
}

header("Content-type: text/plain");
header("Cache-Control: public, max-age=$cacheTime");

printNodes($data['rows']);

// Time to serve page
$serveTime = microtime(true) - $_SERVER["REQUEST_TIME_FLOAT"];
$records = count($data['rows']);

// Print stats
printf(";Generated $records records in %.3f seconds.\n", round($data['queryTime'], 3));
printf(";Served in %.3f seconds.\n", round($serveTime, 3));
print ";Served from cache: $servedFromCache\n";
print ";Generated at ";
print gmdate("Y-m-d H:i:s", $genTime);
echo " UTC by ".getenv("HOSTNAME")."\n\n";

/************************************************************
 * End of program execution. functions() below is ok in php *
 ************************************************************/
function getNodes()
{
    /* Gather all nodes into $rows */

    $SQL = "SELECT name,callsign,node_frequency,location FROM user_Nodes JOIN user_Servers USING (Config_ID)";
    $SQL .= " WHERE Status='Active' AND name > ''";
    
    $sth = \DB::prepare($SQL);
    $sth->execute();
    $rows = $sth->fetchAll();

    // Rather then use ORDER BY 'name' in the query (which slows it), we use php sort()  
    sort($rows);

    return $rows;
}

function printNodes($rows)
{
    foreach ($rows as $row) {
        $line = implode('|', $row);
        print "$line\n";
    }
    print "\n\n";
}