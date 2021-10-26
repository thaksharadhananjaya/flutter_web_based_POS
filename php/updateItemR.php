<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");

  $itemID = mysqli_real_escape_string($connection, $_POST['ItemID']);
  $q = mysqli_real_escape_string($connection, $_POST['Qty']);
  
  $queryResult = $connection->
      query("UPDATE `item` SET `Quantity` = `Quantity`+'$q' WHERE `item`.`Item ID` = '$itemID' ");

 ?>