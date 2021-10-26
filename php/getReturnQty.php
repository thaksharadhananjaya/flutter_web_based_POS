<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $date = mysqli_real_escape_string($connection, $_POST['Date']);
  $item_iD = mysqli_real_escape_string($connection, $_POST['ItemID']);	
  
  $query = " SELECT `Item Name`, SUM(`Return Quantity`) AS 'RtnQty' FROM `return_bill` 
  WHERE `Date & Time` LIKE '$date%' GROUP BY `Item ID`";

  if($item_iD!="-1"){
	  $query = "SELECT `Item Name`, SUM(`Return Quantity`) AS 'RtnQty' FROM `return_bill` 
	  WHERE `Date & Time` LIKE '$date%' AND `Item ID` = '$item_iD' GROUP BY `Item ID`";
  }
  
  $queryResult = $connection->
      query($query);

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>