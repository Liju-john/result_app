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
$cname=$_POST['cname'];
$branch=$_POST['branch'];
$rollNo=$_POST['rollNo'];
$section=$_POST['section'];
$current_db=$_POST['current_db'];
$cno=$_POST['cno'];


$checkForRollNoDuplicacy="select count(*) from `$current_db`.`nominal` where rollno='$rollNo' and branch='$branch' and rowid not in('$rowid') and rollno not in('',' ')";
 $result=$con->query($checkForRollNoDuplicacy);
$rows=$result->fetch_row();
if($rows[0]>0)//check for duplicate rollno
{
  echo "RollNo already taken!!!";
  return;
}
else
{
  //checking for previous status is TC or not
  $tc_delete_query="delete from `kpsbspin_master`.`tcdetail` where rowid='$rowid'";
  $update_studmasterquery="update `kpsbspin_master`.`studmaster` set stat='' where rowid='$rowid' ;";
  $result=$con->query("Select session_status from `$current_db`.`session_tab` where rowid='$rowid'");
  $rows=$result->fetch_row();
  $previous_status=$rows[0];
  if($previous_status=="TC after term1")
  {
    $r1=$con->query($tc_delete_query);
    $r2=$con->query($update_studmasterquery);
    if($r1==false|| $r2==false)
    {
      echo "Error in changing TC!!!";
      return;
    }
  }
  if($previous_status=='Promote and TC'||$previous_status=='Failed and TC')
  {
    $session_status=$previous_status;
    if($section=='Not active')
    {
      echo 'NA Error';
      return;
    }
    $updateSession_tab="update `$current_db`.`session_tab` set rollno='$rollNo',section='$section' where rowid='$rowid'";
  }
  else
  {
    if($section=='Not active')
      {
        $session_status=$section;
        $section='';
        $rollNo='';
        $updateSession_tab="update `$current_db`.`session_tab` set rollno='$rollNo',section='$section',session_status='$session_status' where rowid='$rowid'";
      }
      else
      {
        $updateSession_tab="update `$current_db`.`session_tab` set rollno='$rollNo',section='$section',session_status='Not yet promoted' where rowid='$rowid'";
      }
    
  }
  $q1=$con->query($updateSession_tab);
  if($q1 &&$session_status=='Not active')
  {
    if($con->commit())
    {
      echo 'Updated successfully!!!';
    }
    else
    {
      echo 'Error in assigning not active!!!';
    }
    return;
  }

  $checkForUpdateQuery="select count(*) from `$current_db`.`vi_viii` where rowid='$rowid'";
  $result=$con->query($checkForUpdateQuery);
  $rows=$result->fetch_row();
  $count_flag=$rows[0];
  $getSubjectList="select subname,subno from `$current_db`.`subjectList` where classflag like '%6to8%'";
  
  if($count_flag==7)
  {
    $update_vi_viii="update `$current_db`.`vi_viii` set rollno='$rollNo',branch='$branch' where rowid='$rowid'";
    $update_vi_viii_coscho="update `$current_db`.`vi_viiicoscho` set rollno='$rollNo',branch='$branch' where rowid='$rowid'";
    $r1=$con->query($update_vi_viii);
    $r2=$con->query($update_vi_viii_coscho);
    if(!($r1&&$r2))
    {
      echo 'query error';
      return;
    }
  }
  else
  {
    $result=$con->query($getSubjectList);
    while($row=$result->fetch_array())
    {
        $q.$row[1]="insert into `$current_db`.`vi_viii`(rowid,rollno,subno,subname,branch) values('$rowid','$rollNo','$row[1]','$row[0]',$branch)";
        $query=$query."\n".$q.$row[1];
        if(!($con->query($q.$row[1])))
        {
          echo 'query error';
          return;
        }
    }
    if(!($con->query("insert into `$current_db`.`vi_viiicoscho` (rowid,rollno,branch) values('$rowid','$rollNo','$branch')")))
    {
     echo 'query error';
      return;
    }
    
  }
  if($q1)
  {
      if($con->commit())
      {
        echo "Updated successfully!!!";
      }
      elseif($con->rollback())
      {
        echo "Error in rollno updation!!!";
      }
  }
  else{
    echo "Error in server!!!";
  }
}
?>