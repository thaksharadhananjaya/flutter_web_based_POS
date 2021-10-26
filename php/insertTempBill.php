<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $bill_iD = mysqli_real_escape_string($connection, $_POST['BillID']);
  
  $query = "DELETE FROM `tempbill`"; 

	$results = mysqli_query($connection, $query);

  $query = "INSERT INTO `tempbill` (`ID`) 
	VALUES ('$bill_iD')"; 

	$results = mysqli_query($connection, $query);

  ?>