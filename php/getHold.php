<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");

  $query="SELECT `BillID`, DATE_FORMAT(`Time`,'%Y-%m-%d | %h:%i %p') AS 'Time' FROM `hold`";

  $queryResult = $connection->
      query($query);
	  
$result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>