import { NativeEventEmitter, NativeModules } from 'react-native';
import NxpBridge from './NativeNxpBridge';
import type {
  MeasurementConfig,
  TemperatureConfig,
  HumidityConfig,
  AccelerometerConfig,
  TagInfo,
} from './NativeNxpBridge';

// Create event emitter for tag events
const nxpBridgeEmitter = new NativeEventEmitter(NativeModules.NxpBridge);

export function multiply(a: number, b: number): number {
  return NxpBridge.multiply(a, b);
}

// NFC/NDEF methods
export function initTagReader(): Promise<boolean> {
  return NxpBridge.initTagReader();
}

export function deinitTagReader(): Promise<boolean> {
  return NxpBridge.deinitTagReader();
}

// Configuration methods
export function setConfig(
  measurementConfig: MeasurementConfig,
  temperatureConfig: TemperatureConfig,
  humidityConfig?: HumidityConfig,
  accelerometerConfig?: AccelerometerConfig
): Promise<boolean> {
  return NxpBridge.setConfig(
    measurementConfig,
    temperatureConfig,
    humidityConfig,
    accelerometerConfig
  );
}

export function getConfig(): Promise<{
  measurementConfig: MeasurementConfig;
  temperatureConfig: TemperatureConfig;
  humidityConfig?: HumidityConfig;
  accelerometerConfig?: AccelerometerConfig;
}> {
  return NxpBridge.getConfig();
}

// Data retrieval methods
export function getData(): Promise<{
  temperatureData?: Array<{ timestamp: number; temperature: number }>;
  humidityData?: Array<{ timestamp: number; humidity: number }>;
  accelerometerData?: Array<{
    timestamp: number;
    x: number;
    y: number;
    z: number;
  }>;
  eventData?: Array<{ timestamp: number; eventType: string; data: any }>;
}> {
  return NxpBridge.getData();
}

// Tag connection methods - updated to use event emitter
export function addTagConnectedListener(
  listener: (tagInfo: TagInfo) => void
): {
  remove: () => void;
} {
  const eventSubscription = nxpBridgeEmitter.addListener('tagConnected', listener);
  const subscriptionId = NxpBridge.addTagConnectedListener();

  return {
    remove: () => {
      NxpBridge.removeTagConnectedListener(subscriptionId);
      eventSubscription.remove();
    },
  };
}

export function addTagDisconnectedListener(
  listener: () => void
): {
  remove: () => void;
} {
  const eventSubscription = nxpBridgeEmitter.addListener('tagDisconnected', listener);
  const subscriptionId = NxpBridge.addTagDisconnectedListener();

  return {
    remove: () => {
      NxpBridge.removeTagDisconnectedListener(subscriptionId);
      eventSubscription.remove();
    },
  };
}

// Export types
export type {
  MeasurementConfig,
  TemperatureConfig,
  HumidityConfig,
  AccelerometerConfig,
  TagInfo,
};
