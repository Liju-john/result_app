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
$rowid=$_POST['rowid'];

$con -> autocommit(FALSE);
$insertQuery="insert into `kpsbspin_master`.`deleted_students` (rowid,admno,sname,fname,mname,dob,gen,branch,stat,cat,mobileno,transfer_info,rte) (select rowid,admno,sname,fname,mname,dob,gen,branch,stat,cat,mobileno,transfer_info,rte from `kpsbspin_master`.`studmaster`
 where rowid='$rowid')";
$deleteStudMasterQuery="delete from `kpsbspin_master`.`studmaster` where rowid='$rowid'";
$deleteCurrentSessionQuery="delete from `$current_db`.`session_tab` where rowid='$rowid'";
$r3=$con->query($insertQuery);
$r2=$con->query($deleteStudMasterQuery);
$r1=$con->query($deleteCurrentSessionQuery);
    if($r1&&$r2&&$r3)
    {
      if($con->commit())
      {
        echo "Student deleted";
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
?>