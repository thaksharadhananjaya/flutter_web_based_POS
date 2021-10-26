<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");

  $item_iD = mysqli_real_escape_string($connection, $_POST['ItemID']);
  $cat = mysqli_real_escape_string($connection, $_POST['Cat']);
  $q="SELECT * from item";
  
  if($item_iD!="-1"){
	  $q="SELECT * from item WHERE `Item ID` = '$item_iD' OR `Item Name` = '$item_iD'";
  }
  if($cat!="All"){
	  $q = "SELECT * from item WHERE Category = '$cat'";
	  if($item_iD!="-1"){
		$q="SELECT * from item WHERE `Item ID` = '$item_iD' AND Category = '$cat'";
	  }
  }
  
  $queryResult = $connection->
      query($q);//change your_table with your database table that you want to fetch values

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  
  if (empty($result)) 
  {
	$r[]=array('Item ID'=>'not');
	echo json_encode($r);
  }else{
	echo json_encode($result);
  }
 ?>