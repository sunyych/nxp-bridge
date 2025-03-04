package com.nxpbridge

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.Arguments
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.modules.core.DeviceEventManagerModule
import java.io.File
import dalvik.system.DexClassLoader
import android.os.Handler
import android.os.Looper
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicInteger

@ReactModule(name = NxpBridgeModule.NAME)
class NxpBridgeModule(private val reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  private val tagConnectedListeners = ConcurrentHashMap<Int, Boolean>()
  private val tagDisconnectedListeners = ConcurrentHashMap<Int, Boolean>()
  private val lastSubscriptionId = AtomicInteger(0)
  private val handler = Handler(Looper.getMainLooper())

  override fun getName(): String {
    return NAME
  }

  private fun sendEvent(eventName: String, params: WritableMap?) {
    reactContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(eventName, params)
  }

  // Example method
  @ReactMethod
  fun multiply(a: Double, b: Double, promise: Promise) {
    promise.resolve(a * b)
  }

  // Initialize the tag reader
  @ReactMethod
  fun initTagReader(promise: Promise) {
    try {
      // Load the Xamarin libraries
      val libsDir = File(reactContext.filesDir, "xamarin")
      if (!libsDir.exists()) {
        // Copy the DLLs from the assets to the files directory
        val msgDll = File(libsDir, "Msg.dll")
        val ndefDll = File(libsDir, "Ndef.dll")

        if (!msgDll.exists() || !ndefDll.exists()) {
          promise.reject("library_not_found", "Xamarin libraries not found")
          return
        }
      }

      // TODO: Initialize the Xamarin libraries using the Mono runtime
      // This would require additional integration with the Xamarin runtime

      // For now, we'll just return success
      promise.resolve(true)
    } catch (e: Exception) {
      promise.reject("init_error", "Failed to initialize tag reader", e)
    }
  }

  // Deinitialize the tag reader
  @ReactMethod
  fun deinitTagReader(promise: Promise) {
    try {
      // TODO: Deinitialize the Xamarin libraries

      // For now, we'll just return success
      promise.resolve(true)
    } catch (e: Exception) {
      promise.reject("deinit_error", "Failed to deinitialize tag reader", e)
    }
  }

  // Set configuration
  @ReactMethod
  fun setConfig(
    measurementConfig: ReadableMap,
    temperatureConfig: ReadableMap,
    humidityConfig: ReadableMap?,
    accelerometerConfig: ReadableMap?,
    promise: Promise
  ) {
    try {
      // TODO: Call the Xamarin SetConfigCmdAsync method

      // For now, we'll just return success
      promise.resolve(true)
    } catch (e: Exception) {
      promise.reject("set_config_error", "Failed to set configuration", e)
    }
  }

  // Get configuration
  @ReactMethod
  fun getConfig(promise: Promise) {
    try {
      // TODO: Call the Xamarin GetConfigAsync method

      // For now, we'll just return a mock configuration
      val result = Arguments.createMap()

      val measurementConfig = Arguments.createMap()
      measurementConfig.putInt("interval", 60)
      measurementConfig.putInt("startDelay", 0)
      measurementConfig.putInt("runningTime", 3600)

      val temperatureConfig = Arguments.createMap()
      temperatureConfig.putDouble("validMinimum", -10.0)
      temperatureConfig.putDouble("validMaximum", 50.0)

      result.putMap("measurementConfig", measurementConfig)
      result.putMap("temperatureConfig", temperatureConfig)

      promise.resolve(result)
    } catch (e: Exception) {
      promise.reject("get_config_error", "Failed to get configuration", e)
    }
  }

  // Get data
  @ReactMethod
  fun getData(promise: Promise) {
    try {
      // TODO: Call the Xamarin GetDataAsync method

      // For now, we'll just return mock data
      val result = Arguments.createMap()

      val temperatureData = Arguments.createArray()
      val temperatureItem1 = Arguments.createMap()
      temperatureItem1.putDouble("timestamp", 1620000000.0)
      temperatureItem1.putDouble("temperature", 25.5)

      val temperatureItem2 = Arguments.createMap()
      temperatureItem2.putDouble("timestamp", 1620001000.0)
      temperatureItem2.putDouble("temperature", 25.6)

      temperatureData.pushMap(temperatureItem1)
      temperatureData.pushMap(temperatureItem2)

      result.putArray("temperatureData", temperatureData)

      promise.resolve(result)
    } catch (e: Exception) {
      promise.reject("get_data_error", "Failed to get data", e)
    }
  }

  // Add tag connected listener - updated to use event emitter pattern
  @ReactMethod
  fun addTagConnectedListener(promise: Promise) {
    try {
      val subscriptionId = lastSubscriptionId.incrementAndGet()
      tagConnectedListeners[subscriptionId] = true

      // For demonstration, emit a mock tag connected event after a delay
      handler.postDelayed({
        if (tagConnectedListeners.containsKey(subscriptionId)) {
          val tagInfo = Arguments.createMap()
          tagInfo.putString("tagId", "12345")
          tagInfo.putBoolean("canMeasureTemperature", true)
          tagInfo.putBoolean("canMeasureHumidity", false)
          tagInfo.putBoolean("canMeasureAcceleration", false)

          sendEvent("tagConnected", tagInfo)
        }
      }, 1000)

      promise.resolve(subscriptionId)
    } catch (e: Exception) {
      promise.reject("listener_error", "Failed to add tag connected listener", e)
    }
  }

  // Remove tag connected listener
  @ReactMethod
  fun removeTagConnectedListener(subscriptionId: Int) {
    tagConnectedListeners.remove(subscriptionId)
  }

  // Add tag disconnected listener - updated to use event emitter pattern
  @ReactMethod
  fun addTagDisconnectedListener(promise: Promise) {
    try {
      val subscriptionId = lastSubscriptionId.incrementAndGet()
      tagDisconnectedListeners[subscriptionId] = true

      // For demonstration, emit a mock tag disconnected event after a delay
      handler.postDelayed({
        if (tagDisconnectedListeners.containsKey(subscriptionId)) {
          sendEvent("tagDisconnected", Arguments.createMap())
        }
      }, 3000)

      promise.resolve(subscriptionId)
    } catch (e: Exception) {
      promise.reject("listener_error", "Failed to add tag disconnected listener", e)
    }
  }

  // Remove tag disconnected listener
  @ReactMethod
  fun removeTagDisconnectedListener(subscriptionId: Int) {
    tagDisconnectedListeners.remove(subscriptionId)
  }

  companion object {
    const val NAME = "NxpBridge"
  }
}

