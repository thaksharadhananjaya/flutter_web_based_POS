<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $bill_iD = $_POST['BillID'];	
  $date = $_POST['Date'];	
  
  $query = "SELECT `Bill ID`,
  DATE_FORMAT(`Date & Time`,'%Y-%m-%d | %h:%i %p') AS 'Time'
  FROM `bill` 
  WHERE `Bill ID` LIKE '$bill_iD%' AND `Date & Time` LIKE '$date%' AND `Net Total (Rs.)`!=0";

  
  $queryResult = $connection->
      query($query);

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>