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

$searchQuery="select rowid,sname,fname,mname,admno,cname,section,rollno,dob from nominal where cname='$cname' and branch=1 limit 40";
$result=$con->query($searchQuery);
$response=array();
while($row=$result->fetch_array())
{
  array_push($response,array("rowid"=>$row[0],"sname"=>$row[1],"fname"=>$row[2],"mname"=>$row[3],"admno"=>$row[4],"cname"=>$row[5],"section"=>$row[6],"rollno"=>$row[7],"dob"=>$row[8]));
}
echo json_encode($response);
$con->close();
?>