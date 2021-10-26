<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $billID = $_POST['BillID'];
	
  $query = "INSERT INTO `hold`(`BillID`) VALUES ('$billID')";
  $results = mysqli_query($connection, $query);	
  if($results){
	   echo json_encode($result[]= array(['result'=>'1']));
		exit;
	}else{
		echo json_encode($result[]= array(['result'=>mysqli_errno($connection)]));
	   exit;
		
	}
  ?>