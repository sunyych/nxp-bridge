import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

// Define interfaces for configuration models
export interface MeasurementConfig {
  interval: number;
  startDelay: number;
  runningTime: number;
}

export interface TemperatureConfig {
  validMinimum: number;
  validMaximum: number;
}

export interface HumidityConfig {
  validMinimum: number;
  validMaximum: number;
}

export interface AccelerometerConfig {
  shock: {
    amplitude: number;
    waitTime: number;
    ringingAmplitude: number;
    ringingCount: number;
    ringingDuration: number;
  };
  shake: {
    amplitude: number;
    count: number;
    duration: number;
  };
  vibration: {
    amplitude: number;
    frequency: number;
    duration: number;
  };
  tilt: {
    waitTime: number;
  };
}

export interface TagInfo {
  tagId: string;
  canMeasureTemperature: boolean;
  canMeasureHumidity: boolean;
  canMeasureAcceleration: boolean;
}

export interface Spec extends TurboModule {
  // Original example method
  multiply(a: number, b: number): number;

  // NFC/NDEF methods
  initTagReader(): Promise<boolean>;
  deinitTagReader(): Promise<boolean>;

  // Configuration methods
  setConfig(
    measurementConfig: MeasurementConfig,
    temperatureConfig: TemperatureConfig,
    humidityConfig?: HumidityConfig,
    accelerometerConfig?: AccelerometerConfig
  ): Promise<boolean>;

  getConfig(): Promise<{
    measurementConfig: MeasurementConfig;
    temperatureConfig: TemperatureConfig;
    humidityConfig?: HumidityConfig;
    accelerometerConfig?: AccelerometerConfig;
  }>;

  // Data retrieval methods
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
  }>;

  // Tag connection methods - modified to be compatible with codegen
  // Instead of passing functions directly, we'll use event emitter pattern
  addTagConnectedListener(): number; // Returns a subscription ID
  removeTagConnectedListener(subscriptionId: number): void;

  addTagDisconnectedListener(): number; // Returns a subscription ID
  removeTagDisconnectedListener(subscriptionId: number): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('NxpBridge');
