<?php

$servername = "localhost";
$username = "kpsbspin_result";
$password = "result123#";
$dbname="kpsbspin_master";
$con=new mysqli($servername, $username, $password, $dbname);
if ($con->connect_error) {
  die("Connection failed: " . $con->connect_error);
}
$con -> autocommit(FALSE);


//post data
$rowid=$_POST['rowid'];
$tcdat=$_POST['tcdate'];
$tcno=$_POST['tcno'];
$cname=$_POST['cname'];
$tcreaon=$_POST['tcreason'];
$cno=$_POST['cno'];
$sessionStatus=$_POST['sessionStatus'];
$current_db=$_POST['current_db'];
$previous_db=$_POST['previous_db'];

$update_studmasterquery="update `kpsbspin_master`.`studmaster` set stat='$sessionStatus' where rowid='$rowid';";
$tccheckquery="select count(*) from `kpsbspin_master`.`tcdetail` where rowid='$rowid'";
$tcdeletequery="delete from `kpsbspin_master`.`tcdetail` where rowid='$rowid' ;";
if($sessionStatus=='TC')
{
    $result=$con->query("Select cname,cno from `$previous_db`.`nominal` where rowid='$rowid'");
    $previousCname=$result->fetch_row();
    $r1=$con->query("delete from `$current_db`.`session_tab` where rowid='$rowid'");
    $update_sessiontabquery="update `$previous_db`.`session_tab`  set session_status='Promote and TC' where rowid='$rowid';";
    $tcinsertquery="insert into `kpsbspin_master`.`tcdetail` values('$rowid','$tcdat','$tcno','TC taken after {$previousCname[0]}','$tcreaon','{$previousCname[1]}');";
    $r2=$con->query($update_sessiontabquery);
    if($r1==false||$r2==false)
    {
       echo 'error';
        return;
    }
}
else if($sessionStatus=='TC after term1')
{
    $tcinsertquery="insert into `kpsbspin_master`.`tcdetail` values('$rowid','$tcdat','$tcno','TC taken during $cname','$tcreaon','$cno');";
    $update_sessiontabquery="update `$current_db`.`session_tab`  set session_status='TC after term1' where rowid='$rowid';";
    $r2=$con->query($update_sessiontabquery);
    if($r2==false)
    {
        echo 'error'; 
        return;
    }
}
    $result=$con->query($tccheckquery);
    $count=$result->fetch_row();
    if($count[0]>=0)
    {
     $r1=$con->query($tcdeletequery);  
     if($r1==false)
    {
        echo 'error'; 
        return;
    } 
    }
    $r2=$con->query($tcinsertquery);
    $r3=$con->query($update_studmasterquery);
    if($r2==false||$r3==false)
    {
        echo 'error';
        return;
    }
    if($con->commit())
        {
          echo "TC Updated!!!!";
        }
        else
        {
          echo $con->error;
        }
?>