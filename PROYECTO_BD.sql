CREATE DATABASE [HIDDENLEAFVILLAGE]
GO
USE [HIDDENLEAFVILLAGE]
GO
CREATE TABLE [dbo].[Patient]
(
    PatientID int NOT NULL PRIMARY KEY,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,
    Address TEXT NOT NULL,
    Telephone varchar(50) NOT NULL,
    DateOfBirth datetime NOT NULL,
    EPS varchar(50) NOT NULL,
    ContactTelephone varchar(50) NOT NULL,
    Email varchar(50) NOT NULL UNIQUE,
    ContactName varchar(50) NOT NULL,
    ContactTelephone2 varchar(50) DEFAULT '',
    CHECK (DateOfBirth <= GETDATE())
)
GO

INSERT INTO [dbo].[Patient]
VALUES
(1,'John', 'Smith', '1001 N Pleasant St #24BAmherst, Massachusetts(MA), 01002', '923401789', '01/01/1987', 'N/A', '1232156789', 'johnSmith@email.com', 'N/A', '52223456789'),
(2,'Jane', 'Smith', '261 Mensh Ave Sebastian, Florida(FL), 32958', '0129922789', '01/09/1990', 'N/A', '2124233289', 'janeSmith@email.com', 'N/A', '9823456789'),
(3,'Jacob', 'Andrew', '4177 Nc 43 Hwy Hollister, North Carolina(NC), 27844', '120456700', '05/01/1997', 'N/A', '112342389', 'jacobAndrew@email.com', 'N/A', '1123456789'),
(4,'Jingle', 'Smith', '200 S Taft Ave Mason City, Iowa(IA), 50401', '012345000', '01/08/1999', 'N/A', '112342789', 'jsm@email.com', 'N/A', '443456789');
GO

CREATE TABLE [dbo].[Physician]
(
    PhysicianID int NOT NULL PRIMARY KEY,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,
    Address varchar(50) NOT NULL DEFAULT '',
    Telephone varchar(50) NOT NULL UNIQUE,
    Specialty varchar(50) NOT NULL,
    CHECK (Telephone <= '999999999999')
)
GO

INSERT INTO [dbo].[Physician]
VALUES
(1,'John', 'Smith', '13600 Commerce Blvd Rogers, Minnesota(MN), 55374', '419-574-0348', 'N/A'),
(2,'Jane', 'Smith', '555 Caspian Dr Grasonville, Maryland(MD), 21638', '314-534-3532', 'N/A'),
(3,'Jacob', 'Andrew', '132 Fay St Jeffersonville, Kentucky(KY), 40337', '478-636-5520', 'N/A'),
(4,'Jingle', 'Smith', '4504 Dover Castle Dr Decatur, Georgia(GA), 30035', '917-433-5813', 'N/A');
GO

CREATE TABLE [dbo].[Order]
(
    OrderID int NOT NULL PRIMARY KEY,
    OrderNumber int NOT NULL ,
    DateOfRequest datetime NOT NULL,
    DateOfEntry datetime NOT NULL DEFAULT GETDATE(),
    TreatingPhysician int NOT NULL,
    PatientID int NOT NULL,
    EPS int NOT NULL,
    CHECK (DateOfRequest <= GETDATE())
)
GO

INSERT INTO [dbo].[Order]
VALUES
(1,1,'2017-01-01','2017-01-01',1,1,1),
(2,2,'2018-01-09','2018-01-09',2,1,1),
(3,3,'2017-06-19','2017-06-19',3,1,3),
(4,4,'2017-07-18','2017-07-18',4,1,4);
GO

CREATE TABLE [dbo].[Examination]
(
    ExaminationID int NOT NULL PRIMARY KEY,
    Type varchar(50) NOT NULL DEFAULT '',
    DateOfAppointment datetime NOT NULL,
    DateOfPerformance datetime NOT NULL,
    Observations varchar(50) NOT NULL,
    OrderID int NOT NULL,
    CHECK (DateOfAppointment <= GETDATE())
)
GO

INSERT INTO [dbo].[Examination]
VALUES
(1,'N/A','2017-01-01','2017-01-01','N/A',1),
(2,'N/A','2018-01-09','2018-01-09','N/A',2),
(3,'N/A','2017-06-19','2017-06-19','N/A',3),
(4,'N/A','2017-07-18','2017-07-18','N/A',4);
GO

CREATE TABLE [dbo].[Invoice]
(
    InvoiceID int NOT NULL PRIMARY KEY,
    InvoiceNumber int NOT NULL,
    ValueToPay int NOT NULL DEFAULT 0,
    PatientID int NOT NULL,
    DateOfPerformance datetime NOT NULL,
    CHECK (DateOfPerformance <= GETDATE())
)
GO

INSERT INTO [dbo].[Invoice]
VALUES
(1,1,100,1,'2017-01-01'),
(2,2,200,2,'2018-01-09'),
(3,3,300,3,'2017-06-19'),
(4,4,400,4,'2017-07-18');
GO

CREATE TABLE [dbo].[Revenue]
(
    RevenueID int NOT NULL PRIMARY KEY,
    Type varchar(50) NOT NULL,
    Revenue int NOT NULL DEFAULT 0,
    CHECK (Revenue >= 0)
)
GO

INSERT INTO [dbo].[Revenue]
VALUES
(1,'N/A',100),
(2,'N/A',200),
(3,'N/A',300),
(4,'N/A',400);
GO

ALTER TABLE [dbo].[Invoice]
ADD CONSTRAINT [FK_Invoice_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
GO
ALTER TABLE [dbo].[Order]
ADD CONSTRAINT [FK_Order_Physician] FOREIGN KEY ([TreatingPhysician]) REFERENCES [dbo].[Physician] ([PhysicianID])
GO
ALTER TABLE [dbo].[Order]
ADD CONSTRAINT [FK_Order_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
GO
ALTER TABLE [dbo].[Order]
ADD CONSTRAINT [FK_Order_EPS] FOREIGN KEY ([EPS]) REFERENCES [dbo].[Physician] ([PhysicianID])
GO
ALTER TABLE [dbo].[Examination]
ADD CONSTRAINT [FK_Examination_Order] FOREIGN KEY ([OrderID]) REFERENCES [dbo].[Order] ([OrderID])
GO

CREATE PROCEDURE [dbo].[InsertPatient]
@PatientID int,
@FirstName varchar(50),
@LastName varchar(50),
@Address varchar(50),
@Telephone varchar(50),
@DateOfBirth datetime,
@eps VARCHAR(50),
@CONTACTtelephone varchar(50),
@email varchar(50),
@contactname varchar(50),
@contacttelephone2 varchar(50)
AS
BEGIN
    INSERT INTO [dbo].[Patient]
    VALUES
    (   @PatientID,@FirstName,@LastName,@Address,@Telephone,@DateOfBirth,@eps,@CONTACTtelephone,@email,@contactname,@contacttelephone2);
    PRINT 'Patient inserted successfully';
END;
GO

CREATE OR ALTER TRIGGER [dbo].[Patient_Trigger]
ON [dbo].[Patient]
AFTER INSERT
AS
IF	(SELECT COUNT (*) FROM inserted, [dbo].[Patient] WHERE inserted.[PatientID] = [dbo].[Patient].[PatientID] ) > 1

BEGIN
ROLLBACK TRANSACTION RAISERROR ('Patient already exists', 
								16, 
								1);
END
ELSE
PRINT 'Patient inserted successfully';

GO

CREATE PROCEDURE [dbo].[Report_1]
@PatientID int
AS
BEGIN
    DECLARE cursor1 CURSOR FOR SELECT TOP 5 * FROM [dbo].[Patient] ORDER BY [PatientID] DESC;
    OPEN cursor1;
    FETCH FIRST FROM cursor1;
    CLOSE cursor1;
    DEALLOCATE cursor1;
END;





USE HIDDENLEAFVILLAGE;

CREATE LOGIN [User1] WITH PASSWORD = '123456';
GO
-- a. A user who only has permissions to insert, update, delete or query records.
USE HIDDENLEAFVILLAGE;
GRANT SELECT,INSERT, UPDATE ON [dbo].[Patient] TO [User1];
GO
USE HIDDENLEAFVILLAGE;
CREATE LOGIN [User2] WITH PASSWORD = '123456';
GO
-- b. A user that only has access to query the records in the database.
USE HIDDENLEAFVILLAGE;
GRANT SELECT ON [dbo].[Patient] TO [User2];




EXECUTE [dbo].[InsertPatient]
@PatientID = '1',
@FirstName = 'Juan',
@LastName = 'Perez',
@Address = 'Calle falsa 123',
@Telephone = '123456789',
@DateOfBirth = '2017-01-01',
@EPS = '1',
@ContactTelephone = '123456999',
@Email = 'test@email.com',
@ContactName = 'Juan',
@ContactTelephone2 = '122056909';

EXECUTE [dbo].[Report_1];
