<?php
header("Access-Control-Allow-Origin: *");
$servername = "localhost";
$username = "kpsbilas_result";
$password = "result";
$dbname="kpsbilas_s2020";
$con=new mysqli($servername, $username, $password, $dbname);
if ($con->connect_error)
 {
  die("Connection failed: " . $con->connect_error);
}
$cname=$_POST['cname'];

$searchQuery="select * from report_i_v_term1 where cname='V' and rollno in ('5101','5102')and branch=1";
$result=$con->query($searchQuery);
$data = [];
$response=[];
$i=0;
while($row=$result->fetch_assoc())
{
  $response[]=$row;
}

echo json_encode($response);
?>