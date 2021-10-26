<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");

  $queryResult = $connection->
      query("SELECT Month FROM (SELECT DATE_FORMAT(`bill`.`Date & Time`, '%Y %M') AS 'Month', 
	  DATE_FORMAT(`bill`.`Date & Time`, '%Y %m') AS 'D' 
	  FROM `bill` UNION DISTINCT SELECT DATE_FORMAT(`return_bill`.`Date & Time`, '%Y %M') AS 'Month', 
	  DATE_FORMAT(`return_bill`.`Date & Time`, '%Y %m') AS 'D' FROM `return_bill` ) as t ORDER BY `t`.`D` DESC  ");

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>