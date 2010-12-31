<?php
/*
	Snail Mail Push Alerts
	
	Server side PHP script for sending iPhone push alerts when this example.php
	is requested via HTTP by the Arduino.
	
	Adapted from ProwlPHP 0.3.1 by Mario Mueller: https://github.com/xenji/ProwlPHP
*/

require_once 'ProwlConnector.class.php';
require_once 'ProwlMessage.class.php';
require_once 'ProwlResponse.class.php';

$oProwl = new ProwlConnector();
$oMsg 	= new ProwlMessage();

try 
{
	$oProwl->setIsPostRequest(true);
	$oMsg->setPriority(2);
	$oMsg->addApiKey('b26ca3911867aa132a173aaf0f8e0d1d0f9023fa'); // Change to your API key from http://prowl.weks.net/ 
	$oMsg->setEvent('The mail has been delivered!');
	$oMsg->setApplication('Mailbox');
	$oResponse = $oProwl->push($oMsg);
	if ($oResponse->isError())
		print $oResponse->getErrorAsString();
	else
	{
		print "Sent. " . $oResponse->getRemaining() . " Messages left. (Resets at: " . date('Y-m-d H:i:s', $oResponse->getResetDate()) . ")" . PHP_EOL;
	}
}
catch (InvalidArgumentException $oIAE)
{
	print $oIAE->getMessage();
}
catch (OutOfRangeException $oOORE)
{
	print $oIAE->getMessage();
}

?>