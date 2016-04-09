<?php

'cli' == php_sapi_name() or die('Requires CLI mode.');

define('__DIR_ROOT', __DIR__);

require __DIR_ROOT . '/src/autoload.php';

set_time_limit(0);

start();
