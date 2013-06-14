var instanceUrl:String = "";
var accessToken:String = "";

function getAccessToken():void 
{

   $.post("https://login.salesforce.com/services/oauth2/token", 
   { 
      "grant_type" : "password"
      "client_id" : "3MVG98XJQQAccJQcR1oskEGV9V.GEMHNvCJsTe37wO.3v.Yj14wvz61r8YxuKLM_rhYYeoSKYb7C32udVYA6U"
      "client_secret" : "6242913928381552240"
      "username" : "calmcoders@calpoly.edu"
      "password" : "rtalm20129WQAk0HEmPZLnz47bZaM1w0b"
   },
   function(data):void {
      instanceUrl = data.instance_url + "/services/apexrest/GetEventRecord/";
      accessToken = data.access_token;
   }, 
   "json");
}

function parseEventRecord(data):Object
{
   var eventNames = new Array();
   var eventCounts = new Array();
   var results:Object = new Object();

   for(event in data)
   {
      eventNames.push(event.name);  
      eventCounts.push(event.count);
   }
   
   results.names  = eventNames;
   results.counts = eventCounts;
   
   return results;
}

function getEventRecord(startTime:String="2011-03-22T08:15:18.000Z", endTime:String="2013-03-22T08:15:18.000Z", appKey:String="1"):Object
{
   var result:Object = new Object();

   if(instanceUrl == "" || accessToken == "") 
   {
      getAccessToken();
   }
      
   $.post(instanceUrl,
   { 
      "access_token" : accessToken,   
      "st" : startTime,
      "et" : endTime,
      "appKey" : appKey
   },
   function(data):void {
      var parsed:Object = parseEventRecord(data);
      result.names  = parsed.names;
      result.counts = parsed.counts;
   },
   "json");
   
   return result;
}
