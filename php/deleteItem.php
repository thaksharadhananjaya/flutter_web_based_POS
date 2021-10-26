<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $item_iD = mysqli_real_escape_string($connection, $_POST['ItemID']);	

  $query = "DELETE FROM `item` WHERE `Item ID` = '$item_iD'";  
  mysqli_query($connection, $query);

  ?>