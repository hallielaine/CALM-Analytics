function sendUserMessage(message)
{
	if (isAndroid()) {
    	top.$('#messages').show();
        top.$('#androidframe').hide();
        top.document.getElementById("messages").innerHTML = message;
    }
    else {
    	document.getElementById("messages").innerHTML = message;
    }
}

function sendNoDataMessage()
{
  	sendUserMessage("We're sorry, but there's no data available for this graph.");
}

function isAndroid()
{
	var ua = navigator.userAgent.toLowerCase();
	var isAndroid = ua.indexOf("mobile");
	var isTablet = ua.indexOf("android");
	return isAndroid >= 0 || isTablet >= 0;
}