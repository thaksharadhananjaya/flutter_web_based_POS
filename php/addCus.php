<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");

  $customer_iD = mysqli_real_escape_string($connection, $_POST['ID']);
  $name = mysqli_real_escape_string($connection, $_POST['Name']);
  $adds = mysqli_real_escape_string($connection, $_POST['Address']);
  $contact = mysqli_real_escape_string($connection, $_POST['Contact']);

  $query = "INSERT INTO `Customer` (`Customer ID`, `Name`, `Address`, `Contact`) 
	VALUES ('$customer_iD', '$name', '$adds', '$contact')"; 

	$results = mysqli_query($connection, $query);

  ?>