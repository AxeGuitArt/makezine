<?php

$mbox = imap_open("{imap.gmail.com:993/imap/ssl}INBOX", "address@gmail.com", "passw0rd")
      or die("can't connect: " . imap_last_error());

$status = imap_status($mbox, "{imap.gmail.com:993/imap/ssl}INBOX", SA_MESSAGES);
if ($status) {
  echo $status->messages;
}
?>