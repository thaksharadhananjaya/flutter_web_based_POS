<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $date = mysqli_real_escape_string($connection, $_POST['Date']);


  $query="SELECT * From (SELECT SUM(`billitem`.`Net Total (Rs.)`) AS 'Earn', 
  SUM(`billitem`.`Buying Price (Rs.)`*`Quantity`) AS 'Cost', 
  SUM(`billitem`.`Net Total (Rs.)`-`billitem`.`Quantity`*`billitem`.`Buying Price (Rs.)`) AS 'Profit'
  FROM `billitem`,`bill` WHERE `bill`.`Bill ID` = `billitem`.`Bill ID` AND `bill`.`Date & Time` LIKE '$date%') AS A, 
  (SELECT SUM(`billitem`.`Item ID`) AS 'Free' FROM `billitem`,`bill` 
  WHERE `bill`.`Bill ID` = `billitem`.`Bill ID` AND `bill`.`Date & Time` LIKE '$date%' AND 
  `billitem`.`Selling Price (Rs.)` = `billitem`.`Total (Rs.)`-`billitem`.`Net Total (Rs.)`) AS B";

  $queryResult = $connection->
      query($query);
  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>