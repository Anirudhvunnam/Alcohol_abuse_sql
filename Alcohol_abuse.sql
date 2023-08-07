#check if there exists a a schema called Behavioral
DROP DATABASE Behavioral;

#Create new schema called Behavioral
CREATE SCHEMA Behavioral;
USE Behavioral;

#Create new table Heavydrinking
CREATE TABLE HeavyDrinking (
    ZipCode INT,
    Question VARCHAR(1000),
    Response VARCHAR(1000),
    BreakOut VARCHAR(1000),
    BreakOutCategory VARCHAR(255),
    SampleSize INT,
    DataValue INT
);
#Create new table Demographics
CREATE TABLE Demographics (
    ZipCode INT,
    City VARCHAR(255),
    County VARCHAR(255)
);
#Create new table Demographics_OK
CREATE TABLE Demographics_OK (
    ZipCode INT,
    City VARCHAR(255),
    County VARCHAR(255)
);

#-------Load Data from csv files into these tables -------#
# The files have to be converted into .csv files first from .xlsx format.
# Used MS excel to convert files from .xlsx to .csv
SELECT COUNT(*) FROM HeavyDrinking;
SELECT COUNT(*) FROM Demographics;
SELECT COUNT(*) FROM Demographics_OK;

-- Check for duplicate entries in HeavyDrinking table
SELECT ZipCode, COUNT(*) 
FROM HeavyDrinking
GROUP BY ZipCode
HAVING COUNT(*) > 1;

-- Check for duplicate entries in Demographics table
SELECT ZipCode, COUNT(*)
FROM Demographics
GROUP BY ZipCode
HAVING COUNT(*) > 0;

-- Check for duplicate entries in Demographics_OK table
SELECT ZipCode, COUNT(*)
FROM Demographics_OK
GROUP BY ZipCode
HAVING COUNT(*) > 0;

-- Add primary key to Demographics table
ALTER TABLE Demographics
ADD PRIMARY KEY (ZipCode);

-- Add primary key to Demographics_OK table
ALTER TABLE Demographics_OK
ADD PRIMARY KEY (ZipCode);

-- Add primary key and foreign key to HeavyDrinking table
ALTER TABLE Behavioral.HeavyDrinking
ADD HeavyDrinkingID INT AUTO_INCREMENT PRIMARY KEY,
ADD FOREIGN KEY (ZipCode) REFERENCES Behavioral.Demographics_OK(ZipCode);

#Check if a table ratioTbale exist 
DROP Table RatioTable;
#Create new table as ratio table that would store the ratios of sample vs data
CREATE TABLE Behavioral.RatioTable (
    HeavyDrinkingID INT AUTO_INCREMENT PRIMARY KEY,
    ZipCode INT,
    Ratio DECIMAL(12,4)
);

#Insert data into the table 
INSERT INTO Behavioral.RatioTable (ZipCode, Ratio)
SELECT ZipCode, DataValue / SampleSize AS Ratio
FROM Behavioral.HeavyDrinking;

#-- Add primary key and foreign key to RatioTable table
ALTER TABLE Behavioral.RatioTable
ADD FOREIGN KEY (HeavyDrinkingID) REFERENCES Behavioral.HeavyDrinking(HeavyDrinkingID);

select * from RatioTable;

# -- Average data value for each zipcode in HeavyDrinking
SELECT hd.ZipCode, AVG(hd.DataValue) AS AvgDataValue
FROM Behavioral.HeavyDrinking hd
WHERE hd.BreakOut IN ('18-24', 'College graduate', 'H.S. or G.E.D.','Some post-H.S.',
'Female','Less than $15,000','Male','Overall')
GROUP BY hd.ZipCode;

## -- Find the zip codes with the highest ratios of heavy drinkers:
SELECT r.ZipCode, d.City, d.County, r.Ratio
FROM Behavioral.RatioTable r
JOIN Behavioral.Demographics_OK d ON r.ZipCode = d.ZipCode
ORDER BY r.Ratio DESC
LIMIT 10;

-- Calculate the average ratio of heavy drinkers by county:
SELECT d.County, AVG(r.Ratio) as AvgRatio
FROM Behavioral.RatioTable r
JOIN Behavioral.Demographics_OK d ON r.ZipCode = d.ZipCode
GROUP BY d.County;

## -- find the areas with the highest and lowest percentage of respondents for adolescent alcohol abuse by city:
SELECT d.City, AVG(rt.Ratio)*100 AS AvgPercent
FROM Behavioral.HeavyDrinking hd
JOIN Behavioral.Demographics_OK d ON hd.ZipCode = d.ZipCode
JOIN Behavioral.RatioTable rt ON hd.HeavyDrinkingID = rt.HeavyDrinkingID
WHERE hd.BreakOut IN ('18-24', 'College graduate', 'H.S. or G.E.D.',
'Some post-H.S.','Female','Less than $15,000','Male','Overall')
    AND hd.BreakOutCategory IN ('Age Group', 'Education Attained', 
    'Overall', 'Gender','Household Income')
GROUP BY d.City
ORDER BY AvgPercent DESC
LIMIT 10;

## -- find the areas with the highest and lowest percentage of respondents for adolescent alcohol abuse by county:
SELECT d.County, AVG(rt.Ratio)*100 AS AvgPercent
FROM Behavioral.HeavyDrinking hd
JOIN Behavioral.Demographics_OK d ON hd.ZipCode = d.ZipCode
JOIN Behavioral.RatioTable rt ON hd.HeavyDrinkingID = rt.HeavyDrinkingID
WHERE hd.BreakOut IN ('18-24', 'College graduate', 'H.S. or G.E.D.',
'Some post-H.S.','Female','Less than $15,000','Male','Overall')
    AND hd.BreakOutCategory IN ('Age Group', 'Education Attained', 
    'Overall', 'Gender','Household Income')
GROUP BY d.County
ORDER BY AvgPercent DESC
LIMIT 10;



