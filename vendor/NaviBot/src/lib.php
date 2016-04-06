<?php

function start() {
    $i = 0;
    $totalTime = 0.00;
    foreach (load_locations() as $locationRow) {
        foreach (load_keywords() as $keywordRow) { ++$i;
            $url = SERVICE_URL . str_replace([
                '%%term%%', '%%order%%', '%%dir%%', '%%radius%%', '%offset%%', '%%ll%%'
            ], [
                $keywordRow['keyword'], 'distance', 'asc', 1000, 0, $locationRow['ll']
            ], SEARCH_TPL);

            $start = microtime(true);
            #$headers = get_headers(urlencode($url), 1);
            $headers['Status'] = '200 OK';
            $time = round(microtime(true) - $start);
            $time = 0.123456;
            $totalTime += $time;

            if ( '200 OK' == $headers['Status'] ) {
                printf("\033[32m%s\033[0m: %s [%g sec] (iteration %d) \n", $headers['Status'], $url, $time, $i);
            } else {
                printf("\033[31m%s\033[0m: %s \n", $headers['Status'], $url);
                exit;
            } // end if

            #usleep(250000); # 0.25s
        } // end foreach
    } // end foreach
    printf("Done. Total request time %g sec, average request %g sec. \n", $totalTime, $totalTime/$i);
} // end func

function load_keywords() {
    $h = fopen(__DIR_ROOT . '/data/keywords.csv', 'r');
    $data = [];
    $i = 0;
    while ( $row = fgetcsv($h, 32, ';', '"') ) {
        if ( $i > 0 ) {
            if ( ! empty($row[0]) && ! empty($row[1]) && ! empty($row[2]) ) {
                $data[] = [
                    'keyword'   => $row[0],
                    'lang'      => $row[1],
                    'category'  => $row[2],
                ];
            } // end if
        } // end if
        ++$i;
    } // end while
    return $data;
} // end func

function load_locations() {
    $h = fopen(__DIR_ROOT . '/data/locations.csv', 'r');
    $data = [];
    $i = 0;
    while ( $row = fgetcsv($h, 32, ';', '"') ) {
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
