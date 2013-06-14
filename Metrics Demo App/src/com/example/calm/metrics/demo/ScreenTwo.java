package com.example.calm.metrics.demo;

import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;

import com.example.calm.metrics.demo.R;
import com.localytics.android.LocalyticsSession;


public class ScreenTwo extends Activity {
   
    private final static String EVENT_D_BUTTON = "'D' pressed";
    private final static String EVENT_SCREEN_ONE_BUTTON = "'Screen One' pressed";
    private final static String SCREEN_TWO = "Screen two";
    private final static String TEXT_FIELD = "text";
    private LocalyticsSession metricsCollector;
   
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_screen_two);
        
        // Metrics
        this.metricsCollector = new LocalyticsSession(this.getApplicationContext(), "a0CG000000H6kUSMAZ");
        this.metricsCollector.open();
        this.metricsCollector.upload();
        this.metricsCollector.tagScreen(SCREEN_TWO);
    }

    /** Called when the user clicks the D button */
    public void buttonDClicked(View view) {
       EditText editText = (EditText) findViewById(R.id.editText1);
       String message = editText.getText().toString();
       
       // no text, so tag the event without attributes
       if (message == null || message.equals(""))
          this.metricsCollector.tagEvent(EVENT_D_BUTTON);
       else {
          Map<String, String> attrs = new HashMap<String, String>();
          attrs.put(TEXT_FIELD, message);
          attrs.put("ATTR2", "2nd attr");
          
          this.metricsCollector.tagEvent(EVENT_D_BUTTON, attrs);
       }
    }
    
    /** Called when the user clicks the Screen One button */
    public void buttonScreenOneClicked(View view) {
       this.metricsCollector.tagEvent(EVENT_SCREEN_ONE_BUTTON);
       Intent intent = new Intent(this, ScreenOne.class);
       startActivity(intent);
    }
    
    public void onResume()
    {
       super.onResume();
       this.metricsCollector.open();
    }

    public void onPause()
    {
       super.onPause();
       this.metricsCollector.close();
       this.metricsCollector.upload();
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_screen_two, menu);
        return true;
    }

    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                NavUtils.navigateUpFromSameTask(this);
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

}
