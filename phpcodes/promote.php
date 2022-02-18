<?php
 //post data
 $rowid=$_POST['rowid'];
 $oldcno=$_POST['cno'];
 $status=$_POST['newstatus'];
 $branch=$_POST['branchno'];
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

// previous status
$result=$con->query("Select session_status from `$current_db`.`session_tab` where rowid='$rowid'");//change
$rows=$result->fetch_row();
$previous_status=$rows[0];
if($previous_status=="Not active")
{
  echo 'Student not active';
  return;
}
if($previous_status==$status)
{
    echo "Already promoted!!!";
    return;
}

if(($oldcno>=13&&$oldcno<=15)||($oldcno>=1&&$oldcno<=11))
{
    if($oldcno==15)
    {
        $newcno=13;
    }
    elseif($oldcno==14)
    {
        $newcno=1;
    }
    else
    {
        $newcno=$oldcno+1;
    }   
}

// queries
$update_old_sessiontabquery="update `$current_db`.`session_tab`  set session_status='$status' where rowid='$rowid' ;";
$insert_new_sessiontab_query="insert into `$next_db`.`session_tab` (cno,rowid,branch)values($newcno,$rowid,$branch)";
$tc_delete_query="delete from `kpsbspin_master`.`tcdetail` where rowid='$rowid'";
$update_studmasterquery="update `kpsbspin_master`.`studmaster` set stat='' where rowid='$rowid' ;";
$update_new_sessiontabquery="update `$next_db`.`session_tab` set cno=$newcno where rowid='$rowid'";
if($previous_status=="Not yet promoted")
{
    $r1=$con->query($update_old_sessiontabquery);
    $r2=$con->query($insert_new_sessiontab_query);
    if($r1&&$r2)
    {
      if($con->commit())
        {
          echo "Promoted!!!";
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
elseif($previous_status=="Promote and TC"||$previous_status=="Failed and TC")
{
  $r1=$con->query($tc_delete_query);
  $r2=$con->query($update_studmasterquery);
  $r3=$con->query($update_old_sessiontabquery);
  $r4=$con->query($insert_new_sessiontab_query);  
  if($r1&&$r2&&$r3&&$r4)
    {
      if($con->commit())
        {
          echo "TC deleted and Promoted!!!";
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
elseif($previous_status=="Repeat")
{
   $r1=$con->query($update_old_sessiontabquery);
   $r2=$con->query($update_new_sessiontabquery);
   if($r1&&$r2)
    {
      if($con->commit())
        {
          echo "Promoted!!!";
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
?>