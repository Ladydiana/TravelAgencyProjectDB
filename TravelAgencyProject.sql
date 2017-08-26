# @Author: Culincu Diana Cristina
# @Github: https://github.com/Ladydiana/TravelAgencyProjectDB

DROP DATABASE IF EXISTS Travel;
CREATE DATABASE IF NOT EXISTS Travel;
USE Travel;


/*
 *	TABLE DEFINITIONS
 */
 
DROP TABLE IF EXISTS CONTINENTS;
CREATE TABLE IF NOT EXISTS CONTINENTS
	(
		contID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
        contName VARCHAR(25) NOT NULL UNIQUE
    )
;


DROP TABLE IF EXISTS COUNTRIES;
CREATE table if not exists COUNTRIES 
	(
		id integer not null primary key auto_increment,
		name VARCHAR(45)
    )
;

DROP table IF EXISTS COUNTRIES;
CREATE table if not exists COUNTRIES 
	(
		ctryID integer not null primary key auto_increment,
		ctryName VARCHAR(45) unique,
        id_cont INTEGER NOT NULL,
        FOREIGN KEY(id_cont) REFERENCES CONTINENTS(contID)
        ON DELETE CASCADE ON UPDATE CASCADE
    )
;


DROP TABLE IF EXISTS CITIES;
CREATE table if not exists CITIES 
	(
		id integer not null primary key auto_increment,
		name VARCHAR(60),
        id_country integer not null,
        FOREIGN KEY(id_country) references COUNTRIES(ctryID)
        ON DELETE CASCADE ON UPDATE CASCADE
    )
;

ALTER table CITIES add UNIQUE index (name, id_country);
ALTER table CITIES CHANGE name citName VARCHAR(60) NOT NULL;
ALTER table CITIES CHANGE id id integer not null;
ALTER table CITIES DROP PRIMARY KEY;
ALTER table CITIES CHANGE id citID integer not null primary key auto_increment;

DROP TABLE IF EXISTS POSITIONS;
CREATE TABLE IF NOT EXISTS POSITIONS (
	posID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
	posName VARCHAR(45) NOT NULL UNIQUE,
    posBaseSalary DOUBLE(4,2) NOT NULL
);

DROP TABLE IF EXISTS EMPLOYEES;
CREATE TABLE IF NOT EXISTS EMPLOYEES (
	empID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    empName VARCHAR(45) NOT NULL,
    empSurname VARCHAR(60) NOT NULL,
    position_id INTEGER NOT NULL, 
	FOREIGN KEY(position_id) REFERENCES POSITIONS(posID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    empSalary DOUBLE(4,2) NOT NULL,
    empAccountNo VARCHAR(30) NOT NULL,
    empStartDate date NOT NULL,
    empEndDate date,
    empPhoneNo VARCHAR(20),
    empAddress VARCHAR(60),
    empInsuranceNo VARCHAR(20)
);

DROP TABLE IF EXISTS BUSES;
CREATE TABLE IF NOT EXISTS BUSES (
	busID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
	driver_id INTEGER,
    FOREIGN KEY(driver_id) REFERENCES EMPLOYEES(empID)
    ON UPDATE CASCADE
	);
    
   
DROP TABLE IF EXISTS FLIGHTS;    
CREATE TABLE IF NOT EXISTS FLIGHTS (
	fliID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fliStartPoint INTEGER NOT NULL,
    fliEndPoint INTEGER NOT NULL,
    fliStartTime DATE NOT NULL,
    fliEndTime DATE NOT NULL,
    fliClass ENUM ('First', 'Business', 'Economy') NOT NULL,
    fliLayoverBool BOOL NOT NULL DEFAULT FALSE,
    fliLayoverNo TINYINT NOT NULL DEFAULT 0,
	fliLayoverPos TINYINT,
    fliLayoverLoc INTEGER,
    fliLayoverDuration DOUBLE(4,2),
    fliPrice DOUBLE(4,3),
    fliPriceCurrency VARCHAR(10),
    FOREIGN KEY (fliStartPoint) REFERENCES CITIES(citID)
    ON UPDATE CASCADE,
    FOREIGN KEY (fliEndPoint) REFERENCES CITIES(citID)
    ON UPDATE CASCADE,
    FOREIGN KEY (fliLayoverLoc) REFERENCES CITIES(citID)
	);

DROP TABLE IF EXISTS CUSTOMERS;
CREATE TABLE IF NOT EXISTS CUSTOMERS (
	custID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    custName VARCHAR(50) NOT NULL,
    custSurname VARCHAR(50) NOT NULL,
    custCardNo VARCHAR(20),
    custSocialSecurityNo VARCHAR(20),
	custAddress VARCHAR(100)
	);
    
DROP TABLE IF EXISTS HOTELS;    
CREATE TABLE IF NOT EXISTS HOTELS (
	hotID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
	hotLocID INTEGER NOT NULL,
    hotAddress VARCHAR(50),
    hotTelephoneNo VARCHAR(20),
    hotContactEmail VARCHAR(45),
    FOREIGN KEY (hotLocID) REFERENCES CITIES (citID)
    ON UPDATE CASCADE
	);
    
DROP TABLE IF EXISTS PACKAGES;    
CREATE TABLE IF NOT EXISTS PACKAGES (
	packID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    packTitle VARCHAR(30) NOT NULL,
	packDescription TEXT,
    packLocationID INTEGER NOT NULL,
    packHotelID INTEGER NOT NULL,
    packDuration TINYINT NOT NULL,
    packPrice DOUBLE (4,2),
    packPriceCurrency VARCHAR(3),
    packPplNo TINYINT NOT NULL DEFAULT 1,
    packStartDate DATE NOT NULL,
    packEndDate DATE NOT NULL,
    packDiscountAt TINYINT,
    packDiscountAmnt DOUBLE (4,2),
    packTransportIncluded BOOL DEFAULT false,
    packFlightNo INTEGER NULL,
    packBusNo INTEGER NULL,
    FOREIGN KEY (packLocationID) REFERENCES COUNTRIES (ctryID)
    ON UPDATE CASCADE,
    FOREIGN KEY (packFlightNo) REFERENCES FLIGHTS (fliID)
    ON UPDATE CASCADE, 
    FOREIGN KEY (packBusNo) REFERENCES BUSES (busID)
    ON UPDATE CASCADE, 
    FOREIGN KEY (packHotelID) REFERENCES HOTELS (hotID) 
    ON UPDATE CASCADE 
	);

DROP TABLE IF EXISTS BOOKINGS;
CREATE TABLE IF NOT EXISTS BOOKINGS (
	bookID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    bookCustomerID INTEGER NOT NULL,
    bookPackageID INTEGER NOT NULL,
    bookNoOfPackPurchased INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (bookCustomerID) REFERENCES CUSTOMERS(custID)
    ON UPDATE CASCADE,
    FOREIGN KEY (bookPackageID) REFERENCES PACKAGES(packID)
    ON UPDATE CASCADE
	);


/*
	Triggers
 */
DELIMITER $$
DROP TRIGGER IF EXISTS trgInsCountries; $$
CREATE TRIGGER trgInsCountries BEFORE INSERT ON COUNTRIES
FOR EACH ROW BEGIN 
	SET NEW.ctryName=trim(upper(NEW.ctryName));
END; 
$$

DROP TRIGGER IF EXISTS trgInsCities; $$
CREATE TRIGGER trgInsCities BEFORE INSERT ON CITIES
FOR EACH ROW BEGIN
	SET NEW.citName=trim(upper(NEW.citName));
END;
$$

DROP TRIGGER IF EXISTS trgInsContinents; $$
CREATE TRIGGER trgInsContinents BEFORE INSERT ON CONTINENTS
FOR EACH ROW BEGIN
	SET NEW.contName = trim(upper(NEW.contName));
END;
$$

DELIMITER ;


/* 
 *	FUNCTIONS
 */
 
DELIMITER $$
DROP FUNCTION IF EXISTS fInsCity; $$
CREATE FUNCTION fInsCity(cityName VARCHAR(45), countryName VARCHAR(45))
RETURNS CHAR
DETERMINISTIC
BEGIN
	DECLARE idCountry INT;
    SELECT ctryID INTO idCountry from COUNTRIES WHERE trim(upper(countryName))=ctryName;
    IF isnull(idCountry) then
		RETURN 'Country not found.';
    ELSE
		INSERT INTO CITIES(cName, id_country) VALUES (cityName, idCountry);
        RETURN 'Inserted.';
	END IF;
END $$

DELIMITER $$
DROP FUNCTION IF EXISTS fInsCountry; $$
CREATE FUNCTION fInsCountry(countryName VARCHAR(45), continentName VARCHAR(45))
RETURNS CHAR
DETERMINISTIC
BEGIN
	DECLARE continent_id INT;
    SELECT contID INTO continent_id from CONTINENTS WHERE contName=trim(upper(continentName));
	IF isnull(continent_id) THEN
		RETURN 'Invalid continent';
	ELSE
		INSERT INTO COUNTRIES(ctryName, id_cont) VALUES(countryName, continent_id);
        return 'Inserted.';
	END IF;
END $$

DELIMITER ;



/*
 *	INSERTS
 */
 INSERT INTO CONTINENTS (contName) VALUES 	('AFRICA'), 
											('EUROPE'), 
											('ASiIA'), 
											('SOUTH AMErICA'), 
											('NORTH AMERICA'), 
											('   AuSTRALIa'), 
											('ANTArctICA');
                                            
SELECT * FROM CONTINENTS ORDER BY contName ASC;
DELETE FROM CONTINENTS WHERE contName='ASIIA';
INSERT INTO CONTINENTS(contName) VALUES ('Asia ');
/* 
INSERT INTO COUNTRIES (name) VALUES 
	('Italy'),
    ('Greece'),
    ('SPAIN'),
    ('Portugal'),
    ('germany'),
    ('romania'),
    ('croatia'),
    ('the uk'),
    ('ireland'),
    ('turkey'),
    ('russia'),
    ('HOlland'),
    ('FranCe');
    


SELECT * from countries;




SELECT * from cities;




UPDATE COUNTRIES set name=upper(name) WHERE 1=1;	# Required disabling safe mode
SELECT * from COUNTRIES;
*/

/*

SELECT fInsCity('Marseille', 'France');


SELECT * FROM CITIES;
INSERT INTO CITIES (cName, id_country) VALUES ('Nice', 13);
SELECT * FROM COUNTRIES;
INSERT INTO COUNTRIES(name) VALUES (' Bulgaria  ');

*/