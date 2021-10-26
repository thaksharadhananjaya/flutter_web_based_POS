<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $billID = $_POST['BillID'];
  $itemID = $_POST['ItemID'];
  $qty = $_POST['Qty'];
  $total = $_POST['Total'];
  $netTotal =$_POST['NetTotal'];
	

  $query="UPDATE `billitem` SET `Quantity` = `Quantity`-$qty, `Total (Rs.)` = `Total (Rs.)`-$total, `Net Total (Rs.)` = `Net Total (Rs.)` -$netTotal
  WHERE `billitem`.`Item ID` = '$itemID' AND `billitem`.`Bill ID`='$billID' AND `isFree` = '0'";

  $queryResult = $connection->
      query($query);

 ?>