<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");

  $queryResult = $connection->
      query("SELECT * FROM `catogery` WHERE `Catogery` != 'Uncategory' Order BY `Catogery` ASC");

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>