package cz.tichysimon.flip_the_clock

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // This is a clock meant to sit on a desk or nightstand while
        // charging, so the display must not sleep while it is in the
        // foreground. It also stands in for the Daydream screen saver,
        // which is not registered — see AndroidManifest.xml.
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
}
