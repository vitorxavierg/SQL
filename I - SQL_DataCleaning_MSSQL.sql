--(1) - Exploring the Dataset

SELECT *
FROM [Portfolio Project].dbo.HousingProject;
----------------------------------------------------------------------------\\-----------------------
--(2) - Standardizing Date Format

SELECT SaleDate,
       CONVERT(Date,SaleDate) AS New_SaleDate
FROM [Portfolio Project].dbo.HousingProject;



ALTER TABLE [Portfolio Project].dbo.HousingProject ADD New_SaleDate Date;



UPDATE [Portfolio Project].dbo.HousingProject
SET New_SaleDate = CONVERT(Date,SaleDate);
----------------------------------------------------------------------------\\-----------------------
--(3) - Removing Missing Data:

SELECT PropertyAddress
FROM [Portfolio Project].dbo.HousingProject
WHERE PropertyAddress IS NULL;



SELECT *
FROM [Portfolio Project].dbo.HousingProject
ORDER BY ParcelID;



SELECT x.ParcelID,
       x.PropertyAddress,
       y.ParcelID,
       y.PropertyAddress
FROM [Portfolio Project].dbo.HousingProject x
INNER JOIN [Portfolio Project].dbo.HousingProject y ON x.ParcelID = y.ParcelID
AND x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress IS NULL;



SELECT x.ParcelID,
       x.PropertyAddress,
       y.ParcelID,
       y.PropertyAddress,
       ISNULL(x.PropertyAddress, y.PropertyAddress) AS Filling_Test
FROM [Portfolio Project].dbo.HousingProject x
INNER JOIN [Portfolio Project].dbo.HousingProject y ON x.ParcelID = y.ParcelID
AND x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress IS NULL;
----------------------------------------------------------------------------\\-----------------------
--(4) - Breaking out column’s content into distinct columns

SELECT OwnerAddress
FROM [Portfolio Project].dbo.HousingProject
ORDER BY 1 DESC;



SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS SplittedOwnerAddress,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS SplittedOwnerCity,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS SplittedOwnerState
FROM [Portfolio Project].dbo.HousingProject
ORDER BY 1 DESC;



ALTER TABLE [Portfolio Project].dbo.HousingProject ADD SplittedOwnerAddress NVARCHAR(255);



ALTER TABLE [Portfolio Project].dbo.HousingProject ADD SplittedOwnerCity NVARCHAR(255);



ALTER TABLE [Portfolio Project].dbo.HousingProject ADD SplittedOwnerState NVARCHAR(255);



UPDATE [Portfolio Project].dbo.HousingProject
SET SplittedOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);



UPDATE [Portfolio Project].dbo.HousingProject
SET SplittedOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);



UPDATE [Portfolio Project].dbo.HousingProject
SET SplittedOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);



SELECT *
FROM [Portfolio Project].dbo.HousingProject;
----------------------------------------------------------------------------\\-----------------------
--(5) - Fixing String Typos

SELECT SoldAsVacant, COUNT(SoldAsVacant) as Number_of_Registers
FROM [Portfolio Project].DBO.HousingProject
GROUP BY SoldAsVacant;



SELECT SoldAsVacant,
       CASE
           WHEN SoldAsVacant = 'N' THEN 'No'
           WHEN SoldAsVacant = 'Y' THEN 'Yes'
           ELSE SoldAsVacant
       END AS New_SoldAsVacant
FROM [Portfolio Project].DBO.HousingProject;



UPDATE [Portfolio Project].DBO.HousingProject
SET SoldAsVacant = CASE
                       WHEN SoldAsVacant = 'N' THEN 'No'
                       WHEN SoldAsVacant = 'Y' THEN 'Yes'
                       ELSE SoldAsVacant
                   END;
                   
                   
                   
SELECT DISTINCT SoldAsVacant
FROM [Portfolio Project].dbo.HousingProject;
----------------------------------------------------------------------------\\-----------------------  
--(6) - Removing Duplicated Rows

SELECT *,
       ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                       PropertyAddress,
                                       SaleDate,
                                       SalePrice,
                                       LegalReference
                          ORDER BY UniqueID) AS ROW_NUM
FROM [Portfolio Project].DBO.HousingProject;



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