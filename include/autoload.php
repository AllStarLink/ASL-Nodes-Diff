<?php

require_once __DIR__.'/../vendor/autoload.php';

$dotenv = \Dotenv\Dotenv::createImmutable(__DIR__."/..");
$dotenv->load();

require_once __DIR__.'/DB.php';
require_once __DIR__.'/functions.php';

error_reporting(E_ALL);
ini_set('display_errors', env('APP_DEBUG', false));