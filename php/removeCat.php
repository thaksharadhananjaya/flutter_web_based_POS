<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $cat = mysqli_real_escape_string($connection, $_POST['Category']);	

  $query = "DELETE FROM `catogery` WHERE `catogery` = '$cat'";  
  mysqli_query($connection, $query);
  
  $query = "UPDATE `item` SET `Category` = 'Uncategory' WHERE `Category` = '$cat' ";  
  mysqli_query($connection, $query);

  ?>