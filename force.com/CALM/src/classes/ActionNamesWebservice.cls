@RestResource(urlMapping='/ActionNamesWebservice/*')
global class ActionNamesWebservice {
   
    @HttpPost
    global static Map<String, List<String>> post(String appKey)
    {
   	   return FunnelsWebservice.getActionNames(appKey);
    }
}