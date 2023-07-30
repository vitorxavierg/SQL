--(1) - Exploring the Dataset

-- Checking the dataset
SELECT *
FROM [Portfolio Project].dbo.HousingProject;
----------------------------------------------------------------------------\\-----------------------
--(2) - Standardizing Date Format

-- Using CONVERT to get just the date from SaleDate column
SELECT SaleDate,
       CONVERT(Date,SaleDate) AS New_SaleDate
FROM [Portfolio Project].dbo.HousingProject;


-- Creating a new column called 'New_SaleDate' with Date datetype
ALTER TABLE [Portfolio Project].dbo.HousingProject ADD New_SaleDate Date;


-- Updating the created 'New_SaleDate' column using CONVERT
UPDATE [Portfolio Project].dbo.HousingProject
SET New_SaleDate = CONVERT(Date,SaleDate);
----------------------------------------------------------------------------\\-----------------------
--(3) - Removing Missing Data:

-- Checking records with null values
SELECT PropertyAddress
FROM [Portfolio Project].dbo.HousingProject
WHERE PropertyAddress IS NULL;


-- Checking patterns on registers with the same 'ParcelID'
SELECT *
FROM [Portfolio Project].dbo.HousingProject
ORDER BY ParcelID;


/* Checking registers that have null 'PropertyAddress' but the same ParceLID and different 'UniqueID'.
   The goal here is to use PropertyAddress values from the same ParcelID to fill the null ones. */
SELECT x.ParcelID,
       x.PropertyAddress,
       y.ParcelID,
       y.PropertyAddress
FROM [Portfolio Project].dbo.HousingProject x
INNER JOIN [Portfolio Project].dbo.HousingProject y ON x.ParcelID = y.ParcelID
AND x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress IS NULL;


-- Updating PropertyAddress column to fill null PropertyAddress values, using filled PropertyAddress columns, with the same ParcelID. 
UPDATE x
SET PropertyAddress = ISNULL(x.PropertyAddress, y.PropertyAddress)
FROM [Portfolio Project].dbo.HousingProject x
INNER JOIN [Portfolio Project].dbo.HousingProject y ON x.ParcelID = y.ParcelID
AND x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress IS NULL
----------------------------------------------------------------------------\\-----------------------
--(4) - Breaking out column’s content into distinct columns

-- Checking OwnerAddres column an ordering DESC
SELECT OwnerAddress
FROM [Portfolio Project].dbo.HousingProject
ORDER BY 1 DESC;


/* Parsing OwnerAddress column using PARSENAME.
   The REPLACE is used because the default delimiter for PARSENAME is '.' */
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS SplittedOwnerAddress,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS SplittedOwnerCity,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS SplittedOwnerState
FROM [Portfolio Project].dbo.HousingProject
ORDER BY 1 DESC;


-- Creating SplittedOwnerAddress column
ALTER TABLE [Portfolio Project].dbo.HousingProject ADD SplittedOwnerAddress NVARCHAR(255);


-- Creating SplittedOwnerCity column
ALTER TABLE [Portfolio Project].dbo.HousingProject ADD SplittedOwnerCity NVARCHAR(255);


-- Creating SplittedOwnerState column
ALTER TABLE [Portfolio Project].dbo.HousingProject ADD SplittedOwnerState NVARCHAR(255);


-- Updating the SplittedOwnerAddress with the split 
UPDATE [Portfolio Project].dbo.HousingProject
SET SplittedOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


-- Updating the SplittedOwnerAddress with the split
UPDATE [Portfolio Project].dbo.HousingProject
SET SplittedOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


-- Updating the SplittedOwnerAddress with the split
UPDATE [Portfolio Project].dbo.HousingProject
SET SplittedOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


-- Checking the created splitted columns
SELECT *
FROM [Portfolio Project].dbo.HousingProject;
----------------------------------------------------------------------------\\-----------------------
--(5) - Fixing String Typos

-- Checking the existance of the same register with typos
SELECT SoldAsVacant, COUNT(SoldAsVacant) as Number_of_Registers
FROM [Portfolio Project].DBO.HousingProject
GROUP BY SoldAsVacant;


-- Applying case when to transform all registers of SoldAsVacant into 'Yes' or 'No'
SELECT SoldAsVacant,
       CASE
           WHEN SoldAsVacant = 'N' THEN 'No'
           WHEN SoldAsVacant = 'Y' THEN 'Yes'
           ELSE SoldAsVacant
       END AS New_SoldAsVacant
FROM [Portfolio Project].DBO.HousingProject;


-- Updating SoldAsVacant to standardize registers to 'Yes' or 'No'
UPDATE [Portfolio Project].DBO.HousingProject
SET SoldAsVacant = CASE
                       WHEN SoldAsVacant = 'N' THEN 'No'
                       WHEN SoldAsVacant = 'Y' THEN 'Yes'
                       ELSE SoldAsVacant
                   END;
                   
                   
-- Checking if is there only 'Yes' or 'No' in the updated SoldAsVacant column
SELECT DISTINCT SoldAsVacant
FROM [Portfolio Project].dbo.HousingProject;
----------------------------------------------------------------------------\\-----------------------  
--(6) - Removing Duplicated Rows

-- Applying window function to get the registers that have same ParcelID, PropertyAddress, SaleDate, SalePrice and LegalReference
SELECT *,
       ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                       PropertyAddress,
                                       SaleDate,
                                       SalePrice,
                                       LegalReference
                          ORDER BY UniqueID) AS ROW_NUM
FROM [Portfolio Project].DBO.HousingProject;


-- Filtering ROW_NUM > 1 to get duplicated registers
WITH CTE_RowNum AS
  (SELECT *,
          ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                          PropertyAddress,
                                          SaleDate,
                                          SalePrice,
                                          LegalReference
                             ORDER BY UniqueID) AS ROW_NUM
   FROM [Portfolio Project].DBO.HousingProject)
SELECT *
FROM CTE_RowNum
WHERE ROW_NUM > 1;


-- Deleting duplicated registers with ROW_NUM > 1
WITH CTE_RowNum AS
  (SELECT *,
          ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                          PropertyAddress,
                                          SaleDate,
                                          SalePrice,
                                          LegalReference
                             ORDER BY UniqueID) AS ROW_NUM
   FROM [Portfolio Project].DBO.HousingProject)
DELETE
FROM CTE_RowNum
WHERE ROW_NUM > 1;


-- Checking if the query above is empty, since all duplicated have been deleted
WITH CTE_RowNum AS
  (SELECT *,
          ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                          PropertyAddress,
                                          SaleDate,
                                          SalePrice,
                                          LegalReference
                             ORDER BY UniqueID) AS ROW_NUM
   FROM [Portfolio Project].DBO.HousingProject)
SELECT *
FROM CTE_RowNum
WHERE ROW_NUM > 1;