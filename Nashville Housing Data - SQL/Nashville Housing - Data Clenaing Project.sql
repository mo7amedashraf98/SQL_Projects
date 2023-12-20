SELECT * 
FROM PortfolioProject..NashvilleHousing

-- Standardize Date Format

-- The following method doesn't work, so I'll use another one
--SELECT SaleDate, CONVERT(Date,SaleDate)
--FROM NashvilleHousing

--Update NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

-- Another Method to standardize the Date Format

Alter Table NashvilleHousing
Add SaleConvertedDate Date; 

UPDATE NashvilleHousing
SET SaleConvertedDate = Convert(Date,SaleDate)

SELECT SaleConvertedDate
FROM NashvilleHousing


----------------------------------------------------------------

-- Populate Property Address Data

SELECT * 
FROM NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

-- Populating Property address for the null values
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Updating the table
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
----------------------------------------------------------------

-- Breaking out Owner Address & Property Address into individual columns (Address, City, State) 

SELECT PropertyAddress
FROM NashvilleHousing

-- Splitting the PopertyAddress into two columns
SELECT PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address, 
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM NashvilleHousing


-- Adding PropertySplitAddress column to the table
ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

-- Adding the data into the newly added column
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


-- Adding PropertySplitCity column to the table
ALTER TABLE NashvilleHousing 
ADD PropertySplitCity nvarchar(255);

-- Adding the data into the newly added column
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

----------------------

-- Splitting Owner Address to three columns (Address, City, State) using Parsename

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'), 3), 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2), 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) 
FROM NashvilleHousing

-- Adding OwnerSplitAddress column to the table
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

-- Adding OwnerSplitCity column to the table
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

-- Adding OwnerSplitState column to the table
ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

-- Adding the cleaned data to the newly added columns
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

----------------------------------------------------------------

-- Changing 'Y' and 'N' to 'Yes' and 'No' in the 'SoldasVacant' Column

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Changing 'Y' with 'Yes' and 'N' with 'N'

SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
END
FROM NashvilleHousing

-- Updating the table

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
END
----------------------------------------------------------------

-- Removing Duplicates
-- If we need to remove/delete any data, it's preferable to create a CTE to avoid original data loss
WITH RowNumCTE AS(
SELECT * , 
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate, 
		LegalReference   
		Order By UniqueID) row_num	
FROM NashvilleHousing
)
select *    --- To Remove Duplicates, we use DELETE instead of SELECT  
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

----------------------------------------------------------------

-- Remove Unused Columns

Alter table NashvilleHousing
DROP Column SaleDate, OwnerAddress, PropertyAddress, TaxDistrict



