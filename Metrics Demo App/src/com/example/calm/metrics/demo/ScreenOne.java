package com.example.calm.metrics.demo;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;

import com.example.calm.metrics.demo.R;
import com.localytics.android.LocalyticsSession;


public class ScreenOne extends Activity {
   
   private final static String EVENT_A_BUTTON = "'A' pressed";
   private final static String EVENT_B_BUTTON = "'B' pressed";
   private final static String EVENT_C_BUTTON = "'C' pressed";
   private final static String EVENT_SCREEN_TWO_BUTTON = "'Screen Two' pressed";
   private final static String SCREEN_ONE = "Screen one";
   private LocalyticsSession metricsCollector;
   
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_screen_one);
        
        // Metrics
        this.metricsCollector = new LocalyticsSession(this.getApplicationContext(), "a0CG000000H6kUSMAZ");
        this.metricsCollector.open();
        this.metricsCollector.upload();
        this.metricsCollector.tagScreen(SCREEN_ONE);
    }
    
    /** Called when the user clicks the A button */
    public void buttonAClicked(View view) {
       this.metricsCollector.tagEvent(EVENT_A_BUTTON);
    }
    
    /** Called when the user clicks the B button */
    public void buttonBClicked(View view) {
       this.metricsCollector.tagEvent(EVENT_B_BUTTON);
    }

    /** Called when the user clicks the C button */
    public void buttonCClicked(View view) {
       this.metricsCollector.tagEvent(EVENT_C_BUTTON);
    }
    
    /** Called when the user clicks the Screen Two button */
    public void buttonScreenTwoClicked(View view) {
       this.metricsCollector.tagEvent(EVENT_SCREEN_TWO_BUTTON);
       Intent intent = new Intent(this, ScreenTwo.class);
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
        getMenuInflater().inflate(R.menu.activity_screen_one, menu);
        return true;
    }
}
