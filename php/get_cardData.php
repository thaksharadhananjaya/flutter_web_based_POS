<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");

  $bill_iD = $_POST['BillID'];
  $item_iD = $_POST['ItemID'];
  $qty = mysqli_real_escape_string($connection, $_POST['Qty']);
  $total = $_POST['Total'];
  $netTotal = $_POST['NetTotal'];
  $free = $_POST['Free'];
  $checker=number_format($qty);
  
	  
  if($checker>0){
	  
	  $sql = "SELECT `Quantity` FROM billitem WHERE `billitem`.`Bill ID` = '$bill_iD' AND `billitem`.`Item ID` = '$item_iD' AND `billitem`.`isFree` = '$free'";
	  $result = $connection->query($sql);
	  
	  $q = 0;
	  while($row = $result->fetch_assoc()) {
		  $q = (int)$row["Quantity"];
	  }
	  $q = $checker - $q;
	  
	  $query = "UPDATE `billitem` SET `Quantity` = '$qty', `Total (Rs.)` = '$total', `Net Total (Rs.)` = '$netTotal' WHERE `billitem`.`Bill ID` = '$bill_iD' AND `billitem`.`Item ID` = '$item_iD' AND `billitem`.`isFree` = '$free'";  
	  mysqli_query($connection, $query);
		
	  $query = "UPDATE `item` SET `Quantity` = `Quantity` - ($q) WHERE `Item ID` = '$item_iD'";  
	  mysqli_query($connection, $query);
  }else if($checker==-4){
	  $sql = "SELECT `Quantity` FROM billitem WHERE `Bill ID` = '$bill_iD' AND `Item ID` = '$item_iD' AND `isFree` = '$free'";
	  $result = $connection->query($sql);
	  
	  $q = 0;
	  while($row = $result->fetch_assoc()) {
		  $q = (int)$row["Quantity"];
	  }
	  
	  $query = "UPDATE `item` SET `Quantity` = `Quantity` + ($q) WHERE `Item ID` = '$item_iD'";  
	  mysqli_query($connection, $query);
	  
	  $query = "DELETE FROM `billitem` WHERE `Bill ID` = '$bill_iD' AND `Item ID` = '$item_iD'  AND `isFree` = '$free'";  
	  mysqli_query($connection, $query);
  }

  
  $queryResult = $connection->
      query("SELECT `billitem`.`Item ID`,
		  `billitem`.`Item Name`,
		  FORMAT(`billitem`.`Selling Price (Rs.)`,2) AS 'SPrice',
		  `billitem`.`Price (Rs.)` As 'Price',
		  `billitem`.`Quantity`,
		  `item`.`image`,
		  `item`.`Quantity` AS 'Qty',
		  FORMAT(`billitem`.`Total (Rs.)`,2) AS 'Total (Rs.)',
		  FORMAT(`billitem`.`Net Total (Rs.)`,2) AS 'Net Total (Rs.)',
		  `billitem`.`Total (Rs.)` AS 'Total',
		  `billitem`.`Selling Price (Rs.)` AS 'SellingPrice',
		  `billitem`.`DiscountPer`,
		  `billitem`.`isFree`,
		  FORMAT(`billitem`.`DiscountPer`,2) AS 'Discount'
		  FROM `billitem`, `item` WHERE `billitem`.`Bill ID`='$bill_iD'  AND `item`.`Item ID`=`billitem`.`Item ID`");

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>