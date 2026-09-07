package cz.tichysimon.flip_the_clock

import android.service.dreams.DreamService
import android.view.WindowManager
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * Android's equivalent of a Windows screensaver ("Daydream" — Settings ->
 * Display -> Screen saver). Hosts a [FlutterView] directly in this Service,
 * since a Dream has no Activity of its own. Runs the same lib/main.dart
 * entrypoint as the regular app; on any platform other than Windows, main()
 * always resolves to the standalone (fullscreen clock) mode, so no extra
 * Dart-side branching is needed here.
 *
 * Two things this has to do that a FlutterActivity would normally handle:
 *
 *  - Drive [FlutterEngine.getLifecycleChannel]. Without an Activity nothing
 *    tells the framework the app is resumed, so the engine never schedules a
 *    frame and the dream renders as a black screen.
 *
 *  - Reuse one cached engine. Creating and destroying a fresh FlutterEngine
 *    per dream made the clock appear only on roughly every other run;
 *    repeated standalone engine creation in a single process is unreliable.
 *    The engine is kept in [FlutterEngineCache] and only detached (never
 *    destroyed) when the dream ends, so the next dream reattaches to a
 *    known-good engine.
 */
class FlipTheClockDreamService : DreamService() {
    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null

    private fun obtainEngine(): FlutterEngine {
        FlutterEngineCache.getInstance().get(ENGINE_ID)?.let { return it }

        val engine = FlutterEngine(applicationContext)
        GeneratedPluginRegistrant.registerWith(engine)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        return engine
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()

        isInteractive = false
        isFullscreen = true
        isScreenBright = true
        window?.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        val engine = obtainEngine()
        flutterEngine = engine

        val view = FlutterView(this)
        setContentView(view)
        view.attachToFlutterEngine(engine)
        flutterView = view

        // Also resume here, not only in onDreamingStarted(): the settings
        // "Preview" path does not reliably deliver that callback, and a
        // never-resumed engine paints one static frame and then stops.
        engine.lifecycleChannel.appIsResumed()
    }

    override fun onDreamingStarted() {
        super.onDreamingStarted()
        flutterEngine?.lifecycleChannel?.appIsResumed()
    }

    override fun onDreamingStopped() {
        flutterEngine?.lifecycleChannel?.appIsPaused()
        super.onDreamingStopped()
    }

    override fun onDetachedFromWindow() {
        // Detach the view but deliberately keep the engine cached and alive
        // for the next dream — destroying it here is what made startup
        // unreliable.
        flutterView?.detachFromFlutterEngine()
        flutterView = null
        flutterEngine = null
        super.onDetachedFromWindow()
    }

    private companion object {
        const val ENGINE_ID = "fliptheclock_dream_engine"
    }
}
