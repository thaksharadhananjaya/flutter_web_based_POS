<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  
  $cat = mysqli_real_escape_string($connection, $_POST['Category']);
  

  $query = "INSERT INTO `catogery` (`Catogery`) VALUES ('$cat')"; 

	$results = mysqli_query($connection, $query);
	

  ?>