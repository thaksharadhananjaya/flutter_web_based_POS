<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $billID = $_POST['BillID'];
  $name = mysqli_real_escape_string($connection, $_POST['ItemName']);
  $itemID="2";
  $qty = mysqli_real_escape_string($connection, $_POST['Qty']);
  $bal = mysqli_real_escape_string($connection, $_POST['Bal']);
  $user = mysqli_real_escape_string($connection, $_POST['User']);
  $type = mysqli_real_escape_string($connection, $_POST['Type']);

  $query="INSERT INTO `return_bill`(`Bill ID`, `Item ID`, `Item Name`, `Return Quantity`, `Balance (Rs.)`, `User Name`, `Type`) 
  VALUES ('$billID','$itemID', '$name', '$qty','$bal','$user','$type')";

  $queryResult = $connection->
      query($query);

 ?>