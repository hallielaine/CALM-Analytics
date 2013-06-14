package com.localytics.android;

import org.json.JSONObject;

public class JSONObjectWrapper {
   
   private JSONObject json;
   private String type;
   
   public JSONObjectWrapper(JSONObject json, String type) {
      this.setJson(json);
      this.setType(type);
   }

   public void setJson(JSONObject json) {
      this.json = json;
   }

   public JSONObject getJson() {
      return json;
   }

   public void setType(String type) {
      this.type = type;
   }

   public String getType() {
      return type;
   }   
}
