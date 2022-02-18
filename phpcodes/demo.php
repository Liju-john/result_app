<?php
$servername = "localhost";
$username = "kpsbilas_result";
$password = "result";
$dbname="kpsbspin_master";
$con=new mysqli($servername, $username, $password, $dbname);
if ($con->connect_error) {
  die("Connection failed: " . $con->connect_error);
}
$con -> autocommit(FALSE);
$flag=true;
//mysqli_autocommit($con, false);
$res1=$con->query("update tcdetail set tcno='245' where rowid='11'");
if(!$res1)
	$flag=false;
$res2=$con->query("insert into tcdetail (rowid)values('15')");
if(!$res2)
	$flag=false;
if(!$flag)
{
	$con->rollback();
}
else
{
	$con->commit();
}
$con->close();
return;
?>