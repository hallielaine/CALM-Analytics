package com.localytics.android;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.localytics.android.LocalyticsSession.SessionHandler;
import com.localytics.android.LocalyticsSession.UploadHandler;

public class LocalyticsSessionTest extends android.test.AndroidTestCase {

   private LocalyticsSession metricsCollector;
   private long testStartTime;

   @Override
   public void setUp() {
      metricsCollector = new LocalyticsSession(getContext(), "unit_test");

      // wait until the LocalyticsSession is initialized
      while (metricsCollector.mSessionHandler.hasMessages(SessionHandler.MESSAGE_INIT)) {
    	  try {
    		  Thread.sleep(100);
    	  }
    	  catch (InterruptedException e) {
    		  e.printStackTrace();
    	  }
      }
      
      final Map<String, String> attrs = new HashMap<String, String>();
      attrs.put("Attr1 Key", "Attr1 Value");
      attrs.put("Attr2 Key", "Attr2 Value");
      
      testStartTime = System.currentTimeMillis();
      
      metricsCollector.open();
      metricsCollector.tagEvent("Test Event 1");
      metricsCollector.tagEvent("Test Event 2", attrs);
      metricsCollector.tagScreen("Test Screen 1");
      metricsCollector.tagScreen("Test Screen 2");
      metricsCollector.close();
      metricsCollector.upload();
      
      /* wait until all of the requests (tagEvent, upload, etc.) are handled */
      while (metricsCollector.mSessionHandler.hasMessages(SessionHandler.MESSAGE_UPLOAD) || 
             metricsCollector.mSessionHandler.hasMessages(SessionHandler.MESSAGE_CLOSE) || 
             metricsCollector.mSessionHandler.hasMessages(SessionHandler.MESSAGE_TAG_EVENT) || 
             metricsCollector.mSessionHandler.hasMessages(SessionHandler.MESSAGE_TAG_SCREEN) || 
             metricsCollector.mSessionHandler.hasMessages(SessionHandler.MESSAGE_OPEN) || 
             metricsCollector.mSessionHandler.hasMessages(SessionHandler.MESSAGE_INIT))
      {
         // wait one second then check again to see if there are still requests
         try {
            Thread.sleep(1000);
         } 
         catch (InterruptedException e) {
            e.printStackTrace();
         }
      }
   }
   
   @Override
   public void tearDown() {
      /* clear the database */
      UploadHandler.deleteBlobsAndSessions(LocalyticsProvider.getInstance(getContext(), "unit_test"));
   }

   public void testPerformOAuth() {
      try {
         assertTrue(metricsCollector.mSessionHandler.mUploadHandler.performOAuth());
      } catch (Exception e) {
         fail("Exception caught.");
      }
   }
   
   public void testCovertDatabaseToJSON() throws InterruptedException, JSONException {
      
      /* get the JSON representation of the local database */
      final JSONObject json = metricsCollector.mSessionHandler.mUploadHandler.convertDatabaseToJson();
      
      final JSONArray sessions = json.getJSONArray("sl");
      final JSONArray sessionEnds = json.getJSONArray("sel");
      final JSONArray actions = json.getJSONArray("al");
      final JSONArray eventAttrs = json.getJSONArray("eal");

      /* Testing Sessions */
      final JSONObject session = sessions.getJSONObject(0);
      final long sessionTime = session.getLong("st__c");
      final String sessionId = session.getString("u__c");
      final long currTime = System.currentTimeMillis();
      /* Check that the session time is within a valid range */
      assertTrue(testStartTime < sessionTime); // after the test started
      assertTrue(currTime > sessionTime);      // before the current time
      
      /* Testing Events and Screens */
      
      /* Test Event 1 */
      JSONObject action = actions.getJSONObject(0);      
      String dataType = action.getString("dt__c");
      String actionSessionId = action.getString("su__c");
      String actionName = action.getString("n__c");
      long actionTime = action.getLong("ct__c");
      assertTrue(dataType.equals("e"));              // correct action type
      assertTrue(actionName.equals("Test Event 1")); // correct name
      assertTrue(testStartTime < actionTime);        // after the test started
      assertTrue(currTime > actionTime);             // before the current time
      assertTrue(sessionId.equals(actionSessionId)); // correct session id
      
      /* Test Event 2 */
      action = actions.getJSONObject(1);      
      dataType = action.getString("dt__c");
      actionSessionId = action.getString("su__c");
      actionName = action.getString("n__c");
      actionTime = action.getLong("ct__c");
      assertTrue(dataType.equals("e"));              // correct action type
      assertTrue(actionName.equals("Test Event 2")); // correct name
      assertTrue(testStartTime < actionTime);        // after the test started
      assertTrue(currTime > actionTime);             // before the current time
      assertTrue(sessionId.equals(actionSessionId)); // correct session id
      
      /* Test Screen 1 */
      action = actions.getJSONObject(2);      
      dataType = action.getString("dt__c");
      actionSessionId = action.getString("su__c");
      actionName = action.getString("n__c");
      actionTime = action.getLong("ct__c");
      assertTrue(dataType.equals("s"));               // correct action type
      assertTrue(actionName.equals("Test Screen 1")); // correct name
      assertTrue(testStartTime < actionTime);         // after the test started
      assertTrue(currTime > actionTime);              // before the current time
      assertTrue(sessionId.equals(actionSessionId));  // correct session id
      
      /* Test Screen 2 */
      action = actions.getJSONObject(3);      
      dataType = action.getString("dt__c");
      actionSessionId = action.getString("su__c");
      actionName = action.getString("n__c");
      actionTime = action.getLong("ct__c");
      assertTrue(dataType.equals("s"));               // correct action type
      assertTrue(actionName.equals("Test Screen 2")); // correct name
      assertTrue(testStartTime < actionTime);         // after the test started
      assertTrue(currTime > actionTime);              // before the current time
      assertTrue(sessionId.equals(actionSessionId));  // correct session id

   }
   
   
}
