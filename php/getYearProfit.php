<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $date = mysqli_real_escape_string($connection, $_POST['Date']);


  $query="SELECT T.Time AS 'Time', SUM(T.`Net Total (Rs.)`) AS 'Earn', SUM(T.`Buying Price (Rs.)`) AS 'Cost', SUM(T.`Net Total (Rs.)`-T.`Quantity`*T.`Buying Price (Rs.)`) AS 'Profit' 
  FROM (SELECT DATE_FORMAT(`bill`.`Date & Time`,'%m') AS 'Time', `billitem`.`Buying Price (Rs.)`, `billitem`.`Net Total (Rs.)`, `billitem`.`Quantity` FROM `billitem`,`bill` 
  WHERE `bill`.`Bill ID` = `billitem`.`Bill ID` AND `bill`.`Date & Time` LIKE '$date%' ) AS T GROUP BY T.Time ";

  $queryResult = $connection->
      query($query);
  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>