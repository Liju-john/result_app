<?php
$servername = "localhost";
$username = "kpsbspin_result";
$password = "result123#";
$dbname="kpsbspin_master";
$con=new mysqli($servername, $username, $password, $dbname);
if ($con->connect_error) {
  die("Connection failed: " . $con->connect_error);
}
$rowid=$_POST['rowid'];
$sname=$_POST['sname'];
$fname=$_POST['fname'];
$mname=$_POST['mname'];
$admno=$_POST['admno'];
$rte=$_POST['rte'];
$mobileno=$_POST['mobileno'];
$dob=$_POST['dob'];
$gen=$_POST['gen'];
$cat=$_POST['cat'];
$caste=$_POST['caste'];
//$con->query("call updateNominal('$rowid','$sname','$fname','$mname','$admno','$rte','$mobileno','dob','$gen','$cat','caste')");
$con->query("update studmaster set sname='$sname',mname='$mname', fname='$fname',admno='$admno',rte='$rte',mobileno='$mobileno',dob='$dob',gen='$gen',cat='$cat',caste='$caste' where rowid='$rowid'");
if(mysqli_affected_rows($con)==0)
{
	echo "No changes made!!!!";
}
elseif(mysqli_affected_rows($con)>0)
{
	echo "Data updated!!!!";
}
else
{
echo "error";
}
$con->close();
return;
?>