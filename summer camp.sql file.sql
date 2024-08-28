
-- Task 1: Create Database Model

-- Table 1: Campers (General Information)
CREATE TABLE Campers (
    CamperID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    MiddleName VARCHAR(50),
    DateOfBirth DATE,
    Gender VARCHAR(10),
    Email VARCHAR(100),
    PersonalPhone VARCHAR(15)
);

-- Table 2: Camps (Camp Information)
CREATE TABLE Camps (
    CampID INT PRIMARY KEY IDENTITY(1,1),
    CampTitle VARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    Price DECIMAL(10, 2),
    Capacity INT
);

-- Table 3: Camper Visits (Tracking Visits)
CREATE TABLE CamperVisits (
    VisitID INT PRIMARY KEY IDENTITY(1,1),
    CamperID INT,
    CampID INT,
    VisitDate DATE,
    FOREIGN KEY (CamperID) REFERENCES Campers(CamperID),
    FOREIGN KEY (CampID) REFERENCES Camps(CampID)
);

-- Task 2: Populate Table with 5000 Campers
DECLARE @GenderDistribution TABLE (
    Gender VARCHAR(10),
    Percentage INT
);

-- Insert Gender Distribution (65% Female, 35% Male)
INSERT INTO @GenderDistribution (Gender, Percentage)
VALUES ('Female', 65),
       ('Male', 35);

-- Insert Age Distribution (18% 7-12, 27% 13-14, 20% 15-17, remaining up to 19)
DECLARE @AgeDistribution TABLE (
    MinAge INT,
    MaxAge INT,
    Percentage INT
);

INSERT INTO @AgeDistribution (MinAge, MaxAge, Percentage)
VALUES (7, 12, 18),
       (13, 14, 27),
       (15, 17, 20),
       (18, 19, 35);

-- Generate 5000 random Campers with the specified gender and age distribution
INSERT INTO Campers (FirstName, LastName, MiddleName, DateOfBirth, Gender, Email, PersonalPhone)
SELECT TOP 5000
    CONCAT('FirstName', ROW_NUMBER() OVER (ORDER BY NEWID())) AS FirstName,
    CONCAT('LastName', ROW_NUMBER() OVER (ORDER BY NEWID())) AS LastName,
    CONCAT('M', ROW_NUMBER() OVER (ORDER BY NEWID())) AS MiddleName,
    DATEADD(YEAR, -ABS(CHECKSUM(NEWID()) % (1 + MaxAge - MinAge)) - MinAge, GETDATE()) AS DateOfBirth,
    g.Gender,
    CONCAT(LOWER(CONCAT('camper', ROW_NUMBER() OVER (ORDER BY NEWID()))), '@example.com') AS Email,
    CONCAT('555-', FORMAT(ROW_NUMBER() OVER (ORDER BY NEWID()), '0000')) AS PersonalPhone
FROM @GenderDistribution g
JOIN @AgeDistribution a
    ON g.Percentage > (ABS(CHECKSUM(NEWID())) % 100)
    AND a.Percentage > (ABS(CHECKSUM(NEWID())) % 100);

-- Task 3: Query for Gender and Generation Data
SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 7 AND 12 THEN 'Gen Alpha'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 13 AND 17 THEN 'Gen Z'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 18 AND 34 THEN 'Millennials'
        ELSE 'Gen X'
    END AS Generation,
    Gender,
    COUNT(*) AS Count
FROM Campers
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 7 AND 12 THEN 'Gen Alpha'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 13 AND 17 THEN 'Gen Z'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 18 AND 34 THEN 'Millennials'
        ELSE 'Gen X'
    END,
    Gender
ORDER BY Generation, Gender;
