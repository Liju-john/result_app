<?php

//post data
$rowid=$_POST['rowid'];
$tcdat=$_POST['tcdate'];
$tcno=$_POST['tcno'];
$cname=$_POST['cname'];
$tcreaon=$_POST['tcreason'];
$cno=$_POST['cno'];
$status=$_POST['newstatus'];
$current_db=$_POST['current_db'];
$next_db=$_POST['next_db'];



$servername = "localhost";
$username = "kpsbspin_result";
$password = "result123#";
$dbname="kpsbspin_master";
$con=new mysqli($servername, $username, $password, $dbname);
if ($con->connect_error) {
  die("Connection failed: " . $con->connect_error);
}
$con -> autocommit(FALSE);


//checking previous status
$result=$con->query("Select session_status from `$current_db`.`session_tab` where rowid='$rowid'");
$rows=$result->fetch_row();
$previous_status=$rows[0];



$tccheckquery="select count(*) from `kpsbspin_master`.`tcdetail` where rowid='$rowid'";
$tcinsertquery="insert into `kpsbspin_master`.`tcdetail` values('$rowid','$tcdat','$tcno','TC taken after $cname','$tcreaon','$cno');";
$tcdeletequery="delete from `kpsbspin_master`.`tcdetail` where rowid='$rowid' ;";
$update_studmasterquery="update `kpsbspin_master`.`studmaster` set stat='TC' where rowid='$rowid' ;";
$update_sessiontabquery="update `$current_db`.`session_tab`  set session_status='$status' where rowid='$rowid' ;";
if($previous_status=="Not yet promoted"||$previous_status=="Promote and TC"||$previous_status=="Failed and TC"||$previous_status=="Not active")
{
    $result=$con->query($tccheckquery);
    $count=$result->fetch_row();
    if($count[0]>=0)
    {
     $r1=$con->query($tcdeletequery);   
    }
   $r2=$con->query($tcinsertquery);
   $r3=$con->query($update_studmasterquery);
   $r4=$con->query($update_sessiontabquery);
   if($r1&&$r2&&$r3&&$r4)
    {
      if($con->commit())
        {
           // echo "update `$current_db`.`session_tab`  set session_status='$status' where rowid='$rowid'";
          echo "Data saved!!!";
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
  }
elseif($previous_status=="Repeat"||$previous_status=="Promoted")
{
    $r4=$con->query("delete from `$next_db`.`session_tab` where rowid='$rowid'");
    $r3=$con->query($update_sessiontabquery);
    $r2=$con->query($update_studmasterquery);
    $r1=$con->query($tcinsertquery);
    if($r1&&$r2&&$r3&&$r4)
    {
      if($con->commit())
      {
        echo "TC Updated!!!";
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
}
$con->close();
return;
?>