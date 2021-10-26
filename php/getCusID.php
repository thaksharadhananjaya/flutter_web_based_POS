<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");

  $queryResult = $connection->
      query("SELECT `Customer ID` AS 'ID' from customer");

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
    $result[] = $fetchdata;
  }	
  
  if ($result[0]["ID"]!="") 
  {
	echo json_encode($result);
  }else{
	$r[]=array('ID'=>'not');
	echo json_encode($r);
  }
 ?>