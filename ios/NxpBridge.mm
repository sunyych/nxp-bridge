#import "NxpBridge.h"

#import <React/RCTBridge+Private.h>
#import <React/RCTUtils.h>
#import <ReactCommon/RCTTurboModule.h>

#import <objc/runtime.h>
#import <dlfcn.h>

@implementation NxpBridge {
  NSMutableDictionary<NSNumber *, NSNumber *> *_tagConnectedListeners;
  NSMutableDictionary<NSNumber *, NSNumber *> *_tagDisconnectedListeners;
  NSInteger _lastSubscriptionId;
}

RCT_EXPORT_MODULE()

// Override init to initialize the listener dictionaries
- (instancetype)init {
  if (self = [super init]) {
    _tagConnectedListeners = [NSMutableDictionary new];
    _tagDisconnectedListeners = [NSMutableDictionary new];
    _lastSubscriptionId = 0;
  }
  return self;
}

// Required for RCTEventEmitter
- (NSArray<NSString *> *)supportedEvents {
  return @[@"tagConnected", @"tagDisconnected"];
}

// Example method
RCT_EXPORT_METHOD(multiply:(double)a
                  b:(double)b
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  NSNumber *result = @(a * b);
  resolve(result);
}

// Initialize the tag reader
RCT_EXPORT_METHOD(initTagReader:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  // Load the Xamarin libraries
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *resourceBundlePath = [bundle pathForResource:@"NxpBridge" ofType:@"bundle"];
  NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];

  NSString *msgDllPath = [resourceBundle pathForResource:@"Msg" ofType:@"dll"];
  NSString *ndefDllPath = [resourceBundle pathForResource:@"Ndef" ofType:@"dll"];

  if (!msgDllPath || !ndefDllPath) {
    NSError *error = [NSError errorWithDomain:@"com.nxpbridge" code:404 userInfo:@{NSLocalizedDescriptionKey: @"Xamarin libraries not found"}];
    reject(@"library_not_found", @"Xamarin libraries not found", error);
    return;
  }

  // TODO: Initialize the Xamarin libraries using the Mono runtime
  // This would require additional integration with the Xamarin runtime

  // For now, we'll just return success
  resolve(@YES);
}

// Deinitialize the tag reader
RCT_EXPORT_METHOD(deinitTagReader:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  // TODO: Deinitialize the Xamarin libraries

  // For now, we'll just return success
  resolve(@YES);
}

// Set configuration
RCT_EXPORT_METHOD(setConfig:(NSDictionary *)measurementConfig
                  temperatureConfig:(NSDictionary *)temperatureConfig
                  humidityConfig:(NSDictionary *)humidityConfig
                  accelerometerConfig:(NSDictionary *)accelerometerConfig
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  // TODO: Call the Xamarin SetConfigCmdAsync method

  // For now, we'll just return success
  resolve(@YES);
}

// Get configuration
RCT_EXPORT_METHOD(getConfig:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  // TODO: Call the Xamarin GetConfigAsync method

  // For now, we'll just return a mock configuration
  NSDictionary *measurementConfig = @{
    @"interval": @60,
    @"startDelay": @0,
    @"runningTime": @3600
  };

  NSDictionary *temperatureConfig = @{
    @"validMinimum": @-10,
    @"validMaximum": @50
  };

  NSDictionary *result = @{
    @"measurementConfig": measurementConfig,
    @"temperatureConfig": temperatureConfig
  };

  resolve(result);
}

// Get data
RCT_EXPORT_METHOD(getData:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  // TODO: Call the Xamarin GetDataAsync method

  // For now, we'll just return mock data
  NSArray *temperatureData = @[
    @{@"timestamp": @1620000000, @"temperature": @25.5},
    @{@"timestamp": @1620001000, @"temperature": @25.6}
  ];

  NSDictionary *result = @{
    @"temperatureData": temperatureData
  };

  resolve(result);
}

// Add tag connected listener - updated to use event emitter pattern
RCT_EXPORT_METHOD(addTagConnectedListener:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  // Generate a new subscription ID
  NSInteger subscriptionId = ++_lastSubscriptionId;
  _tagConnectedListeners[@(subscriptionId)] = @YES;

  // For demonstration, emit a mock tag connected event after a delay
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    if ([self->_tagConnectedListeners objectForKey:@(subscriptionId)]) {
      NSDictionary *tagInfo = @{
        @"tagId": @"12345",
        @"canMeasureTemperature": @YES,
        @"canMeasureHumidity": @NO,
        @"canMeasureAcceleration": @NO
      };
      [self sendEventWithName:@"tagConnected" body:tagInfo];
    }
  });

  resolve(@(subscriptionId));
}

// Remove tag connected listener
RCT_EXPORT_METHOD(removeTagConnectedListener:(NSNumber *)subscriptionId)
{
  [_tagConnectedListeners removeObjectForKey:subscriptionId];
}

// Add tag disconnected listener - updated to use event emitter pattern
RCT_EXPORT_METHOD(addTagDisconnectedListener:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  // Generate a new subscription ID
  NSInteger subscriptionId = ++_lastSubscriptionId;
  _tagDisconnectedListeners[@(subscriptionId)] = @YES;

  // For demonstration, emit a mock tag disconnected event after a delay
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    if ([self->_tagDisconnectedListeners objectForKey:@(subscriptionId)]) {
      [self sendEventWithName:@"tagDisconnected" body:@{}];
    }
  });

  resolve(@(subscriptionId));
}

// Remove tag disconnected listener
RCT_EXPORT_METHOD(removeTagDisconnectedListener:(NSNumber *)subscriptionId)
{
  [_tagDisconnectedListeners removeObjectForKey:subscriptionId];
}

// Required for the TurboModule system
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
  return nullptr;
}

@end
