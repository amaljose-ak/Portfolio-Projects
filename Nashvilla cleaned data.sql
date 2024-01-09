--Cleaning Data in sql Queries

select *
from ProjectPortfolio.dbo.NashvilleHouse





-- Date Format

select salesDateConverted,CONVERT(date,SaleDate)
from ProjectPortfolio.dbo.NashvilleHouse

update NashvilleHouse
set SaleDate = CONVERT(date,SaleDate)

alter table NashvilleHouse
add salesDateConverted Date;

Update NashvilleHouse
SET salesDateConverted = CONVERT(date,SaleDate)



--Property address data

select *
from ProjectPortfolio.dbo.NashvilleHouse
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.ParcelID,b.PropertyAddress)
from ProjectPortfolio.dbo.NashvilleHouse a
join ProjectPortfolio.dbo.NashvilleHouse b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
where a.PropertyAddress is null	

update a 
set PropertyAddress= ISNULL(a.ParcelID,b.PropertyAddress)
join ProjectPortfolio.dbo.NashvilleHouse b
from ProjectPortfolio.dbo.NashvilleHouse a
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
where a.PropertyAddress is null	




-- address into individual coloumns(address,city,state)

select PropertyAddress
from ProjectPortfolio.dbo.NashvilleHouse

SELECT 
    CASE WHEN CHARINDEX(',', PropertyAddress) > 0
         THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
         ELSE PropertyAddress
    END AS addressr,
    CASE WHEN CHARINDEX(',', PropertyAddress) > 0
         THEN SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
         ELSE ''
    END AS adress
FROM 
    ProjectPortfolio.dbo.NashvilleHouse





	Select OwnerAddress
From ProjectPortfolio.dbo.NashvilleHouse


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From ProjectPortfolio.dbo.NashvilleHouse



-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From ProjectPortfolio.dbo.NashvilleHouse
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From ProjectPortfolio.dbo.NashvilleHouse


-- Remove Duplicates

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

from ProjectPortfolio.dbo.NashvilleHouse
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress




--delete unused columns


Select *
From ProjectPortfolio.dbo.NashvilleHouse


ALTER TABLE ProjectPortfolio.dbo.NashvilleHouse
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

