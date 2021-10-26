<?php 
	include "conn.php";
	header("Access-Control-Allow-Origin: *");

	//Insert BillIteme tabele data for new bill
	
	$bill_iD = $_POST['BillID'];
    $item_iD = $_POST['ItemID'];
    $name = $_POST['ItemName'];
	$buying_price = $_POST['BuyingPrice'];
    $selling_price = $_POST['SellingPrice'];
    $total = $_POST['Total'];
	$net_toatal =$_POST['NetTotal'];
	$isFree =  $_POST['Free'];
	
	$result = mysqli_query($connection, "SELECT `Bill ID`,`Item ID`, `isFree` FROM `billitem` WHERE `Bill ID` = '$bill_iD' AND `Item ID` = '$item_iD' AND `isFree` = '$isFree'"); 
	if (!empty($result)) 
	{  
		$query = "UPDATE `billitem` SET `Quantity` = `Quantity`+1, `Total (Rs.)` = `Total (Rs.)`+$total, `Net Total (Rs.)` = `Net Total (Rs.)` - `DiscountPer` + $net_toatal WHERE `billitem`.`Bill ID` = '$bill_iD' AND `billitem`.`Item ID` = '$item_iD' AND `billitem`.`isFree` = '$isFree'";  
		mysqli_query($connection, $query);
	}
	$query = "INSERT INTO `billitem` (`Bill ID`, `Item ID`, `Item Name`, `Buying Price (Rs.)`, `Selling Price (Rs.)`, `Price (Rs.)`, `Total (Rs.)`, `Net Total (Rs.)`, `isFree`) 
	VALUES ('$bill_iD', '$item_iD', '$name', '$buying_price', '$selling_price', '$selling_price', '$total', '$net_toatal', '$isFree')"; 

	$results = mysqli_query($connection, $query);
	
	$query = "UPDATE `item` SET `Quantity` = `Quantity`-1 WHERE `Item ID` = '$item_iD'";  
	mysqli_query($connection, $query);
	