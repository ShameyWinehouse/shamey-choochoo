CREATE TABLE `redm`.`trains` (`name` VARCHAR(20) NOT NULL , `fuel` INT NOT NULL DEFAULT '0' , UNIQUE (`name`)) ENGINE = InnoDB; 

INSERT INTO `trains` (`name`, `fuel`) VALUES ('east', '0');