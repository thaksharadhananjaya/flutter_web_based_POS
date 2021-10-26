<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $billID = mysqli_real_escape_string($connection, $_POST['BillID']);
  $total = mysqli_real_escape_string($connection, $_POST['Total']);
  $netTotal = mysqli_real_escape_string($connection, $_POST['NetTotal']);
  $dis = mysqli_real_escape_string($connection, $_POST['Dis']);
  $bal = mysqli_real_escape_string($connection, $_POST['Balance']);

  $query="UPDATE 
  `bill` SET `Total (Rs.)` = `Total (Rs.)`-$total, 
  `Net Total (Rs.)` = `Net Total (Rs.)` -$netTotal,
  `Discount (Rs.)` = `Discount (Rs.)`- $dis,
  `Balance (Rs.)` = $bal
  WHERE `bill`.`Bill ID`='$billID'";

  $queryResult = $connection->
      query($query);

 ?>