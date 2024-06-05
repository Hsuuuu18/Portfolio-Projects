-- Cleaning Data in SQL Queries --


Select * 
From [Portfolio Project].dbo.NashvilleHousing
--------------------------------------------------------------------------------------
-- Standardized Date Format --
Select SaleDate, CONVERT(Date, SaleDate)
From [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From [Portfolio Project].dbo.NashvilleHousing

--------------------------------------------------------------------------------------
-- Populate Property Address Data --
Select * 
From [Portfolio Project].dbo.NashvilleHousing
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

--------------------------------------------------------------------------------------
-- Breaking Out address into Individual Columns (Address, City, State)

--- FOR PropertyAddress
Select PropertyAddress
From [Portfolio Project].dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, 
SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress)) +1 ,  LEN(PropertyAddress)) AS City
From [Portfolio Project].dbo.NashvilleHousing

-- Update table Address
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

-- Update table city
ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress)) +1 ,  LEN(PropertyAddress))



--- FOR OwnerAddress
Select OwnerAddress
From [Portfolio Project].dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio Project].dbo.NashvilleHousing

-- Update table OwnerAddress (Address)
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-- Update table OwnerAddress (City)
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- Update table OwnerAddress (State)
ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(225)
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project].dbo.NashvilleHousing
GROUP BY SoldAsVacant
Order BY 2

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From [Portfolio Project].dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

--------------------------------------------------------------------------------------
-- Remove Duplicates
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER  (
	PARTITION BY ParcelID, 
	PropertyAddress, 
	SalePrice, 
	SaleDate, 
	LegalReference
	ORDER BY
	UniqueID
	) row_num

From [Portfolio Project].dbo.NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
From [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN SaleDate

