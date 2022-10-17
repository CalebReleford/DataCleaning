--Cleaning Data in SQL Queries

Select *
From PortfolioProject.dbo.NashvilleHousing
-------------------------------------------------------------------------------------------------------------------------

-- Standardized Date Format

Select [Sale Date Converted], SaleDate
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add [Sale Date Converted] Date
Update PortfolioProject.dbo.NashvilleHousing
SET [Sale Date Converted] = FORMAT (SaleDate, 'MM-dd-yyyy')--CONVERT(Date, SaleDate)

Select FORMAT (SaleDate, 'MM-dd-yyyy') as 'Date Time'
From PortfolioProject.dbo.NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------

-- Populate Missing Property Addresses (via referencing ParcelID)


Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------

-- Splitting Addresses Into Multiple Columns (Address, City, State)

-- Property Address Split

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Add [Property Address Split] nvarchar(255)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add [Property City Split] nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
Set [Property Address Split] = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Update PortfolioProject.dbo.NashvilleHousing
Set [Property City Split] = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- Owner Address Split

Select
PARSENAME(Replace(OwnerAddress,',','.'), 3) as [Owner Address Split],
PARSENAME(Replace(OwnerAddress,',','.'), 2) as [Owner City Split],
PARSENAME(Replace(OwnerAddress,',','.'), 1) as [Owner State Split]
From PortfolioProject.dbo.NashvilleHousing 

Alter Table PortfolioProject.dbo.NashvilleHousing
Add [Owner Address Split] nvarchar(255)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add [Owner City Split] nvarchar(255)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add [Owner State Split] nvarchar(255)


Update PortfolioProject.dbo.NashvilleHousing
SET [Owner Address Split] = PARSENAME(Replace(OwnerAddress,',','.'), 3)

Update PortfolioProject.dbo.NashvilleHousing
SET [Owner City Split] = PARSENAME(Replace(OwnerAddress,',','.'), 2)

Update PortfolioProject.dbo.NashvilleHousing
SET [Owner State Split] = PARSENAME(Replace(OwnerAddress,',','.'), 1)

-------------------------------------------------------------------------------------------------------------------------

-- Replacing 'N' / 'Y' with 'Yes' / 'No'

Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = Case 
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing 
Group by SoldAsVacant
Order by 2

-------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

Select *
From PortfolioProject.dbo.NashvilleHousing 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1

-------------------------------------------------------------------------------------------------------------------------

-- Remove Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate