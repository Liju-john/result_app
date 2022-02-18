<?php
$servername = "localhost";
$username = "kpsbilas_result";
$password = "result";
$dbname="kpsbilas_s2020";
// Create connection
// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
echo"<html>";
$cnamesql = "select distinct cname,section from nominal where branch=1 and section not in(' ') order by cno,section";
$result = $conn->query($cnamesql);
echo "<FONT COLOR='RED'><b>KONI</b></FONT>";
while($row=$result->fetch_assoc())
{
    echo"<table border=2 bordercolor='blue'><tr><td colspan=2><b>".$row['cname']."   ".$row['section']."</b></td></tr>";
    $sql="select session_status,count(session_status) as 'count' from nominal where branch=1 and cname='{$row['cname']}' 
    and section='{$row['section']}' group by session_status";
    $res=$conn->query($sql);
    while($r=$res->fetch_assoc())
    {
        echo"<tr><td>".$r['session_status']."</td><td>".$r['count']."</td></tr>";
    }
    echo"</table>";
    echo"<br>";
}
$cnamesql = "select distinct cname,section from nominal where branch=2 and section not in(' ') order by cno,section";
$result = $conn->query($cnamesql);
echo "<FONT COLOR='RED'><b>NARMADA NAGAR</b></FONT>";
while($row=$result->fetch_assoc())
{
    echo"<table border=2 bordercolor='blue'><tr><td colspan=2><b>".$row['cname']."   ".$row['section']."</b></td></tr>";
    $sql="select session_status,count(session_status) as 'count' from nominal where branch=2 and cname='{$row['cname']}' 
    and section='{$row['section']}' group by session_status";
    $res=$conn->query($sql);
    while($r=$res->fetch_assoc())
    {
        echo"<tr><td>".$r['session_status']."</td><td>".$r['count']."</td></tr>";
    }
    echo"</table>";
    echo"<br>";
}
$cnamesql = "select distinct cname,section from nominal where branch=3 and section not in(' ') order by cno,section";
$result = $conn->query($cnamesql);
echo "<FONT COLOR='RED'><b>SAKRI</b></FONT>";
while($row=$result->fetch_assoc())
{
    echo"<table border=2 bordercolor='blue'><tr><td colspan=2><b>".$row['cname']."   ".$row['section']."</b></td></tr>";
    $sql="select session_status,count(session_status) as 'count' from nominal where branch=3 and cname='{$row['cname']}' 
    and section='{$row['section']}' group by session_status";
    $res=$conn->query($sql);
    while($r=$res->fetch_assoc())
    {
        echo"<tr><td>".$r['session_status']."</td><td>".$r['count']."</td></tr>";
    }
    echo"</table>";
    echo"<br>";
}
$cnamesql = "select distinct cname,section from nominal where branch=4 and section not in(' ') order by cno,section";
$result = $conn->query($cnamesql);
echo "<FONT COLOR='RED'><b>KOYLA VIHAR</b></FONT>";
while($row=$result->fetch_assoc())
{
    echo"<table border=2 bordercolor='blue'><tr><td colspan=2><b>".$row['cname']."   ".$row['section']."</b></td></tr>";
    $sql="select session_status,count(session_status) as 'count' from nominal where branch=4 and cname='{$row['cname']}' 
    and section='{$row['section']}' group by session_status";
    $res=$conn->query($sql);
    while($r=$res->fetch_assoc())
    {
        echo"<tr><td>".$r['session_status']."</td><td>".$r['count']."</td></tr>";
    }
    echo"</table>";
    echo"<br>";
}
echo "</html>";
$conn->close();
?>