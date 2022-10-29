--Cleaning Data in SQL

Select*
From NashvilleHousing

--Date formating (Standardizing Date time format into just date)

Select SaleDateConverted, Convert (Date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert (Date,SaleDate)

--This did not work for some reason
--Instead Creating a new column by altering the existing table and then updating the Date values in the newly created column

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert (Date,SaleDate)

--Dealing with Nulls in the "PropertyAddress" column

Select *
From NashvilleHousing
--Where PropertyAddress is Null
Order By ParcelID

/* In order to not loose data we need to populate the Null values. To do that we need look for ParcelID that has PropertyAddress and are repeating, if the repeated 
PropertyAddress is Null then we have to re-populate it with the existing ParcelID address 
*/

--Self joining the tables
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is Null

Update a 
SET PropertyAddress = isnull (a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is Null

/* Explanation of the above Query 
The table is joined to itself where ParcelID column is common but seperated by UniqueID column 

ISNULL  
This function will copy the value before comma to the value after comma 

Further the table is updated 
*/

--Breaking out Address into Individual Columns (Address, City, State)

Select *
From NashvilleHousing
--Where PropertyAddress is Null
--Order By ParcelID

Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) As Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, Len (PropertyAddress)) As Address

From NashvilleHousing

/* Explanation of the above Query
We are using SUBSTRING function to break down the address 1 is the first value that is getting selected up untill "," which is represented in CHARINDEX function 
In order to get rid of the Comma "," in the output -1 is added to the query 

Next Seperating City from the address same SUBSTRING function is used and the first value is considered as the previous CHARINDEX function itself and +1 is added to 
again get rid of the comma ",". Further LEN function is used to incoprated rest of the string as the length of the string further is unknown 

We cannot seperate 2 values from 1 column without creating 2 seperate columns
Creating 2 colunms like before
*/

--First Column

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar (255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

--Second Column

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar (255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, Len (PropertyAddress))

Select*
From NashvilleHousing


/*
Doing exact same seperation of addresses for OwnerAddress as well but using different Queries

PARSENAME
PARSENAME is a function that seperates the string with respect to periods ( . ) in the string
Example 
 Column Content -- 18.Akanksha.chs.Mumbai
 Output after using the function -- 18   Akanksha   chs   Mumbai

*/

Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(Replace (OwnerAddress , ',', '.'), 3),
PARSENAME(Replace (OwnerAddress , ',', '.'), 2),
PARSENAME(Replace (OwnerAddress , ',', '.'), 1)
From NashvilleHousing

--Creating and updating 3 colunms like before

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar (255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace (OwnerAddress , ',', '.'), 3)

--Second Column

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar (255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace (OwnerAddress , ',', '.'), 2)

--Third Column

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar (255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace (OwnerAddress , ',', '.'), 1)

Select*
From NashvilleHousing


--Change Y and N  to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant) , Count (SoldAsVacant)
From NashvilleHousing
Group by (SoldAsVacant)
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
     Else SoldAsVacant	
     End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant =  Case When SoldAsVacant = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
     Else SoldAsVacant	
     End


--Removing Duplicates

With RowNumCTE as (
Select*,
 ROW_NUMBER() Over(
 Partition by ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  Order By 
			   UniqueID
			   ) row_num
From NashvilleHousing
--Order by ParcelID
)

Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--Delete Unused Columns

Select *
From NashvilleHousing

Alter Table NashvilleHousing
 Drop Column OwnerAddress, PropertyAddress, TaxDistrict

 Alter Table NashvilleHousing
 Drop Column SaleDate