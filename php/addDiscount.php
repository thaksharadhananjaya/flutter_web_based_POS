<?php 
	include "conn.php";
	header("Access-Control-Allow-Origin: *");

	//Insert BillIteme tabele data for new bill
	
	$bill_iD = mysqli_real_escape_string($connection, $_POST['BillID']);
    $item_iD = mysqli_real_escape_string($connection, $_POST['ItemID']);
	$discountPer = mysqli_real_escape_string($connection, $_POST['DisPer']);
	$price = mysqli_real_escape_string($connection, $_POST['Price']);
    $netTotal = mysqli_real_escape_string($connection, $_POST['NetTotal']);

	
	$query = "UPDATE `billitem` SET `Price (Rs.)` = '$price', `DiscountPer` = '$discountPer', `Net Total (Rs.)` = '$netTotal' WHERE `Bill ID` = '$bill_iD' AND `Item ID` = '$item_iD'";  
	mysqli_query($connection, $query);
	
    if($results>0)
    {
        echo "Successfully";
    }