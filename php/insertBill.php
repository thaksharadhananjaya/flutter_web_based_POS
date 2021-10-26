<?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");
  
  $billID = $_POST['BillID'];
  $invoiceNo = $_POST['InvoiceNo'];
  $date = $_POST['Date'];
  $userName = $_POST['User'];
  $customerID = $_POST['Cus'];
  $cash = $_POST['Cash'];
  $balance = $_POST['Bal'];
  $payMethod = $_POST['PMthd'];
  $bankDate = $_POST['BankDate'];
  
  $total = "";
  $discount = "";
  $netTotal = "";
  
  $queryResult = $connection->
  query("SELECT SUM(`Total (Rs.)`) AS 'total', SUM(`DiscountPer`*`Quantity`) AS 'dis', SUM(`Net Total (Rs.)`) AS 'netTotal' FROM `billitem` WHERE `Bill ID` = '$billID'");
  
   while ($row=$queryResult->fetch_assoc()) {
	  $total = $row["total"];
      $discount = $row["dis"];
	  $netTotal = $row["netTotal"];
	  
  }	

  $queryBill;
	
	if($date!=""){
		$queryBill = "INSERT INTO `bill` (`Bill ID`, `User Name`, `Customer ID`, `Date & Time`, `Total (Rs.)`, `Discount (Rs.)`, `Net Total (Rs.)`, `Cash (Rs.)`, `Balance (Rs.)`, `Payment Method`) 
	VALUES ('$invoiceNo', '$userName', '$customerID', $date, '$total', '$discount', '$netTotal', '$cash', '$balance', '$payMethod');"; 
	}else{
		$queryBill = "INSERT INTO `bill` (`Bill ID`, `User Name`, `Customer ID`, `Total (Rs.)`, `Discount (Rs.)`, `Net Total (Rs.)`, `Cash (Rs.)`, `Balance (Rs.)`, `Payment Method`) 
	VALUES ('$invoiceNo', '$userName', '$customerID', '$total', '$discount', '$netTotal', '$cash', '$balance', '$payMethod');"; 
	}

	$results;
	
	if($payMethod=="Cheque"){
		$queryCheque = "INSERT INTO `cheque` (`BillID`, `bankDate`) VALUES ('$invoiceNo', '$bankDate');"; 
		if($billID!=$invoiceNo){
				$queryBillItem = "UPDATE `billitem` SET `Bill ID` = '$invoiceNo' WHERE `billitem`.`Bill ID` = '$billID';";
				$query = $queryBill.$queryBillItem.$queryCheque;
				$results = mysqli_multi_query($connection, $query);
		}
		else{
			$query = $queryBill.$queryCheque;
			$results = mysqli_multi_query($connection, $query);	
		}
	}else{
		if($billID!=$invoiceNo){
			$queryBillItem = "UPDATE `billitem` SET `Bill ID` = '$invoiceNo' WHERE `billitem`.`Bill ID` = '$billID';";
			$query = $queryBill.$queryBillItem;
			$results = mysqli_multi_query($connection, $query);
		}
		else{
			$results = mysqli_query($connection, $queryBill);	
		}	
	}
	
	if($results){
		echo json_encode($result[]= array(['result'=>'1']));
		exit;
	}else{
		echo json_encode($result[]= array(['result'=>mysqli_errno($connection)]));
	   exit;
	}
	
  ?>