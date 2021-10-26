<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $item_iD = mysqli_real_escape_string($connection, $_POST['ID']);
  $barCode = mysqli_real_escape_string($connection, $_POST['BarCode']);
  $name = mysqli_real_escape_string($connection, $_POST['Name']);
  $img = mysqli_real_escape_string($connection, $_POST['Image']);
  $buying_price = mysqli_real_escape_string($connection, $_POST['BuyingPrice']);
  $selling_price = mysqli_real_escape_string($connection, $_POST['SellingPrice']);
  $qty = mysqli_real_escape_string($connection, $_POST['Quantity']);
  $alt = mysqli_real_escape_string($connection, $_POST['Alt']);
  $cat = mysqli_real_escape_string($connection, $_POST['Category']);
  

  $query = "INSERT INTO `item` (`Item ID`, `BarCode`, `Item Name`, `image`, `Buying Price (Rs.)`, `Selling Price (Rs.)`, `Quantity`, `Alert Quantity`, `Category`) 
  VALUES ('$item_iD', '$barCode', '$name', '$img', '$buying_price', '$selling_price', '$qty', '$alt', '$cat')"; 

	$results = mysqli_query($connection, $query);
	

  ?>