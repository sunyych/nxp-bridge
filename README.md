# NXP Bridge

A React Native module for integrating with NXP NTAG and NTAG-I2C NFC tags.

## Features

- Read and write NDEF messages to NFC tags
- Configure measurement parameters for temperature, humidity, and accelerometer
- Retrieve sensor data from NFC tags
- Event-based tag connection and disconnection handling

## Installation

```sh
npm install nxp-bridge
# or
yarn add nxp-bridge
```

## Setup

### iOS

1. Add the following to your `Info.plist`:

```xml
<key>NFCReaderUsageDescription</key>
<string>This app uses NFC to read and write NXP tags</string>
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
    <string>NDEF</string>
    <string>TAG</string>
</array>
```

2. Add NFC capability to your app in Xcode.

### Android

1. Add the following to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.NFC" />
<uses-feature android:name="android.hardware.nfc" android:required="true" />
```

## Development

### Prerequisites

- Node.js
- Yarn
- Xcode (for iOS development)
- Android Studio (for Android development)
- CocoaPods (for iOS dependencies)

### Setup Development Environment

1. Clone the repository
2. Install dependencies:
   ```sh
   yarn install
   ```
3. Setup the project:
   ```sh
   yarn setup
   ```

This will:
- Build the Xamarin libraries (if available)
- Create mock DLLs (if Xamarin libraries are not available)
- Integrate the libraries with the React Native module

### Running the Example App

```sh
cd example
yarn install
# For iOS
yarn ios
# For Android
yarn android
```

## API Reference

### Tag Reader Methods

```typescript
// Initialize the tag reader
initTagReader(): Promise<boolean>

// Deinitialize the tag reader
deinitTagReader(): Promise<boolean>
```

### Configuration Methods

```typescript
// Set configuration for measurements
setConfig(
  measurementConfig: MeasurementConfig,
  temperatureConfig: TemperatureConfig,
  humidityConfig?: HumidityConfig,
  accelerometerConfig?: AccelerometerConfig
): Promise<boolean>

// Get current configuration
getConfig(): Promise<{
  measurementConfig: MeasurementConfig;
  temperatureConfig: TemperatureConfig;
  humidityConfig?: HumidityConfig;
  accelerometerConfig?: AccelerometerConfig;
}>
```

### Data Retrieval Methods

```typescript
// Get data from the tag
getData(): Promise<{
  temperatureData?: Array<{ timestamp: number; temperature: number }>;
  humidityData?: Array<{ timestamp: number; humidity: number }>;
  accelerometerData?: Array<{
    timestamp: number;
    x: number;
    y: number;
    z: number;
  }>;
  eventData?: Array<{ timestamp: number; eventType: string; data: any }>;
}>
```

### Tag Connection Methods

```typescript
// Add a listener for tag connected events
addTagConnectedListener(
  listener: (tagInfo: TagInfo) => void
): {
  remove: () => void;
}

// Add a listener for tag disconnected events
addTagDisconnectedListener(
  listener: () => void
): {
  remove: () => void;
}
```

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
