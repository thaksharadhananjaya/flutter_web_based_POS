<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $date = mysqli_real_escape_string($connection, $_POST['Date']);
  $item_iD = mysqli_real_escape_string($connection, $_POST['ItemID']);	
  
  $query = "SELECT `billitem`.`Item Name`, SUM(`billitem`.`Quantity`) AS 'Qty' FROM `billitem`,`bill` 
	  WHERE `bill`.`Date & Time` LIKE '$date%' AND `bill`.`Bill ID` = `billitem`.`Bill ID` GROUP BY `billitem`.`Item ID` ";
  
  if($item_iD!="-1"){
	  $query = "SELECT `billitem`.`Item Name`, SUM(`billitem`.`Quantity`) AS 'Qty' FROM `billitem`,`bill` 
	  WHERE `bill`.`Date & Time` LIKE '$date%' AND `bill`.`Bill ID` = `billitem`.`Bill ID` AND `billitem`.`Item ID` = '$item_iD' 
	  GROUP BY `billitem`.`Item ID`";
  }

  $queryResult = $connection->
      query($query);

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>