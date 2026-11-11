#!/bin/bash
# Creates the Android WebView project for "تاجر جملة" — used by GitHub Actions.
set -e
PKG=com/nizar/tajerjomla
mkdir -p android/app/src/main/java/$PKG android/app/src/main/res/drawable android/app/src/main/res/drawable-anydpi-v26

cat > android/settings.gradle <<'EOF'
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositories { google(); mavenCentral() } }
rootProject.name = "TajerJomla"
include ':app'
EOF

cat > android/build.gradle <<'EOF'
plugins { id 'com.android.application' version '8.5.2' apply false }
EOF

cat > android/gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2g
EOF

cat > android/app/build.gradle <<'EOF'
plugins { id 'com.android.application' }
android {
    namespace 'com.nizar.tajerjomla'
    compileSdk 34
    defaultConfig {
        applicationId "com.nizar.tajerjomla"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
    buildTypes { release { minifyEnabled false } }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}
EOF

cat > android/app/src/main/AndroidManifest.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <application
        android:label="تاجر جملة"
        android:icon="@drawable/ic_launcher"
        android:supportsRtl="true"
        android:theme="@android:style/Theme.Material.Light.NoActionBar">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:configChanges="orientation|screenSize|keyboardHidden|screenLayout"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# App icon: teal background + white cart
cat > android/app/src/main/res/drawable/ic_launcher_fg.xml <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <group android:translateX="30" android:translateY="30" android:scaleX="2" android:scaleY="2">
        <path android:fillColor="#FFFFFF" android:pathData="M7,18c-1.1,0 -1.99,0.9 -1.99,2S5.9,22 7,22s2,-0.9 2,-2 -0.9,-2 -2,-2zM1,2v2h2l3.6,7.59 -1.35,2.45c-0.16,0.28 -0.25,0.61 -0.25,0.96 0,1.1 0.9,2 2,2h12v-2L7.42,15c-0.14,0 -0.25,-0.11 -0.25,-0.25l0.03,-0.12 0.9,-1.63h7.45c0.75,0 1.41,-0.41 1.75,-1.03l3.58,-6.49c0.08,-0.14 0.12,-0.31 0.12,-0.48 0,-0.55 -0.45,-1 -1,-1L5.21,4l-0.94,-2L1,2zM17,18c-1.1,0 -1.99,0.9 -1.99,2s0.89,2 1.99,2 2,-0.9 2,-2 -0.9,-2 -2,-2z"/>
    </group>
</vector>
EOF

cat > android/app/src/main/res/drawable/ic_launcher_bg.xml <<'EOF'
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#0F766E"/>
</shape>
EOF

cat > android/app/src/main/res/drawable-anydpi-v26/ic_launcher.xml <<'EOF'
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_bg"/>
    <foreground android:drawable="@drawable/ic_launcher_fg"/>
</adaptive-icon>
EOF

cat > android/app/src/main/res/drawable/ic_launcher.xml <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="48dp" android:height="48dp" android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="#0F766E" android:pathData="M12,0a12,12 0,1 1,0 24a12,12 0,1 1,0 -24z"/>
    <group android:translateX="5" android:translateY="5" android:scaleX="0.58" android:scaleY="0.58">
        <path android:fillColor="#FFFFFF" android:pathData="M7,18c-1.1,0 -1.99,0.9 -1.99,2S5.9,22 7,22s2,-0.9 2,-2 -0.9,-2 -2,-2zM1,2v2h2l3.6,7.59 -1.35,2.45c-0.16,0.28 -0.25,0.61 -0.25,0.96 0,1.1 0.9,2 2,2h12v-2L7.42,15c-0.14,0 -0.25,-0.11 -0.25,-0.25l0.03,-0.12 0.9,-1.63h7.45c0.75,0 1.41,-0.41 1.75,-1.03l3.58,-6.49c0.08,-0.14 0.12,-0.31 0.12,-0.48 0,-0.55 -0.45,-1 -1,-1L5.21,4l-0.94,-2L1,2zM17,18c-1.1,0 -1.99,0.9 -1.99,2s0.89,2 1.99,2 2,-0.9 2,-2 -0.9,-2 -2,-2z"/>
    </group>
</vector>
EOF

cat > android/app/src/main/java/$PKG/MainActivity.java <<'EOF'
package com.nizar.tajerjomla;

import android.app.Activity;
import android.content.ContentValues;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.print.PrintAttributes;
import android.print.PrintManager;
import android.provider.MediaStore;
import android.util.Base64;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;

public class MainActivity extends Activity {
    static final String SITE = "https://nizarmhadi15-maker.github.io/tajer-jomla/";
    static final int FILE_REQ = 11;
    WebView web;
    ValueCallback<Uri[]> fileCb;

    @Override
    protected void onCreate(Bundle saved) {
        super.onCreate(saved);
        getWindow().setStatusBarColor(Color.parseColor("#0F766E"));
        web = new WebView(this);
        setContentView(web);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setDatabaseEnabled(true);
        s.setCacheMode(WebSettings.LOAD_DEFAULT);
        web.addJavascriptInterface(new Bridge(), "Android");

        web.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView v, WebResourceRequest r) {
                String u = r.getUrl().toString();
                if (u.startsWith(SITE)) return false;
                openExternal(u);
                return true;
            }
            @Override
            public void onReceivedError(WebView v, WebResourceRequest r, WebResourceError e) {
                if (r.isForMainFrame()) {
                    v.loadDataWithBaseURL(null,
                        "<html dir='rtl'><body style='font-family:sans-serif;text-align:center;padding:60px 20px;color:#333'>"
                        + "<div style='font-size:60px'>📡</div><h2>لا يوجد اتصال بالإنترنت</h2>"
                        + "<p>تأكد من الإنترنت واضغط إعادة المحاولة</p>"
                        + "<button onclick=\"location.href='" + SITE + "'\" style='background:#0F766E;color:#fff;border:0;border-radius:10px;padding:14px 30px;font-size:18px'>إعادة المحاولة</button>"
                        + "</body></html>", "text/html", "UTF-8", null);
                }
            }
        });

        web.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onShowFileChooser(WebView v, ValueCallback<Uri[]> cb, FileChooserParams p) {
                if (fileCb != null) fileCb.onReceiveValue(null);
                fileCb = cb;
                try {
                    startActivityForResult(p.createIntent(), FILE_REQ);
                } catch (Exception ex) {
                    fileCb = null;
                    return false;
                }
                return true;
            }
        });

        if (saved != null) web.restoreState(saved);
        else web.loadUrl(SITE);
    }

    @Override
    protected void onSaveInstanceState(Bundle out) {
        super.onSaveInstanceState(out);
        web.saveState(out);
    }

    @Override
    protected void onActivityResult(int req, int res, Intent data) {
        super.onActivityResult(req, res, data);
        if (req == FILE_REQ && fileCb != null) {
            fileCb.onReceiveValue(WebChromeClient.FileChooserParams.parseResult(res, data));
            fileCb = null;
        }
    }

    @Override
    public void onBackPressed() {
        web.evaluateJavascript("(window.appBack && window.appBack()) ? 'yes' : 'no'", v -> {
            if (v != null && v.contains("yes")) return;
            if (web.canGoBack()) web.goBack();
            else finish();
        });
    }

    void openExternal(String url) {
        try {
            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
        } catch (Exception e) {
            Toast.makeText(this, "ما في تطبيق يفتح هذا الرابط", Toast.LENGTH_SHORT).show();
        }
    }

    class Bridge {
        @JavascriptInterface
        public void openUrl(String url) {
            runOnUiThread(() -> openExternal(url));
        }

        @JavascriptInterface
        public void printPage(String title) {
            runOnUiThread(() -> {
                PrintManager pm = (PrintManager) getSystemService(PRINT_SERVICE);
                pm.print(title, web.createPrintDocumentAdapter(title),
                    new PrintAttributes.Builder().setMediaSize(PrintAttributes.MediaSize.ISO_A4).build());
            });
        }

        @JavascriptInterface
        public void saveFile(String b64, String name, String mime) {
            runOnUiThread(() -> {
                try {
                    byte[] data = Base64.decode(b64, Base64.DEFAULT);
                    Uri uri;
                    if (Build.VERSION.SDK_INT >= 29) {
                        ContentValues cv = new ContentValues();
                        cv.put(MediaStore.Downloads.DISPLAY_NAME, name);
                        cv.put(MediaStore.Downloads.MIME_TYPE, mime);
                        cv.put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS);
                        uri = getContentResolver().insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, cv);
                        OutputStream os = getContentResolver().openOutputStream(uri);
                        os.write(data);
                        os.close();
                        Toast.makeText(MainActivity.this, "تم الحفظ في التنزيلات: " + name, Toast.LENGTH_LONG).show();
                        Intent i = new Intent(Intent.ACTION_SEND);
                        i.setType(mime);
                        i.putExtra(Intent.EXTRA_STREAM, uri);
                        i.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                        startActivity(Intent.createChooser(i, "مشاركة الملف"));
                    } else {
                        File dir = getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS);
                        if (dir != null && !dir.exists()) dir.mkdirs();
                        File f = new File(dir, name);
                        FileOutputStream fo = new FileOutputStream(f);
                        fo.write(data);
                        fo.close();
                        Toast.makeText(MainActivity.this, "تم الحفظ: " + f.getAbsolutePath(), Toast.LENGTH_LONG).show();
                    }
                } catch (Exception e) {
                    Toast.makeText(MainActivity.this, "فشل حفظ الملف: " + e.getMessage(), Toast.LENGTH_LONG).show();
                }
            });
        }
    }
}
EOF

echo "Android project created."
