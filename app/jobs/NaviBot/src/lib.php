<?php

function start() {
    print "\nStarting NaviBot...\nLoading data...\n";
    $i                = 0;
    $totalTime        = 0.00;
    $locations        = load_locations(); shuffle($locations);
    $keywords         = load_keywords();
    $businesses       = load_businesses();
    $keywords         = array_merge($businesses, $keywords); shuffle($keywords);
    $totalIterations  = count($locations) * count($keywords);
    printf("Loaded %s locations and %s keywords (including %s businesses) \nStarting total %s iterations... \n", count($locations), count($keywords), count($businesses), $totalIterations);

    foreach ($locations as $locationRow) {
        foreach ($keywords as $keywordRow) { ++$i;

            $url = build_url($keywordRow['keyword'], $locationRow['ll']);
            $start = microtime(true);
            //$headers = get_headers($url, 1);
            $headers['Status'] = ( rand(1, 100) > 50 ? '200 OK' : '500 Internal Server Error' );
            //$time = microtime(true) - $start;
            $time = 0.123456;
            $totalTime += $time;

            if ( '200 OK' == $headers['Status'] ) {
                printf("\033[32m%s\033[0m: %s | kw: '%s'@'%s' [%g sec] (iteration %d of %d)\n", $headers['Status'], $url, $keywordRow['keyword'], $locationRow['name'], $time, $i, $totalIterations);
            } else {
                printf("\033[31m%s\033[0m: %s | kw: '%s'@'%s' [%g sec] (iteration %d of %d)\n", $headers['Status'], $url, $keywordRow['keyword'], $locationRow['name'], $time, $i, $totalIterations);
            } // end if

            if ( $i == REQUEST_LIMIT ) {
                printf("Reached request count limit (%d), breaking iterations \n", REQUEST_LIMIT);
                break 2;
            } // end if

            #usleep(250000); # 0.25s
        } // end foreach
    } // end foreach
    printf("Done. Total request time %g sec, average request %g sec. \n", $totalTime, $totalTime/$i);
} // end func

function load_keywords() {
    $used = array();
    $h = fopen(__DIR_ROOT . '/data/keywords.csv', 'r');
    $data = [];
    $i = 0;
    $skip = [ 'duplicate' => 0, 'length' => 0 ];
    while ( $row = fgetcsv($h, 1024, ';', '"') ) {
        if ( $i > 0 ) {
            if ( ! empty($row[0]) && ! empty($row[1]) && ! empty($row[2]) ) {

                if ( in_array(strtolower($row[0]), $used) ) {
                    ++$skip['duplicate'];
                } elseif ( ! strlen(trim($row[0])) ) {
                    ++$skip['length'];
                } else {
                    $data[] = [
                        'keyword'   => trim($row[0]),
                        'lang'      => $row[1],
                        'category'  => $row[2],
                    ];
                    $used[] = strtolower($row[0]);
                } // end if

            } else {
                printf("Skipping row %s (seems to be empty, please check keywords.csv for details) \n", $i+1);
            } // end if
        } // end if
        ++$i;
    } // end while
    printf("Skipped %s keywords because of duplicity and %s because of length\n", $skip['duplicate'], $skip['length']);
    return $data;
} // end func

function load_locations() {
    $h = fopen(__DIR_ROOT . '/data/locations.csv', 'r');
    $data = [];
    $i = 0;
    while ( $row = fgetcsv($h, 1024, ';', '"') ) {
        if ( $i > 0 ) {
            $data[] = [
                'll'    => $row[0],
                'lang'  => $row[1],
                'name'  => $row[2],
            ];
        } // end if
        ++$i;
    } // end while
    return $data;
} // end func

function load_businesses() {
    $h = fopen(__DIR_ROOT . '/data/businesses.csv', 'r');
    $data = [];
    $i = 0;
    while ( $row = fgetcsv($h, 1024, ';', '"') ) {
        if ( $i > 0 ) {
            $data[] = [
                'keyword' => $row[0],
                'lang'    => $row[1],
                'name'    => $row[2],
            ];
        } // end if
        ++$i;
    } // end while
    return $data;
} // end func

function build_url($keyword, $location) {
    return SERVICE_URL . str_replace([
        '%%term%%', '%%order%%', '%%dir%%', '%%radius%%', '%offset%%', '%%ll%%'
    ], [
        rawurlencode($keyword), 'distance', 'asc', 1000, 0, $location
    ], SEARCH_TPL);
} // end func
