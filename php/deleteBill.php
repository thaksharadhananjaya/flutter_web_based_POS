<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $bill_iD = mysqli_real_escape_string($connection, $_POST['BillID']);
  
  $queryResult = $connection->
  query("SELECT `Item ID`, `Quantity` FROM `billitem` WHERE `Bill ID` = '$bill_iD'");
  
   while ($row=$queryResult->fetch_assoc()) {
	  $item_id = $row["Item ID"];
      $qty = $row["Quantity"];
	  
	  $query = "UPDATE `item` SET `Quantity` = `Quantity`+$qty WHERE `Item ID` = '$item_id'";  
	  mysqli_query($connection, $query);
  }	

  $query = "DELETE FROM `billitem` WHERE `Bill ID` = '$bill_iD'";  
  mysqli_query($connection, $query);

  ?>