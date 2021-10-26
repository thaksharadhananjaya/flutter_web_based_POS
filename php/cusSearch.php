<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $id = mysqli_real_escape_string($connection, $_POST['id']);

  $queryResult = $connection->
      query("SELECT `Customer ID` AS 'ID', `Name` from customer WHERE `Customer ID` Like '$id%' OR `Name` Like '%$id%'");

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
    $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>