<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $invoiceNo= mysqli_real_escape_string($connection, $_POST['No']);

  $queryResult = mysqli_query($connection, "SELECT `Bill ID` As 'invoiceNo' from bill WHERE `Bill ID` = '$invoiceNo'");

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
    $result[] = $fetchdata;
  }	
  
  if(mysqli_num_rows($queryResult)>0){
	  echo json_encode($result); 
  }else{
	echo json_encode($result[]= array(['invoiceNo'=>'null']));
  }
 ?>