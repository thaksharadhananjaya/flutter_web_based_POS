<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $date = $_POST['Date'];
  $bill_iD = $_POST['BillID'];	
  
  $query = "SELECT `Bill ID`,
  DATE_FORMAT(`Date & Time`,'%Y-%m-%d | %h:%i %p') AS 'Time',
  FORMAT(`Total (Rs.)`,2) AS 'Total', 
  FORMAT(`Discount (Rs.)`,2) AS 'Dis', 
  FORMAT(`Net Total (Rs.)`,2) AS 'NetTotal', 
  FORMAT(`Balance (Rs.)`,2) AS 'Bal', `Balance (Rs.)` AS 'BalValue', 
  `Customer ID` AS 'Cus',`Payment Method` AS 'PayMethod' FROM `bill` 
  WHERE `Net Total (Rs.)`!=0 AND `Date & Time` LIKE '$date%' ORDER BY `Time` DESC ";

  if($bill_iD!="-1"){
	  $query = "SELECT `Bill ID`,
	  DATE_FORMAT(`Date & Time`,'%Y-%m-%d | %h:%i %p') AS 'Time', 
	  FORMAT(`Total (Rs.)`,2) AS 'Total', 
	  FORMAT(`Discount (Rs.)`,2) AS 'Dis', 
	  FORMAT(`Net Total (Rs.)`,2) AS 'NetTotal', 
	  FORMAT(`Balance (Rs.)`,2) AS 'Bal', 
	  `Balance (Rs.)` AS 'BalValue', 
	  `Customer ID` AS 'Cus', 
	  `Payment Method` AS 'PayMethod' FROM `bill` 
	  WHERE `Date & Time` LIKE '$date%' AND `Bill ID` = '$bill_iD' AND `Net Total (Rs.)`!=0 ORDER BY `Time` DESC";
  }
  
  $queryResult = $connection->
      query($query);

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>