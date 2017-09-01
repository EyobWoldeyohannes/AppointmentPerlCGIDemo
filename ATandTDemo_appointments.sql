DROP TABLE IF EXISTS `appointments`;
CREATE TABLE `appointments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` varchar(45) NOT NULL,
  `time` varchar(45) NOT NULL,
  `disc` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1;

LOCK TABLES `appointments` WRITE;
INSERT INTO `appointments` VALUES (1,'2017-10-01','20:08','This is eyob');
INSERT INTO `appointments` VALUES (2,'2017-11-01','22:08','This is another eyob');
UNLOCK TABLES;
