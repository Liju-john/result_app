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
$tname=$_POST['tname'];
$tid=$_POST['tid'];
$tpwd=$_POST['tpwd'];
$con -> autocommit(FALSE);
$sql="insert into login (`id`,`pwd`,`name`)values('$tid','$tpwd','$tname')";
$q1=$con->query($sql);
if($q1)
{
    if($con->commit())
      {
        echo "Teacher added successfully";
        return;
      }
      else
      {
        echo $con->error;
      }
}
else{
    echo $con->error;
}
?>