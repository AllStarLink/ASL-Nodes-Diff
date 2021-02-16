<?php
/*
 * AllStarLink extnodes generator
 *
 * Copyright (C) 2018, AllStarLink, Inc.
 *
 * Written by:
 * Tim Sawyer, WD6AWP 
 * Tom Hayward, KD7LXL (caching implementation)
 * Bryan Fields, W9CR (architecture/test)
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

$cacheFile = "/tmp/extnodes.txt";
$cacheTime = 30;  // seconds
$maxRegTime = 600;

/* Connect to database */
require_once __DIR__.'/../include/autoload.php';

// Serve from the cache if it is younger than $cachetime
if (file_exists($cacheFile) && (time() - $cacheTime < filemtime($cacheFile))) {
    $data = unserialize(file_get_contents($cacheFile));
    $genTime = filemtime($cacheFile);
    $servedFromCache = "Yes";
    $cacheTime = $cacheTime - (time() - filemtime($cacheFile));
} else {
    $genTime = time();
    $timeout = $genTime - $maxRegTime;
    $servedFromCache = "No";
    $queryStart = microtime(true);
    $data['rows'] = getNodes($timeout);
    $data['queryTime'] = microtime(true) - $queryStart;

    // cache getNodes() result and make $queryTime persist for wget.
    file_put_contents($cacheFile, serialize($data));
}

$rows = $data['rows'];

// Just return the total
if (isset($_GET['total'])) {
    header("Cache-Control: no-cache");
    header("Content-type: text/plain");
    echo count($rows);
    exit;
}

header("Cache-Control: public, max-age=$cacheTime");
header("Content-type: text/plain");

try {
    echo "[extnodes]\n\n";

    printNodes($rows);
    
    // Time to serve page
    $serveTime = microtime(true) - $_SERVER["REQUEST_TIME_FLOAT"];
    $records = count($rows);

    // echo stats
    $docker_host = gethostname();
    printf(";Generated $records records in %.3f seconds.\n", round($data['queryTime'], 3));
    printf(";Served in %.3f seconds.\n", round($serveTime, 3));
    echo ";Served from cache: $servedFromCache\n";
    echo ";Generated at ";
    echo gmdate("Y-m-d H:i:s", $genTime);
    echo " UTC by ".getenv("HOSTNAME")."\n\n";
} catch (\Throwable $e) {
    http_response_code(500);
}