<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");

  $queryResult = $connection->
      query("SELECT * FROM (SELECT DATE_FORMAT(`bill`.`Date & Time`, '%Y %M %d') AS 'Date', 
	  DATE_FORMAT(`bill`.`Date & Time`, '%Y-%m-%d') AS 'DateValue' FROM `bill` 
	  UNION DISTINCT SELECT DATE_FORMAT(`return_bill`.`Date & Time`, '%Y %M %d') AS 'Date', DATE_FORMAT(`return_bill`.`Date & Time`, '%Y-%m-%d') AS 'DateValue' FROM `return_bill` ) 
	  as t ORDER BY t.DateValue DESC ");

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>