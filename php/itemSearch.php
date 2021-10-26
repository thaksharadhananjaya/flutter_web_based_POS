<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $name = mysqli_real_escape_string($connection, $_POST['name']);

  $queryResult = $connection->
      query("SELECT `Item ID` AS 'ID', `Item Name`, `image`, `Quantity`, `Alert Quantity` AS 'AltQty' from item 
	  WHERE `Item Name` Like '$name%' OR `Item ID` = '$name' OR `BarCode` = '$name'");//change your_table with your database table that you want to fetch values

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>