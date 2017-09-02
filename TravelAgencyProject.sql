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
    posBaseSalary DOUBLE(10,2) NOT NULL
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
    fliStartTime DATETIME NOT NULL,
    fliEndTime DATETIME NOT NULL,
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
    hotPricePerNight DOUBLE (10,2),
    hotPriceCurrency VARCHAR(6),
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
    packHotelID INTEGER NULL,
    packDuration TINYINT NOT NULL,
    packPrice DOUBLE (10,2) NULL,
    packPriceCurrency VARCHAR(3),
    packPplNo TINYINT NOT NULL DEFAULT 1,
    packStartDate DATE NOT NULL,
    packEndDate DATE NOT NULL,
    packDiscountAt TINYINT,
    packDiscountAmnt DOUBLE (4,2),
    packTransportIncluded BOOL DEFAULT false,
    packFlightNo VARCHAR(30) NULL,
    packBusNo INTEGER NULL,
    FOREIGN KEY (packLocationID) REFERENCES CITIES (citID)
    ON UPDATE CASCADE,
    #FOREIGN KEY (packFlightNo) REFERENCES FLIGHTS (fliID)
    #ON UPDATE CASCADE, 
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
 *	VIEW which calculate the flight prices in case of return or one-way tickets
 */
#to, from, date_start, date_end, price
DROP view if exists flight_price_list;
CREATE VIEW flight_price_list AS
SELECT  a.fliStartPoint as 'From', a.fliEndPoint as 'To', true as 'Return', date(a.fliStartTime) as 'Date start', date(b.fliStartTime) as 'Date Return', a.fliPrice+b.fliPrice as 'Price', 'EUR' as 'Currency'
FROM flights a, flights b
WHERE (a.fliStartPoint=b.fliEndPoint) and (a.fliEndPoint=b.fliStartPoint)
and (a.fliStartTime < b.fliStartTime)
UNION
SELECT fliStartPoint as 'From', fliEndPoint as 'To', false as 'Return', date(fliStartTime) as 'Date start', NULL as 'Date Return', fliPrice as 'Price', 'EUR' as 'Currency'
FROM flights;


/*
	Triggers
 */
 
 /*
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
*/

/* 
 *	FUNCTIONS
 */
 
 /*
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

*/

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
  
  
 /*
  *	INDEX
  */
  
CREATE INDEX ord_Cont on CONTINENTS (contName);               

DELETE FROM CONTINENTS WHERE contName='ASIIA';
INSERT INTO CONTINENTS(contName) VALUES ('Asia ');

INSERT INTO positions(posName, posBaseSalary) VALUES 	('Driver', 700),
														('Intern', 300),
                                                        ('CEO', 5000),
                                                        ('CFO', 5000),
                                                        ('Travel Consultant', 1500),
                                                        ('Sales Assistant', 1300),
                                                        ('Customer Service Representative', 1000),
                                                        ('Business Travel Consultant', 1700),
                                                        ('Travel Advisor', 1200),
                                                        ('Cabin Crew', 2000),
                                                        ('Account Manager', 1500);
        

INSERT INTO COUNTRIES (ctryName, id_cont) VALUES 
	('Italy', 2),
    ('Greece', 2),
    ('SPAIN', 2),
    ('Portugal', 2),
    ('germany', 2),
    ('romania', 2),
    ('croatia', 2),
    ('the uk', 2),
    ('ireland', 2),
    ('turkey', 8),
    ('russia', 8),
    ('HOlland', 2),
    ('FranCe', 2),
    ('Australia', 6);
CREATE INDEX ctry_Ind on COUNTRIES (ctryName);


INSERT INTO CITIES (citName, id_country) values
	('Rome', 1),
    ('Venice', 1),
    ('Milano', 1),
    ('Athens', 2),
    ('Barcelona', 3),
    ('Porto', 4),
    ('Berlin', 5),
    ('Antalya', 10),
    ('Istanbul', 10),
    ('Moscow', 11),
    ('Sankt Petersburg', 11),
    ('Amsterdam', 12),
    ('Paris', 13),
    ('Nisa', 13),
    ('Sydney', 14);


UPDATE COUNTRIES set ctryName=upper(ctryName) WHERE 1=1;	# Required disabling safe mode

INSERT INTO CUSTOMERS	(custName, custSurname, custCardNo, custSocialSecurityNo, custAddress) VALUES
						# Used http://www.theonegenerator.com/s to generate some of the values
                        # Used https://www.doogal.co.uk/RandomAddresses.php to generate addresses (all UK though)
						('Emilia', 'Clarke', '4716785105999216', '044-20-3064', '15 New Sandridge, Newbiggin-by-the-Sea NE64 6DX, UK'),
                        ('Sherlock', 'Holmes', '5237000519035418', '222-20-0107', '221B Baker Street'),
                        ('Matt', 'Murdock', '378449500019826', '654-03-7276', '22 Bergholt Ave, Ilford IG4 5NE, UK'),
                        ('Jessica', 'Jones', '374737367310237', '416-24-0430', '29 Withy Mead, London E4 6JY, UK'),
                        ('Oliver', 'Queen', '377467177618507', '001-70-8727', '15C Conewood St, London N5 1BZ, UK'),
                        ('Amelia', 'Earhart', '370476885874911', '003-18-9982', '9 Wearfield, Sunderland SR5 2TG, UK'), 
                        ('Elektra', 'Natchios', '347184958274940', '529-98-7900', '10 Gale Cl, Hales, Norwich NR14 6SN, UK'),
						('Amberle', 'Elessedil', '4514029875991689', '215-82-0623', '38 Anderson St, Inverness IV3 8DF, UK'),
                        ('Emma', 'Swan', '5206278971927036', '576-44-5409', 'Longwood Ln, United Kingdom'),
                        ('Harry', 'Potter', '5304721916534756', '221-78-6228', '21 Privet Drive, Little Winging, Surrey'),
                        ('Luke', 'Cage', '371380687639226', '135-22-9947', 'Merry Ln, Highbridge TA9 3PS, UK');

ALTER table hotels ADD hotName VARCHAR(30);

INSERT INTO hotels (hotLocID, hotName, hotAddress , hotContactEmail, hotPricePErNight) VALUES
(12, 'Triple Fjord Hotel', 'Amsterdam 1', 'contact@fjordhotel.com', 50),
(8, 'Suleyiman Saray', 'Antalya 1', 'contact@ssaray.com', 30),
(4, 'Troya Hotel', 'Athens 1', 'contact@troyahotels.com', 30),
(5, 'Hotel Barca', 'Barca 1', 'contact@barcahotel.com', 55),
(7, 'Berliner Hotels', 'Berlin Alexanderplatz 1', 'contact@berlineralexhotel.com', 40),
(9, 'Hotel Galata', 'Istanbul Galata Bridge 1', 'contact@galatahotel.com', 35),
(3, 'Hotel Dom Milano', 'Milano Dom 1', 'contact@dommilano.com', 50),
(13, 'Eiffel Hotel Paris', 'Paris Louvre 1', 'contact@eiffelhotels.com', 90),
(6, 'Porto Wino Hostel', 'Porto 1', 'contact@portohostel.com', 70),
(1, 'Colosseum Hotel', 'Rome Colosseum 1', 'contact@colloseumhotels.it', 45),
(2, 'Hotel Grand Canale', 'Venice Grand Canal 1', 'contact@grandcanelehotels.com', 55),
(15, 'Sydney Opera Hotel', 'Sydney Opera 1', 'contact@syoperahotel.com', 60);

UPDATE hotels SET hotTelephoneNo='+61 491 570 156' where hotLocId=15;
UPDATE hotels set hotTelephoneNo='+39 065555555' where hotLocID=3;
UPDATE hotels set hotTelephoneNo='+30 1 1234567' where hotLocID=4;
UPDATE hotels set hotPriceCurrency='EUR';


DELETE from employees where 1=1;
INSERT INTO employees (empName, empSurname, position_id, empSalary, empAccountNo, empStartDate) VALUES
('James', 'Howlett', 7, 100, '4556315376438273', '2015-12-11'),
('Sara', 'Lance', 8, 100, '342875545339832', '2014-07-01'),
('Felicity', 'Smoak', 3, 100, '378951202793145', '2017-05-03'),
('James', 'Rhodes', 1, 100, '5278461483279004', '2011-07-06'),
('Vegeta', 'Prince', 1, 100, '4929325031020937', '2017-02-09'),
('Clark', 'Kent', 6, 100, '5269768863327877', '2015-03-10'),
('Bruce', 'Wayne', 4, 100, '378747694766783', '2016-03-02'),
('Iam', 'Groot', 2, 100, '6011107596622883', '2017-06-13'),
('Wilson', 'Fisk', 11, 100, '340233352451740', '2015-10-10'),
('Diana', 'Prince', 5, 100, '4556400401622875', '2017-04-09')
;


# Setting up salary as minimum salary for their function
ALTER TABLE employees CHANGE empSalary empSalary DOUBLE(10,2) NOT NULL;
UPDATE employees SET empSalary = (select posBaseSalary from positions where position_id=posID);


INSERT INTO CITIES (citName, id_country) VALUES ('Bucharest', 6);
DELETE FROM flights where 1=1;
ALTER TABLE flights CHANGE fliPrice fliPrice DOUBLE(8,2);
INSERT INTO flights	(fliStartPoint, fliEndPoint, fliStartTime, fliEndTime, fliClass, fliLayoverBool, fliPrice, fliPriceCurrency) values
					(16, 3, '2017-09-21 08:50', '2017-09-21 10:30', 'Economy', false, 130, 'EUR'),
                    (3, 16, '2017-09-27 11:00', '2017-09-27 12:30', 'Economy', false, 120, 'EUR'),
					(16, 12, '2017-09-25 11:30', '2017-09-25 14:00', 'Economy', false, 200, 'EUR'),
                    (12, 16, '2017-10-03 14:00', '2017-09-25 16:00', 'Economy', false, 210, 'EUR'),
                    (16, 7, '2017-12-29 06:15', '2017-12-29 09:05', 'Economy', false, 110, 'EUR'),
                    (7, 16, '2018-01-03 10:00', '2017-01-03 11:30', 'Economy', false, 100, 'EUR'),
                    (16, 13, '2017-12-20 07:20', '2017-12-20 10:30', 'Business', false, 320, 'EUR'),
                    (13, 16, '2017-12-27 11:00', '2017-12-27 13:00', 'Business', false, 300, 'EUR'),
                    (16, 6, '2017-08-25 13:20', '2017-08-25 16:30', 'Economy', false, 210, 'EUR'),
                    (6, 16, '2017-08-30 17:00', '2017-08-30 19:30', 'Economy', false, 190, 'EUR'),
                    (16, 14, '2017-09-13 08:10', '2017-09-13 10:25', 'First', false, 340, 'EUR'),
                    (14, 16, '2017-09-18 11:10', '2017-09-18 13:25', 'First', false, 350, 'EUR'),
                    (16, 5, '2017-10-11 08:50', '2017-10-11 10:30', 'Economy', false, 130, 'EUR'),
                    (5, 16, '2017-10-15 11:00', '2017-10-15 13:30', 'Economy', false, 120, 'EUR');

INSERT INTO buses(driver_id) values (4), (6);


DELETE from packages where 1=1;
INSERT INTO PACKAGES (packTitle, packLocationID, packHotelID, packPplNo, packStartDate, packEndDate, packBusNo, packTransportIncluded) VALUES
					('Visit Istanbul', 9, 6, 2, '2017-09-20', '2017-09-27', 1, true),
                    ('Antalya Holiday', 8, 2, 2, '2017-09-03', '2017-09-10', 2, true),
                    ('Athens City Break', 4, 3, 2, '2017-10-13', '2017-10-16', 1, true)
;



INSERT INTO PACKAGES (packTitle, packLocationID, packHotelID, packPplNo, packStartDate, packEndDate, packFlightNo, packTransportIncluded) VALUES
					('Visit Milano', 3, 7, 2, '2017-09-21', '2017-09-27', '1;2', true),
					('Visit Amsterdam', 12, 1, 2, '2017-09-25', '2017-10-03', '3;4', true),
                    ('Berlin New Year\'s', 7, 5, 2, '2017-12-29', '2018-01-03', '5;6', true ),
                    ('Paris in Love', 13, 8, 2, '2017-12-20', '2017-12-27', '7;8', true),
                    ('Taste Porto Wine', 6, 9, 2, '2017-08-25', '2017-08-30', '9;10', true),
                    ('Nisa Pink Beach',14, NULL, 2, '2017-09-13', '2017-09-18', '11;12', true),
                    ('Have a walk on the Rambla', 5, 4, 2, '2017-10-11', '2017-10-15', '13;14', true),
                    ('Gondola on the canal', 2, 11, 2, '2017-11-16', '2017-11-22', NULL, false),
                    ('Sydney in love', 15, 12, 2, '2018-03-12', '2018-03-27', NULL, false);

INSERT INTO bookings (bookCustomerID, bookPackageID) VALUES
	(1, 7),
    (2, 1),
    (3, 5),
    (1, 9),
    (5, 11), 
    (6, 11),
    (4, 3),
    (7, 6),
    (8, 11),
    (9, 11),
    (9, 7),
    (10, 2),
    (11, 8),
    (7, 4), 
    (6 ,4),
    (10, 10);
    

# Select all packages with the number of customers who selected it
	select a.packTitle as 'Title', citName as 'City Name', count(a.bookCustomerID) as 'Number of Reservations'
	from (	select packTitle, packLocationID, bookCustomerID from packages left join bookings
			on bookPackageID=packID) as a 
    inner join cities on
	a.packLocationID=citID
	group by (a.packLocationID)
	;
    
UPDATE packages set packPriceCurrency='EUR';

#Calculate package price
#Step 1 update for the ones with flights included
UPDATE packages set packPrice= (	
									SELECT d.price + (hotPricePErNight * datediff(packEndDate, packStartDate))  from
												(	SELECT f.price, packLocationID as 'location' from flight_price_list f
													join packages  on f.to=packLocationID
													where f.return=1 
												) d, hotels
									WHERE d.location=packLocationID and hotLocID=d.location
                                    
                                ) 
where packTransportIncluded=true and packFlightNo is not null;
#Step 2 update for the ones with bus included
UPDATE packages set packPrice= (	
									SELECT (hotPricePErNight * datediff(packEndDate, packStartDate)) + 100  from
											hotels
									WHERE hotLocID=packLocationID
                                ) 
where packTransportIncluded=true and packBusNo is not null;
#Step 3 update for the ones with no transport included
UPDATE packages set packPrice= (	
									SELECT (hotPricePErNight * datediff(packEndDate, packStartDate)) + 50  from
											hotels
									WHERE hotLocID=packLocationID
                                ) 
where packTransportIncluded=false;
#Step 4 update for the ones with no hotel
UPDATE packages set packPrice= (	
									SELECT d.price  from
												(	SELECT f.price, packLocationID as 'location' from flight_price_list f
													join packages  on f.to=packLocationID
													where f.return=1 
												) d
									WHERE d.location=packLocationID 
                                    
                                ) 
where packTransportIncluded=true and packFlightNo is not null and packBusNo is null and (select hotLocID from hotels where hotLocId=packLocationID ) is null;

									
select * from continents;
select * from countries;
select * from cities;
select * from hotels;
select * from flights;
select * from buses;
select * from positions;
select * from customers;
select * from employees;
select * from packages;
select * from bookings;
select * from flight_price_list;								

# See for each customer money spent so far
SELECT concat(custName, ' ', custSurname) as 'Name', count(bookCustomerID) as 'Number of bookings', sum(packPrice) as 'Total Spent (EUR)'
from customers 
join bookings on bookCustomerID=custID 
join packages on bookPackageID=packID
group by bookCustomerID;



/*

SELECT fInsCity('Marseille', 'France');


SELECT * FROM CITIES;
INSERT INTO CITIES (cName, id_country) VALUES ('Nice', 13);
SELECT * FROM COUNTRIES;
INSERT INTO COUNTRIES(name) VALUES (' Bulgaria  ');

*/