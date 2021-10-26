<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");

  $iD = mysqli_real_escape_string($connection, $_POST['ID']);
  
  $queryResult = $connection->
      query("SELECT * FROM `customer` WHERE `Customer ID`='$iD'");

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>