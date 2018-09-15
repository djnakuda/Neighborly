DROP DATABASE IF EXISTS Neighborly; /*THIS IS THE MOST DANGEROUS LINE OF SQL CODE */

CREATE DATABASE Neighborly; 
USE Neighborly;

CREATE TABLE Users (
	userID INT(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL,
    imageURL VARCHAR(300) default "",
    borrow BOOL NOT NULL
);

CREATE TABLE Items (	
	itemID INT(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
    itemName VARCHAR(30) NOT NULL,
    ownerID INT(11) NOT NULL,-- foreign key from user table
    borrowerID INT(11) DEFAULT -1 , -- foreign key from user table, if its null, means that it is available
    imageURL VARCHAR(300),
    itemDescription VARCHAR(500),
	latitude DOUBLE(20,16) NOT NULL,
    longitude DOUBLE(20,16) NOT NULL,
    available INT(1) NOT NULL,
    request INT(1) NOT NULL,
    requestorID INT(11) DEFAULT -1,
    returnRequest INT(1) NOT NULL,
    FOREIGN KEY fk1(ownerID) REFERENCES Users(userID)
);

INSERT INTO Users (email, name, password, borrow)
VALUES("guest", "Guest", "guest", false);