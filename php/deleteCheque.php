<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $billID = $_POST['BillID'];

  $query="DELETE FROM `cheque`";
	  
	$result = mysqli_query($connection,$query);

 ?>