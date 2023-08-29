/*

Cleaning Data in SQL Queries

*/

SELECT * 
FROM NashvilleHousing..NashvilleHousing

--------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousing..NashvilleHousing

UPDATE NashvilleHousing..NashvilleHousing 
SET SaleDate = CONVERT(Date, SaleDate)


-- If it doesn't Update properly

ALTER TABLE NashvilleHousing..NashvilleHousing
Add SaleDateConverted Date

UPDATE NashvilleHousing..NashvilleHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate)

 --------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM NashvilleHousing..NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing..NashvilleHousing as a
JOIN NashvilleHousing..NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress is null

UPDATE a
 SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing..NashvilleHousing as a
JOIN NashvilleHousing..NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM NashvilleHousing..NashvilleHousing
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing..NashvilleHousing


ALTER TABLE NashvilleHousing..NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing..NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing..NashvilleHousing
Add PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing..NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT * 
FROM NashvilleHousing..NashvilleHousing

SELECT OwnerAddress 
FROM NashvilleHousing..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing..NashvilleHousing

ALTER TABLE NashvilleHousing..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing..NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing..NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing..NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing..NashvilleHousing
Add OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing..NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant) 
FROM NashvilleHousing..NashvilleHousing


SELECT SoldAsVacant, 
CASE 
	WHEN SoldAsVacant = 'Y' THEN  'Yes'
	WHEN SoldAsVacant = 'N' THEN  'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing..NashvilleHousing

UPDATE NashvilleHousing..NashvilleHousing
SET SoldAsVacant = 
CASE 
	WHEN SoldAsVacant = 'Y' THEN  'Yes'
	WHEN SoldAsVacant = 'N' THEN  'No'
	ELSE SoldAsVacant
END

----------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
	ORDER BY
		UniqueID
		) row_num
FROM NashvilleHousing..NashvilleHousing
--ORDER BY ParcelID
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1


--------------------------------------------------------------------------------------

-- Delete Unused Columns
SELECT * 
FROM NashvilleHousing..NashvilleHousing


ALTER TABLE NashvilleHousing..NashvilleHousing
DROP Column OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE NashvilleHousing..NashvilleHousing
DROP Column SaleDate
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

