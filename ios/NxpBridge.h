#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface NxpBridge : RCTEventEmitter <RCTBridgeModule>

// Initialize the tag reader
- (void)initTagReader:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject;

// Deinitialize the tag reader
- (void)deinitTagReader:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject;

// Set configuration
- (void)setConfig:(NSDictionary *)measurementConfig
temperatureConfig:(NSDictionary *)temperatureConfig
   humidityConfig:(NSDictionary *)humidityConfig
accelerometerConfig:(NSDictionary *)accelerometerConfig
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject;

// Get configuration
- (void)getConfig:(RCTPromiseResolveBlock)resolve
          reject:(RCTPromiseRejectBlock)reject;

// Get data
- (void)getData:(RCTPromiseResolveBlock)resolve
        reject:(RCTPromiseRejectBlock)reject;

// Tag connection methods - updated to use event emitter pattern
- (NSNumber *)addTagConnectedListener;
- (void)removeTagConnectedListener:(NSNumber *)subscriptionId;

- (NSNumber *)addTagDisconnectedListener;
- (void)removeTagDisconnectedListener:(NSNumber *)subscriptionId;

@end
