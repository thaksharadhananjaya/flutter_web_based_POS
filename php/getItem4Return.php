<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");

  $bill_iD = $_POST['BillID'];
  
  $queryResult = $connection->
      query("SELECT `billitem`.`Item ID`,
		  `billitem`.`Item Name`,
		   `billitem`.`Item ID`,
		  `billitem`.`Selling Price (Rs.)` AS 'SPrice',
		  `billitem`.`Price (Rs.)` As 'Price',
		  `billitem`.`Quantity`,
		  `billitem`.`isFree`,
		  `item`.`image`,
		  `item`.`Quantity` AS 'Qty',
		  FORMAT(`billitem`.`Total (Rs.)`,2) AS 'Total (Rs.)',
		  FORMAT(`billitem`.`Net Total (Rs.)`,2) AS 'Net Total (Rs.)',
		  `billitem`.`Total (Rs.)` AS 'Total',
		  `billitem`.`Net Total (Rs.)` AS 'NetTotal',
		  FORMAT(`billitem`.`DiscountPer`*`billitem`.`Quantity`,2) AS 'Discount',
		  `billitem`.`DiscountPer` AS 'Dis'
		  FROM `billitem`, `item` WHERE `billitem`.`Bill ID`='$bill_iD'  AND `item`.`Item ID`=`billitem`.`Item ID`");

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>