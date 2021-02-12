<?php
/*
 * Allstar Link Network Portal
 *
 * Copyright (C) 2021, AllStarLink, Inc
 *
 * Rob Vella, KK9ROB <me@robvella.com>
 * Tim Sawyer, WD6AWP <tisawyer@gmail.com>
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

/**
 * Class DB
 * @author Rob Vella KK9ROB <me@robvella.com>
 */
class DB
{
    public static $dbh;
    protected static $instance;
    protected $options = [
        PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8',
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_PERSISTENT => true
    ];
    
    public function __construct($forceConnection = false)
    {
        if (!$forceConnection && self::$dbh) {
            return self::$dbh;
        }
        
        // Connect to database
        $dsn = "mysql:host=".env('DB_HOST').";port=".env('DB_PORT', 3306)
            . ";dbname=".env('DB_DATABASE');

        try {
            self::$dbh = new PDO($dsn, env('DB_USERNAME'), env('DB_PASSWORD'), $this->options);
        } catch(PDOException $e) {
            echo "\nDB connect failed: " . $e->getMessage() . ".\n\n";
        }
        
        return $this;
    }

    /**
     * @return DB
     */
    public static function getInstance()
    {
        if (!self::$instance) {
            self::$instance = new DB;
        }
        
        return self::$instance;
    }

    /**
     * @param $name
     * @param $arguments
     * @return false|mixed
     */
    public function __call($name, $arguments)
    {
        return call_user_func_array([self::$dbh, $name], $arguments);
    }

    /**
     * @param $name
     * @param $arguments
     * @return false|mixed
     */
    public static function __callStatic($name, $arguments)
    {
        return call_user_func_array([self::getInstance(), $name], $arguments);
    }
}