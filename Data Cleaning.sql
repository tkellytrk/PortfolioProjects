

Select *
From PortfolioProject.dbo.NashvilleHousing


Select SaleDate, Convert(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)


Alter Table NashvilleHousing
Add SaleDateConverted Date;


Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)


-- Populate Property Adress Data


Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isNull(a.propertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
set PropertyAddress = isNull(a.propertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Breaking out Address into Individual Columns ( Address, City, State )

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(propertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress NVarchar(255);


Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


Alter Table NashvilleHousing
Add PropertySplitCity NVarchar(255);


Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(propertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing





Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
ParseName( RePlace(OwnerAddress, ',', '.'), 3)
, ParseName( RePlace(OwnerAddress, ',', '.'), 2)
, ParseName( RePlace(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing



Alter Table NashvilleHousing
Add OwnerSplitAddress NVarchar(255);


Update NashvilleHousing
Set OwnerSplitAddress = ParseName( RePlace(OwnerAddress, ',', '.'), 3)


Alter Table NashvilleHousing
Add OwnerSplitCity NVarchar(255);


Update NashvilleHousing
Set OwnerSplitCity = ParseName( RePlace(OwnerAddress, ',', '.'), 2)


Alter Table NashvilleHousing
Add OwnerSplitState NVarchar(255);


Update NashvilleHousing
Set OwnerSplitState = ParseName( RePlace(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProject.dbo.NashvilleHousing



-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldasVacant), Count(SoldASVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End


-- Removing Duplicates

With RowNumCTE as (
Select *, 
	Row_Number() Over (
	Partition by  ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order by UniqueID
	) Row_num


From PortfolioProject.dbo.NashvilleHousing
--Order by parcelID
)
Delete 
from RowNumCTE
where row_num > 1
--Order by PropertyAddress


Select *
From PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate