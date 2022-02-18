<?php
$servername = "localhost";
$username = "kpsbspin_result";
$password = "result123#";
$dbname="kpsbspin_master";
$con=new mysqli($servername, $username, $password, $dbname);
if ($con->connect_error)
 {
  die("Connection failed: " . $con->connect_error);
}

$current_db=$_POST['current_db'];
$next_db=$_POST['next_db'];
$searchColumn=$_POST['searchBy'];
$searchKeyword=$_POST['searchKeyword'];
$searchQuery="select rowid,sname,fname,mname,admno,cname,section from `$current_db`.`nominal` where $searchColumn like '%$searchKeyword%'";
$result=$con->query($searchQuery);
$response=array();
while($row=$result->fetch_array())
{
  array_push($response,array("rowid"=>$row[0],"sname"=>$row[1],"fname"=>$row[2],"mname"=>$row[3],"admno"=>$row[4],"cname"=>$row[5],"section"=>$row[6]));
}
echo json_encode($response);
$con->close();
?>