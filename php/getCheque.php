
 <?php 

  include("conn.php");
  header("Access-Control-Allow-Origin: *");

  $query = "SELECT * FROM `cheque`";
  
$queryResult = $connection->
      query($query);
	  
$result = array();

  while ($fetchdata=$queryResult->fetch_assoc()) {
      $result[] = $fetchdata;
  }	
  echo json_encode($result);
 ?>