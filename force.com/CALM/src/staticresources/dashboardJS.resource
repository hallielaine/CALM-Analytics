function sendUserMessage(message)
{
	if (!isAndroid()) {
    	document.getElementById("messages").innerHTML = message;
    }
}

function isAndroid()
{
	var ua = navigator.userAgent.toLowerCase();
	var isAndroid = ua.indexOf("mobile");
	var isTablet = ua.indexOf("android");
	return isAndroid >= 0 || isTablet >= 0;
}