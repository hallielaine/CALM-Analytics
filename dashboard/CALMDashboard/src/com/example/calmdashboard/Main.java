package com.example.calmdashboard;

import java.util.LinkedList;
import java.util.TreeMap;

import android.app.Activity;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebSettings.ZoomDensity;

public class Main extends Activity {
	private WebView wv;
	private LinkedList<String> history;
	private String homepage = "https://c.na11.visual.force.com/apex/android_homepage";
	
	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		history = new LinkedList<String>();
		setContentView(R.layout.activity_main);
		wv = (WebView)findViewById(R.id.my_webview);
		wv.getSettings().setJavaScriptEnabled(true);
		wv.setWebViewClient(new WebViewClient() {
		@Override
		public boolean shouldOverrideUrlLoading(WebView view, String url) {
			view.loadUrl(url);
			return true;
		}
		
		@Override
		public void onPageFinished (WebView view, String url) {
			// Once a page has finished loading, if it is has been visited
			// before, the user has pressed back and we have reloaded this page.
			// Otherwise, it is a new click so add it to the history.
			if (history.contains(url)) {
				int loadedPageIndex = history.indexOf(url);
				for (int i = 0; i < history.size()-loadedPageIndex; i++) {
				  history.removeLast();
				}
			}
			else {
				history.add(url);
			}
			
			// If you're at the homepage, you can't go back any further so
			// clear the history
			if (url.equals(homepage)) {
				history.clear();
			}
		}
		});
	}
	
	@Override
	public void onResume(){
		wv.loadUrl(homepage);
	    super.onResume();
	}
		
	@Override
    public void onBackPressed() {
		if (history.isEmpty()) {
			onResume();
		}
		else {
			if (history.size() >= 2) 
				wv.loadUrl(history.get(history.size() - 2));
			else
				wv.loadUrl(homepage);
		}
	}
}