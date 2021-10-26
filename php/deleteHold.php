<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $billID = $_POST['BillID'];

  $query="DELETE FROM `hold` WHERE `BillID` ='$billID'";
	  
	$result = mysqli_query($connection,$query);

 ?>