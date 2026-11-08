package com.leopisces.growth;

import android.os.Bundle;
import android.webkit.WebView;

import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 清一次 WebView 缓存，避免旧 JS 资源被缓存后继续渲染旧界面
        try {
            WebView wv = this.bridge.getWebView();
            wv.clearCache(true);
            wv.clearHistory();
        } catch (Exception ignored) {
        }
    }
}
