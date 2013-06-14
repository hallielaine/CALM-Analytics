function sendUserMessage(message)
{
    parent.document.getElementById("messages").innerHTML = message;
}

function sendNoDataMessage()
{
    sendUserMessage("We're sorry, but there's no data available for this graph.");
}
