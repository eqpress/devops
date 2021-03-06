<?php

$domain = $_GET['domain'];
	$last_few_days = 0;
	$busiest_day = array( 0, 0, 0, 0, 0 );
	$db_query = "
		SELECT date, hits, visits, unique_visitors, bytes_transfered
		FROM stats WHERE domain_id
		IN (
			SELECT ID
			FROM domains
			WHERE domain LIKE '$domain')
		ORDER BY date DESC";
	$dbh = new mysqli( 'localhost', 'swp_webstats', 'c3hXyH2jhrW7YL7w26qRU', 'swp_webstats' );
	if ( $dbh->connect_error ) {
		process_errors( "Connect failed to swp_webstats for domain $domain: " . $dbh->connect_errno . ' : ' . $dbh->connect_error, true );
	}
	if ( $db_results = $dbh->query( $db_query ) ) {
		$all_stats = $db_results->fetch_all();
		if ( !empty( $all_stats ) ) {
			$total_bytes = $month_hits = $month_visits = $month_uniques = $month_bytes = 0;
			$this_month = preg_replace( '/-[0-9][0-9]$/', '', $all_stats[0][0] );
			foreach ( $all_stats as $stats ) {
				if ( $busiest_day[4] < $stats[4] )
					$busiest_day = $stats;
				if ( $last_few_days < 31 ) {
					$daily_stats[] = $stats;
					$last_few_days++;
				}
				$total_bytes += $stats[4];
				$same_month = strpos( $stats[0], $this_month );
				if ( $same_month === false ) {
					$st['monthly'][$this_month] = array( 'hits' => $month_hits, 'visits' => $month_visits, 'bytes' => $month_bytes );
					$month_hits = $month_visits = $month_uniques = $month_bytes = 0;
					$month_bytes += $stats[4];
					$this_month = preg_replace( '/-[0-9][0-9]$/', '', $stats[0] );
				} else {
					$month_hits += $stats[1];
					$month_visits += $stats[2];
					$month_uniques += $stats[3];
					$month_bytes += $stats[4];
				}
			}
			$st['monthly'][$this_month] = array( 'hits' => $month_hits, 'visits' => $month_visits, 'bytes' => $month_bytes );
			$st['total_bytes'] = $total_bytes;
                        $st['busiest_day'] = array( 'date' => $busiest_day[0], 'hits' => $busiest_day[1], 'visits' => $busiest_day[2], 'bytes' => $busiest_day[4] );
			foreach ( $daily_stats as $ds ) {
                                $st['recent'][$ds[0]] = array ( 'hits' => $ds[1], 'visits' => $ds[2], 'bytes' => $ds[4] );
			}
		} else {
			echo "No stats yet.";
		}
	} else {
		process_errors( 'Results for query not found', true );
	}
	$dbh->close();
echo json_encode($st);

/**
 * Process errors
 *
 * @param string $message is the error message to write to the log and/or screen.
 * @param boolean $exit_now will determine whether or not to terminate the process.
 * 
 */
function process_errors( $message, $exit_now = false ) {
	global $all_errors;
	$all_errors[] = $message;
	error_log( $message );
	if ( $exit_now ) {
		var_dump( $all_errors );
		error_log( var_export( $all_errors, true ) );
		exit;
	}
}

