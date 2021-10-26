<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
   $date = mysqli_real_escape_string($connection, $_POST['Date']);
  $item_iD = mysqli_real_escape_string($connection, $_POST['ItemID']);


     $query="SELECT A.Qty, B.RtnQty,A.Pofit,C.Free
 FROM 
 ( SELECT `billitem`.`Item ID`, SUM(`billitem`.`Quantity`) AS 'Qty', FORMAT(SUM(`billitem`.`Net Total (Rs.)`) - SUM(`Quantity`*`Buying Price (Rs.)`),2) as 'Pofit' FROM `billitem`, `bill` 
  WHERE `bill`.`Date & Time` LIKE '$date%' AND `bill`.`Bill ID` = `billitem`.`Bill ID`) as A, 
 ( SELECT `Item ID`, SUM(`Return Quantity`) AS 'RtnQty' FROM `return_bill` WHERE `Date & Time` LIKE '$date%') as B,
 ( SELECT `billitem`.`Item ID`, SUM(`billitem`.`Quantity`) AS 'Free' FROM `billitem`, `bill` 
  WHERE `bill`.`Date & Time` LIKE '$date%' AND `bill`.`Bill ID` = `billitem`.`Bill ID`  AND `billitem`.`isFree` = '1') as C";
 
 if($item_iD!="-1"){
	  $query = "SELECT A.Qty, B.RtnQty,A.Pofit,C.Free
 FROM 
 ( SELECT `billitem`.`Item ID`, SUM(`billitem`.`Quantity`) AS 'Qty', FORMAT(SUM(`billitem`.`Net Total (Rs.)`) - SUM(`Quantity`*`Buying Price (Rs.)`),2) as 'Pofit' FROM `billitem`, `bill` 
  WHERE `bill`.`Date & Time` LIKE '$date%' AND `bill`.`Bill ID` = `billitem`.`Bill ID` AND `billitem`.`Item ID` = '$item_iD') as A, 
 ( SELECT `Item ID`, SUM(`Return Quantity`) AS 'RtnQty' FROM `return_bill` 
 WHERE `Date & Time` LIKE '$date%' AND `return_bill`.`Item ID` = '$item_iD') as B,
 ( SELECT `billitem`.`Item ID`, SUM(`billitem`.`Quantity`) AS 'Free' FROM `billitem`, `bill` 
  WHERE `bill`.`Date & Time` LIKE '$date%' AND `bill`.`Bill ID` = `billitem`.`Bill ID` AND `billitem`.`Item ID` = '$item_iD' AND `billitem`.`isFree` = '1') as C ";
  }

  $queryResult = $connection->
      query($query);
  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>