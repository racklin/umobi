<?php
$apcEnable = extension_loaded('apc');
$contentType = 'text/javascript';
$jsfiles = array (
  '../LICENSE.txt',
  'define.js',
  'classList.js',
  // 'depend.js',
  // 'text.js',
  // 'domReady.js',
  'jquery.js',
  'jquery.hashchange.js',
  // 'z.js',
  // 'zepto.js',
  // 'zepto.min.js',

  // TODO: use coffee-script to filter these coffee-script
  // 'coffee-script.js',
  // 'cs.js',
);

$coffeefiles = array(
  'u.dom.coffee',
  'u.coffee',
  'umobi.core.coffee',
  'umobi.support.coffee',
  'umobi.button.coffee',
  'umobi.listview.coffee',
  'umobi.navigation.coffee',
  'umobi.offlinecache.coffee',
  'umobi.scroller.coffee',
  'umobi.widget.coffee',
  'umobi.page.coffee',
  'umobi.zoom.coffee',
  'umobi.init.coffee',
);

function findbin($bin)
{
	$binpaths = array(
		'/usr/bin',
		'/usr/local/bin',
		'/usr/share/bin',
		'/opt/local/bin',
   	);
	foreach( $binpaths as $path ) {
		if( file_exists($path . DIRECTORY_SEPARATOR . $bin) )
			return $path . DIRECTORY_SEPARATOR . $bin;
	}
}


function runCoffee($files)
{
	$desc = array(
		0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
		1 => array("pipe", "w"),  // stdout is a pipe that the child will write to
		# 2 => array("pipe", "w", "a") // stderr is a file to write to
	);
	$node   = findbin('node');
	$coffee = findbin('coffee');
	$cwd = getcwd();
	$pipes = array();
	$process = proc_open("$node $coffee --bare --stdio --print", $desc, $pipes, $cwd);
	if (is_resource($process)) {
		$content = '';
		foreach( $files as $file ) {
			$content .= file_get_contents($file);
		}
		fwrite($pipes[0], $content);
		fclose($pipes[0]);
		$js = stream_get_contents($pipes[1]);
		fclose($pipes[1]);
		$return_value = proc_close($process);
		return $js;
	} else {
		header('HTTP/1.0 500 Process Error');
		die('Can not open coffee-script process');
	}
}


function getCommitId() {
	$gitHeadPath = "../.git/logs/HEAD";
	$logs = ( is_readable( $gitHeadPath ) ? file_get_contents( $gitHeadPath ) : false );
	if ( $logs ) {
		$logs = explode( "\n", $logs );
		$n_logs = count( $logs );
		if ( $n_logs > 1 ) {
			$log = explode( " ", $logs[ $n_logs - 2 ] );
			if ( count( $log ) > 1 ) {
				return $log[ 1 ];
			}
		}
	}
	return false;
}

function aggregateContent($commitId)
{
	global $jsfiles;
	global $coffeefiles;

	$output = '';
	$comment = '';
	if ( $commitId )
		$comment = "/* git commitid " . $commitId . " */\n";

	$output .= $comment . "\n";
	foreach( $jsfiles as $jsfile ) {
		$output .= file_get_contents($jsfile);
	}
	$output .= runCoffee($coffeefiles);
	return $output;
}

header('Content-Type: ' . $contentType);
$commitId = getCommitId();
$cacheId = 'umobi-js-content:' . $commitId;

if($apcEnable) {
	$cache =  apc_fetch($cacheId);
	if($cache) {
		echo $cache;
		exit(0);
	}
}

$content = aggregateContent($commitId);
if($apcEnable)
	apc_store($cacheId,$content);
echo $content;
