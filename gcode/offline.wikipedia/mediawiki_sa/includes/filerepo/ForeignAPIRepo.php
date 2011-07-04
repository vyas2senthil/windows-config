<?php
/**
 * Foreign repository accessible through api.php requests.
 *
 * @file
 * @ingroup FileRepo
 */

/**
 * A foreign repository with a remote MediaWiki with an API thingy
 * Very hacky and inefficient
 * do not use except for testing :D
 *
 * Example config:
 *
 * $wgForeignFileRepos[] = array(
 *   'class'                  => 'ForeignAPIRepo',
 *   'name'                   => 'shared',
 *   'apibase'                => 'http://en.wikipedia.org/w/api.php',
 *   'fetchDescription'       => true, // Optional
 *   'descriptionCacheExpiry' => 3600,
 * );
 *
 * @ingroup FileRepo
 */
class ForeignAPIRepo extends FileRepo {
	var $fileFactory = array( 'ForeignAPIFile', 'newFromTitle' );
	var $apiThumbCacheExpiry = 86400;
	protected $mQueryCache = array();
	protected $mFileExists = array();

	function __construct( $info ) {
		parent::__construct( $info );
		
		// http://commons.wikimedia.org/w/api.php		
		$this->mApiBase = isset( $info['apibase'] ) ? $info['apibase'] : null; 

		if( isset( $info['apiThumbCacheExpiry'] ) ) {
			$this->apiThumbCacheExpiry = $info['apiThumbCacheExpiry'];
		}
		if( !$this->scriptDirUrl ) {
			// hack for description fetches
			$this->scriptDirUrl = dirname( $this->mApiBase );
		}
		// If we can cache thumbs we can guess sane defaults for these
		if( $this->canCacheThumbs() && !$this->url ) {
			global $wgLocalFileRepo;
			$this->url = $wgLocalFileRepo['url'];
		}
		if( $this->canCacheThumbs() && !$this->thumbUrl ) {
			$this->thumbUrl = $this->url . '/thumb';
		}
	}

	/**
	 * Per docs in FileRepo, this needs to return false if we don't support versioned
	 * files. Well, we don't.
	 */
	function newFile( $title, $time = false ) {
		if ( $time ) {
			return false;
		}
		return parent::newFile( $title, $time );
	}

/**
 * No-ops
 */
	function storeBatch( $triplets, $flags = 0 ) {
		return false;
	}
	function storeTemp( $originalName, $srcPath ) {
		return false;
	}
	function append( $srcPath, $toAppendPath, $flags = 0 ){
		return false;
	}
	function publishBatch( $triplets, $flags = 0 ) {
		return false;
	}
	function deleteBatch( $sourceDestPairs ) {
		return false;
	}


	function fileExistsBatch( $files, $flags = 0 ) {
		$results = array();
		foreach ( $files as $k => $f ) {
			if ( isset( $this->mFileExists[$k] ) ) {
				$results[$k] = true;
				unset( $files[$k] );
			} elseif( self::isVirtualUrl( $f ) ) {
				# TODO! FIXME! We need to be able to handle virtual
				# URLs better, at least when we know they refer to the
				# same repo.
				$results[$k] = false;
				unset( $files[$k] );
			}
		}

		$results = $this->fetchImageQuery( array( 'titles' => implode( $files, '|' ),
											'prop' => 'imageinfo' ) );
		if( isset( $data['query']['pages'] ) ) {
			$i = 0;
			foreach( $files as $key => $file ) {
				$results[$key] = $this->mFileExists[$key] = !isset( $data['query']['pages'][$i]['missing'] );
				$i++;
			}
		}
	}
	function getFileProps( $virtualUrl ) {
		return false;
	}

	function fetchImageQuery( $query ) {
		global $wgMemc;

		$query = array_merge( $query,
				      array(
					    'format' => 'json',
					    'action' => 'query',
					    'redirects' => 'true' 
					    ) );
		if ( $this->mApiBase ) {
			$url = wfAppendQuery( $this->mApiBase, $query );
		} else {
			$url = $this->makeUrl( $query, 'api' );
		}

		$md5s = md5($url);
		$md5s_d = substr($md5s, 0, 2);
		$md5s_f = substr($md5s, 2);
		$md5s_p = "images_cache/$md5s_d/$md5s_f.mwI";
		if (file_exists($md5s_p)) {
			return FormatJson::decode( file_get_contents($md5s_p), true );
		}
		wfDebugLog('bhj', __METHOD__ . " bhj fetching $url\n"); 
		system("wiki-cache-image-info " . escapeshellarg($url) . " " . escapeshellarg($md5s_p)); // put it background
		return null;
	}

	function getImageInfo( $data ) {
		if( $data && isset( $data['query']['pages'] ) ) {
			foreach( $data['query']['pages'] as $info ) {
				if( isset( $info['imageinfo'][0] ) ) {
					return $info['imageinfo'][0];
				}
			}
		}
		return false;
	}

	function findBySha1( $hash ) {
		$results = $this->fetchImageQuery( array(
										'aisha1base36' => $hash,
										'aiprop'       => ForeignAPIFile::getProps(),
										'list'         => 'allimages', ) );
		$ret = array();
		if ( isset( $results['query']['allimages'] ) ) {
			foreach ( $results['query']['allimages'] as $img ) {
				// 1.14 was broken, doesn't return name attribute
				if( !isset( $img['name'] ) ) {
					continue;
				}
				$ret[] = new ForeignAPIFile( Title::makeTitle( NS_FILE, $img['name'] ), $this, $img );
			}
		}
		return $ret;
	}

	function getThumbUrl( $name, $width=-1, $height=-1 ) {
		$data = $this->fetchImageQuery( array(
			'titles' => 'File:' . $name,
			'iiprop' => 'url',
			'iiurlwidth' => $width,
			'iiurlheight' => $height,
			'prop' => 'imageinfo' ) );
		$info = $this->getImageInfo( $data );

		if( $data && $info && $info['thumburl'] ) {
			wfDebugLog("bhj",  __METHOD__ . " got remote thumb " . $info['thumburl'] . "\n" );
			return $info['thumburl'];
		} else {
			return false;
		}
	}

	function getThumbUrlFromCache( $name, $width, $height ) {
		global $wgMemc, $wgUploadPath, $wgServer, $wgUploadDirectory;

		if ( 1 ) {
			$url = $this->getThumbUrl( $name, $width, $height );
			$md5s = md5($url);
			$md5s_d = substr($md5s, 0, 2);
			$md5s_f = substr($md5s, 2);
			$ext = strrchr($url, '.');
			$md5s_p = "images/thumb/$md5s_d/$md5s_f$ext";

			if (file_exists($md5s_p)) {
				return "http://localhost:8000/scripts/$md5s_p";
			}
			system("wiki-cache-image-thumb " . escapeshellarg($url) . " " . escapeshellarg($md5s_p) . "&"); // put it background
			return $url;
		}

		$key = $this->getLocalCacheKey( 'ForeignAPIRepo', 'ThumbUrl', $name );
		if ( $thumbUrl = $wgMemc->get($key) ) {
			wfDebugLog("bhj", "Got thumb from local cache. $thumbUrl \n");
			return $thumbUrl;
		}
		else {
			$foreignUrl = $this->getThumbUrl( $name, $width, $height );
			if( !$foreignUrl ) {
				wfDebugLog("bhj",  __METHOD__ . " Could not find thumburl\n" );
				return false;
			}
			$thumb = Http::get( $foreignUrl );
			if( !$thumb ) {
				wfDebugLog("bhj",  __METHOD__ . " Could not download thumb\n" );
				return false;
			}
			// We need the same filename as the remote one :)
			$fileName = rawurldecode( pathinfo( $foreignUrl, PATHINFO_BASENAME ) );
			$path = 'thumb/' . $this->getHashPath( $name ) . $name . "/";
			if ( !is_dir($wgUploadDirectory . '/' . $path) ) {
				if( !wfMkdirParents($wgUploadDirectory . '/' . $path) ) {
					wfDebugLog("bhj",   __METHOD__ . " could not create directory for thumb\n" );
					return $foreignUrl;
				}
			}
			$localUrl =  $wgServer . $wgUploadPath . '/' . $path . $fileName;
			# FIXME: Delete old thumbs that aren't being used. Maintenance script?
			wfSuppressWarnings();
			if( !file_put_contents($wgUploadDirectory . '/' . $path . $fileName, $thumb ) ) {
				wfRestoreWarnings();
				wfDebugLog("bhj",  __METHOD__ . " could not write to thumb path\n" );
				return $foreignUrl;
			}
			wfRestoreWarnings();
			$wgMemc->set( $key, $localUrl, $this->apiThumbCacheExpiry );
                        wfDebugLog('bhj', __METHOD__ . "got local thumb $localUrl, saving to cache \n");
			return $localUrl;
		}
	}

	/**
	 * @see FileRepo::getZoneUrl()
	 */
	function getZoneUrl( $zone ) {
		switch ( $zone ) {
			case 'public':
				return $this->url;
			case 'thumb':
				return $this->thumbUrl;
			default:
				return parent::getZoneUrl( $zone );
		}
	}

	/**
	 * Are we locally caching the thumbnails?
	 * @return bool
	 */
	public function canCacheThumbs() {
		return ( $this->apiThumbCacheExpiry > 0 );
	}
}
