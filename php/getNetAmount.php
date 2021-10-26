<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");

  $bill_iD = mysqli_real_escape_string($connection, $_POST['BillID']);

  
  $queryResult = $connection->
      query("SELECT A.sumOfTotal, A.sumOfDis, B.sumOfNetTotal, B.sumOfNet From
		  (Select FORMAT(SUM(`billitem`.`Total (Rs.)`),2) As 'sumOfTotal',
		  FORMAT(SUM(`billitem`.`Quantity` * `billitem`.`DiscountPer`),2) As 'sumOfDis'
		  FROM `billitem` WHERE `billitem`.`Bill ID`='$bill_iD') AS A, 
          
          (Select 
		  FORMAT(SUM(`billitem`.`Net Total (Rs.)`),2) As 'sumOfNetTotal',
		  SUM(`billitem`.`Net Total (Rs.)`) As 'sumOfNet'
		  FROM `billitem` WHERE `billitem`.`Bill ID`='$bill_iD' AND `billitem`.`isFree`='0') AS B ");

  $result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  
  if ($result[0]["sumOfTotal"]!="") 
	{
		echo json_encode($result);
	}else{
		$r[]=array('sumOfTotal'=>'0.00','sumOfDis'=>'0.00','sumOfNetTotal'=>'0.00', 'sumOfNet'=>'0');
		echo json_encode($r);
	}
  
 ?>