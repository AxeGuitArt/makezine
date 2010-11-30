// This script writes a simple log file for a
<?php
   $fn = "sensor_log.txt";
   if (file_exists($fn)) {
      //The file exists already, so append the new data to the end
      $fh = fopen($fn, 'a') or die("UGH");
   }
   //Fetch the data from the query string
   $time = $date = date('d-m-Y H:i:s T', time());;
   $face_count = $_GET["face_count"];
   $interval = $_GET["interval"];
   $room_name = $_GET["room_name"];
   //Make an array
   $l = array($time, $room_name, $face_count, $interval);
   //Append as a tab delimited record
   fwrite($fh, join("\t", $l)."\n");
   fclose($fh);
   echo "OK";
?>
