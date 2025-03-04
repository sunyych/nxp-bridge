import React, { useState, useEffect, useCallback } from 'react';
import {
  Text,
  View,
  StyleSheet,
  Button,
  ScrollView,
  ActivityIndicator,
  SafeAreaView,
  Alert,
} from 'react-native';
import {
  initTagReader,
  deinitTagReader,
  setConfig,
  getConfig,
  getData,
  addTagConnectedListener,
  addTagDisconnectedListener,
  type TagInfo,
  type MeasurementConfig,
  type TemperatureConfig,
  type HumidityConfig,
  type AccelerometerConfig,
} from 'react-native-nxp-bridge';

export default function App() {
  const [isReaderInitialized, setIsReaderInitialized] = useState(false);
  const [isTagConnected, setIsTagConnected] = useState(false);
  const [tagInfo, setTagInfo] = useState<TagInfo | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [configData, setConfigData] = useState<{
    measurementConfig?: MeasurementConfig;
    temperatureConfig?: TemperatureConfig;
    humidityConfig?: HumidityConfig;
    accelerometerConfig?: AccelerometerConfig;
  } | null>(null);
  const [sensorData, setSensorData] = useState<{
    temperatureData?: Array<{ timestamp: number; temperature: number }>;
    humidityData?: Array<{ timestamp: number; humidity: number }>;
    accelerometerData?: Array<{
      timestamp: number;
      x: number;
      y: number;
      z: number;
    }>;
    eventData?: Array<{ timestamp: number; eventType: string; data: any }>;
  } | null>(null);

  const handleGetConfig = useCallback(async () => {
    if (!isTagConnected) {
      Alert.alert('Error', 'No tag connected');
      return;
    }

    try {
      setIsLoading(true);
      const config = await getConfig();
      setConfigData(config);
    } catch (error) {
      Alert.alert('Error', `Failed to get config: ${error}`);
    } finally {
      setIsLoading(false);
    }
  }, [isTagConnected]);

  const handleDeinitReader = useCallback(async () => {
    try {
      setIsLoading(true);
      await deinitTagReader();
      setIsReaderInitialized(false);
    } catch (error) {
      Alert.alert('Error', `Failed to deinitialize tag reader: ${error}`);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const handleInitReader = useCallback(async () => {
    try {
      setIsLoading(true);
      const success = await initTagReader();
      setIsReaderInitialized(success);

      if (success) {
        // Add tag connected listener
        const tagConnectedSubscription = addTagConnectedListener((info) => {
          setIsTagConnected(true);
          setTagInfo(info);
          Alert.alert('Tag Connected', `Tag ID: ${info.tagId}`);

          // Automatically fetch config when tag is connected
          handleGetConfig();
        });

        // Add tag disconnected listener
        const tagDisconnectedSubscription = addTagDisconnectedListener(() => {
          setIsTagConnected(false);
          setTagInfo(null);
          setConfigData(null);
          setSensorData(null);
          Alert.alert('Tag Disconnected');
        });

        // Store subscriptions for cleanup
        return () => {
          tagConnectedSubscription.remove();
          tagDisconnectedSubscription.remove();
        };
      }
    } catch (error) {
      Alert.alert('Error', `Failed to initialize tag reader: ${error}`);
    } finally {
      setIsLoading(false);
    }
  }, [handleGetConfig]);

  useEffect(() => {
    // Initialize tag reader when component mounts
    handleInitReader();

    // Clean up when component unmounts
    return () => {
      handleDeinitReader();
    };
  }, [handleInitReader, handleDeinitReader]);

  const handleGetData = async () => {
    if (!isTagConnected) {
      Alert.alert('Error', 'No tag connected');
      return;
    }

    try {
      setIsLoading(true);
      const data = await getData();
      setSensorData(data);
    } catch (error) {
      Alert.alert('Error', `Failed to get data: ${error}`);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSetConfig = async () => {
    if (!isTagConnected || !configData) {
      Alert.alert('Error', 'No tag connected or no config data available');
      return;
    }

    try {
      setIsLoading(true);

      // Example configuration values
      const measurementConfig: MeasurementConfig = {
        interval: 60, // 60 seconds
        startDelay: 0, // Start immediately
        runningTime: 3600, // Run for 1 hour
      };

      const temperatureConfig: TemperatureConfig = {
        validMinimum: -10, // -10°C
        validMaximum: 50, // 50°C
      };

      // Optional configurations based on tag capabilities
      const humidityConfig: HumidityConfig | undefined = tagInfo?.canMeasureHumidity
        ? {
            validMinimum: 20, // 20%
            validMaximum: 80, // 80%
          }
        : undefined;

      const accelerometerConfig: AccelerometerConfig | undefined = tagInfo?.canMeasureAcceleration
        ? {
            shock: {
              amplitude: 1000,
              waitTime: 100,
              ringingAmplitude: 500,
              ringingCount: 3,
              ringingDuration: 200,
            },
            shake: {
              amplitude: 800,
              count: 5,
              duration: 300,
            },
            vibration: {
              amplitude: 600,
              frequency: 10,
              duration: 500,
            },
            tilt: {
              waitTime: 100,
            },
          }
        : undefined;

      const success = await setConfig(
        measurementConfig,
        temperatureConfig,
        humidityConfig,
        accelerometerConfig
      );

      if (success) {
        Alert.alert('Success', 'Configuration set successfully');
        // Refresh config data
        handleGetConfig();
      } else {
        Alert.alert('Error', 'Failed to set configuration');
      }
    } catch (error) {
      Alert.alert('Error', `Failed to set config: ${error}`);
    } finally {
      setIsLoading(false);
    }
  };

  const renderTagInfo = () => {
    if (!tagInfo) return null;

    return (
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Tag Information</Text>
        <Text>Tag ID: {tagInfo.tagId}</Text>
        <Text>Temperature Sensor: {tagInfo.canMeasureTemperature ? 'Yes' : 'No'}</Text>
        <Text>Humidity Sensor: {tagInfo.canMeasureHumidity ? 'Yes' : 'No'}</Text>
        <Text>Accelerometer: {tagInfo.canMeasureAcceleration ? 'Yes' : 'No'}</Text>
      </View>
    );
  };

  const renderConfigData = () => {
    if (!configData) return null;

    return (
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Configuration</Text>

        {configData.measurementConfig && (
          <View style={styles.subsection}>
            <Text style={styles.subsectionTitle}>Measurement</Text>
            <Text>Interval: {configData.measurementConfig.interval} seconds</Text>
            <Text>Start Delay: {configData.measurementConfig.startDelay} seconds</Text>
            <Text>Running Time: {configData.measurementConfig.runningTime} seconds</Text>
          </View>
        )}

        {configData.temperatureConfig && (
          <View style={styles.subsection}>
            <Text style={styles.subsectionTitle}>Temperature</Text>
            <Text>Valid Min: {configData.temperatureConfig.validMinimum}°C</Text>
            <Text>Valid Max: {configData.temperatureConfig.validMaximum}°C</Text>
          </View>
        )}

        {configData.humidityConfig && (
          <View style={styles.subsection}>
            <Text style={styles.subsectionTitle}>Humidity</Text>
            <Text>Valid Min: {configData.humidityConfig.validMinimum}%</Text>
            <Text>Valid Max: {configData.humidityConfig.validMaximum}%</Text>
          </View>
        )}

        {configData.accelerometerConfig && (
          <View style={styles.subsection}>
            <Text style={styles.subsectionTitle}>Accelerometer</Text>
            <Text>Shock Amplitude: {configData.accelerometerConfig.shock.amplitude}</Text>
            <Text>Shake Count: {configData.accelerometerConfig.shake.count}</Text>
            <Text>Vibration Frequency: {configData.accelerometerConfig.vibration.frequency}</Text>
            <Text>Tilt Wait Time: {configData.accelerometerConfig.tilt.waitTime}</Text>
          </View>
        )}
      </View>
    );
  };

  const renderSensorData = () => {
    if (!sensorData) return null;

    return (
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Sensor Data</Text>

        {sensorData.temperatureData && sensorData.temperatureData.length > 0 && (
          <View style={styles.subsection}>
            <Text style={styles.subsectionTitle}>Temperature Data</Text>
            {sensorData.temperatureData.slice(0, 5).map((item, index) => (
              <Text key={index}>
                {new Date(item.timestamp * 1000).toLocaleString()}: {item.temperature}°C
              </Text>
            ))}
            {sensorData.temperatureData.length > 5 && (
              <Text>...and {sensorData.temperatureData.length - 5} more</Text>
            )}
          </View>
        )}

        {sensorData.humidityData && sensorData.humidityData.length > 0 && (
          <View style={styles.subsection}>
            <Text style={styles.subsectionTitle}>Humidity Data</Text>
            {sensorData.humidityData.slice(0, 5).map((item, index) => (
              <Text key={index}>
                {new Date(item.timestamp * 1000).toLocaleString()}: {item.humidity}%
              </Text>
            ))}
            {sensorData.humidityData.length > 5 && (
              <Text>...and {sensorData.humidityData.length - 5} more</Text>
            )}
          </View>
        )}

        {sensorData.accelerometerData && sensorData.accelerometerData.length > 0 && (
          <View style={styles.subsection}>
            <Text style={styles.subsectionTitle}>Accelerometer Data</Text>
            {sensorData.accelerometerData.slice(0, 5).map((item, index) => (
              <Text key={index}>
                {new Date(item.timestamp * 1000).toLocaleString()}:
                X: {item.x}, Y: {item.y}, Z: {item.z}
              </Text>
            ))}
            {sensorData.accelerometerData.length > 5 && (
              <Text>...and {sensorData.accelerometerData.length - 5} more</Text>
            )}
          </View>
        )}

        {sensorData.eventData && sensorData.eventData.length > 0 && (
          <View style={styles.subsection}>
            <Text style={styles.subsectionTitle}>Event Data</Text>
            {sensorData.eventData.slice(0, 5).map((item, index) => (
              <Text key={index}>
                {new Date(item.timestamp * 1000).toLocaleString()}: {item.eventType}
              </Text>
            ))}
            {sensorData.eventData.length > 5 && (
              <Text>...and {sensorData.eventData.length - 5} more</Text>
            )}
          </View>
        )}
      </View>
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Text style={styles.title}>NXP Bridge Demo</Text>

        <View style={styles.statusContainer}>
          <Text>Reader Status: {isReaderInitialized ? 'Initialized' : 'Not Initialized'}</Text>
          <Text>Tag Status: {isTagConnected ? 'Connected' : 'Not Connected'}</Text>
        </View>

        <View style={styles.buttonContainer}>
          <Button
            title={isReaderInitialized ? "Deinitialize Reader" : "Initialize Reader"}
            onPress={isReaderInitialized ? handleDeinitReader : handleInitReader}
            disabled={isLoading}
          />
        </View>

        {isTagConnected && (
          <>
            <View style={styles.buttonRow}>
              <View style={styles.buttonContainer}>
                <Button
                  title="Get Config"
                  onPress={handleGetConfig}
                  disabled={isLoading || !isTagConnected}
                />
              </View>
              <View style={styles.buttonContainer}>
                <Button
                  title="Get Data"
                  onPress={handleGetData}
                  disabled={isLoading || !isTagConnected}
                />
              </View>
            </View>

            <View style={styles.buttonContainer}>
              <Button
                title="Set Example Config"
                onPress={handleSetConfig}
                disabled={isLoading || !isTagConnected}
              />
            </View>

            {renderTagInfo()}
            {renderConfigData()}
            {renderSensorData()}
          </>
        )}

        {isLoading && (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color="#0000ff" />
            <Text>Loading...</Text>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollContent: {
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  statusContainer: {
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 8,
    marginBottom: 16,
  },
  buttonContainer: {
    marginBottom: 12,
  },
  buttonRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  section: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 8,
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  subsection: {
    marginTop: 8,
    marginBottom: 8,
    paddingLeft: 8,
    borderLeftWidth: 2,
    borderLeftColor: '#ddd',
  },
  subsectionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  loadingContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
  },
});
