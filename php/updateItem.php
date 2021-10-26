<?php 
	include "conn.php";
	header("Access-Control-Allow-Origin: *");
	
    $item_iD = mysqli_real_escape_string($connection, $_POST['ItemID']);
    $name = mysqli_real_escape_string($connection, $_POST['ItemName']);
	$code = mysqli_real_escape_string($connection, $_POST['BarCode']);
	$img = mysqli_real_escape_string($connection, $_POST['Image']);
	$buying_price = mysqli_real_escape_string($connection, $_POST['BuyingPrice']);
    $selling_price = mysqli_real_escape_string($connection, $_POST['SellingPrice']);
	$qty = mysqli_real_escape_string($connection, $_POST['Quantity']);
	$alt = mysqli_real_escape_string($connection, $_POST['Alt']);
    $cat = mysqli_real_escape_string($connection, $_POST['Category']);

	$query = "UPDATE `item` SET `Item Name` = '$name', `BarCode` = '$code', `Image` = '$img', `Buying Price (Rs.)` = '$buying_price', `Selling Price (Rs.)` = '$selling_price', `Quantity` = '$qty', `Alert Quantity` = '$alt', `Category` = '$cat' WHERE `Item ID` = '$item_iD' ";  
	mysqli_query($connection, $query);
	
    if($results>0)
    {
        echo "Successfully";
    }