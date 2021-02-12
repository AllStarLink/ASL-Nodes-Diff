<?php

/*
 * AllStarLink extnodes generator
 *
 * Copyright (C) 2018-2021, AllStarLink, Inc.
 *
 * Written by:
 * Tim Sawyer, WD6AWP 
 * Rob Vella, KK9ROB (send patch diff instead of full file)
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
 * the GNU General Public License Version 3. See the LICENSE file
 * at the top of the source tree.
 */

require_once __DIR__.'/../include/autoload.php';

$cacheTime = 10;  // seconds
$maxRegTime = 600;

$dataDir = __DIR__.'/../data/';
$fullFile = $dataDir.'extnodes.txt';

// Serve from the cache if it is younger than $cachetime
if (file_exists($fullFile) && (time() - $cacheTime < filemtime($fullFile))) {
    $full = file_get_contents($fullFile);
} else {
    $genTime = time();
    $timeout = $genTime - $maxRegTime;
    $queryStart = microtime(true);
    $rows = getNodes($timeout);
    $queryTime = microtime(true) - $queryStart;

    // Just return the total
    if (isset($_GET['total'])) {
        header("Cache-Control: no-cache");
        header("Content-type: text/plain");
        echo count($rows);
        exit;
    }

    ob_start();
    echo ";Full\n";
    echo "[extnodes]\n\n";

    printNodes($rows);
    
    // Time to serve page
    $serveTime = microtime(true) - $_SERVER["REQUEST_TIME_FLOAT"];
    $records = count($rows);

    // Footer stats
    $hostname = getenv('HOSTNAME');
    printf(";Generated $records records in %.3f seconds.\n", round($queryTime, 3));
    echo ";Generated at ";
    echo gmdate("Y-m-d H:i:s", $genTime);
    echo " UTC by ".$hostname."\n";
    
    $full = ob_get_contents();
    ob_end_clean();
    $sha1 = substr(sha1($full), 0, 9);
    
    $full .= ";SHA1=$sha1\n\n";
    
    file_put_contents($fullFile, $full);
    copy($fullFile, $fullFile . "." . $sha1);
}

if (!isset($_GET['hash'])) {
    printOutput($full);
}

// See if patch hash exists
$hash = substr(alphaOnly($_GET['hash']), 0, 9);
$hashFile = "{$fullFile}.{$hash}";

if (!file_exists($hashFile)) {
    printOutput($full);
}

$patch = shell_exec("diff $hashFile $fullFile");

// In case a prune happens or there's no difference
if (empty($patch)) {
    printOutput(";Empty");
}

printOutput(";Diff\n".$patch, $hash);

function printOutput($data, $etag = false)
{
    header("Cache-Control: public, max-age=30");
    header("Content-type: text/plain");
    
    if ($etag) {
        header("ETag: \"$etag\"");
    }
    
    echo $data;
    exit;
}