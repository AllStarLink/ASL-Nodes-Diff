<?php

require_once __DIR__.'/../vendor/autoload.php';

$dotenv = \Dotenv\Dotenv::createImmutable(__DIR__."/..");
$dotenv->load();

require_once __DIR__.'/DB.php';
require_once __DIR__.'/functions.php';

ini_set('display_errors', env('APP_DEBUG', false));