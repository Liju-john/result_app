<?php
$current_db=$_POST['current_db'];
$next_db=$_POST['next_db'];
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
$cname=$_POST['cname'];
$branch=$_POST['branch'];


$servername = "localhost";
$username = "kpsbspin_result";
$password = "result123#";
$dbname="kpsbspin_master";
$con=new mysqli($servername, $username, $password, $dbname);
if ($con->connect_error)
 {
  die("Connection failed: " . $con->connect_error);
}
$con -> autocommit(FALSE);
$insertStudmasterQuery="insert into `kpsbspin_master`.`studmaster`(admno,sname,mname,fname,dob,cat,caste,gen,mobileno,rte,branch)
values('$admno','$sname','$mname','$fname','$dob','$cat','$caste','$gen','$mobileno','$rte',$branch)";
$getRowidQuery="select rowid from `kpsbspin_master`.`studmaster` where sname='$sname' and mname='$mname' and fname='$fname' and
dob='$dob' and gen='$gen' and mobileno='$mobileno' and branch='$branch'";
$q1=$con->query($insertStudmasterQuery);//query to insert nominal

$result=$con->query($getRowidQuery);//to get inserted row id;
$rows=$result->fetch_row();
$rowid=$rows[0];

$getcnoQuery="Select cno from `kpsbspin_master`.`classdetail` where cname='$cname'";// to get the cno
$result=$con->query($getcnoQuery);
$rows=$result->fetch_row();
$cno=$rows[0];

$insertsession_tab="insert into `$current_db`.`session_tab` (rowid,cno,branch) values('$rowid','$cno','$branch')";
$q2=$con->query($insertsession_tab);// to insert in session_tab

if($q1&&$q2)
{
  if($con->commit())
      {
        echo "Student added successfully";
      }
      else
      {
        echo $con->error;
      }
}
else
{
  if($con->rollback())
      {
        echo "Query Error";
      }
      else
        {
          echo $con->error;
        }
}
//echo "error";
$con->close();
?>