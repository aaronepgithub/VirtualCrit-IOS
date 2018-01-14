// Copyright (c) Attack Pattern LLC.  All rights reserved.
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

// Simulates a heart rate device with:
//
//      * Heart rate measurement (required)
//      * Sensor body location (optional)
//
// http://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.heart_rate.xml

#import "HeartRateDevice.h"
#import <Foundation/NSNotification.h>

//#define HEART_RATE_SERVICE_UUID                      @"180D"
//#define HEART_RATE_MEASUREMENT_CHARACTERISTIC_UUID   @"2A37"
//#define BODY_SENSOR_LOCATION_CHARACTERISTIC_UUID     @"2A38"

#define HEART_RATE_SERVICE_UUID                      @"1816"
#define HEART_RATE_MEASUREMENT_CHARACTERISTIC_UUID   @"2A5B"
#define BODY_SENSOR_LOCATION_CHARACTERISTIC_UUID     @"2A38"


//let HR_Service = "0x180D"
//let HR_Char =  "0x2A37"
//
//let CSC_Service = "0x1816"
//let CSC_Char = "0x2A5B"

@interface HeartRateDevice()

@property (nonatomic, strong) CBMutableService *heartRateService;
@property (nonatomic, strong) CBMutableCharacteristic *heartRateMeasurementCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *bodySensorLocationCharacteristic;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation HeartRateDevice
{
    NSArray *_services;
    uint8_t _currentHeartRate;
    uint8_t _b5;
    uint8_t _b6;
    
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _currentHeartRate = _targetHeartRate = 1;
        _location = HRSensorLocationFinger;
        _b5 = 100;
        _b6 = 1;
    }
    return self;
}

- (NSString *)name
{
    return @"Heart Rate";
}

- (NSString *)imageName
{
    return @"HeartRateMonitor.png";
}

- (void)setTargetHeartRate:(uint8_t)targetHeartRate
{
    _currentHeartRate = _targetHeartRate = targetHeartRate;
    if (self.on)
        [self sendHeartRateMeasurement];
}

- (uint8_t) heartRate {
    return _currentHeartRate;
}

- (NSArray *)services
{
    if (!_services) _services = @[[self createHeartRateService]];
    return _services;
}

- (CBMutableService *)createHeartRateService
{
    self.heartRateService =
        [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:HEART_RATE_SERVICE_UUID]
                                       primary:YES];
    
    self.heartRateMeasurementCharacteristic =
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:HEART_RATE_MEASUREMENT_CHARACTERISTIC_UUID]
                                           properties:(CBCharacteristicPropertyNotify)
                                                value:nil
                                          permissions:CBAttributePermissionsReadable];
    
    self.bodySensorLocationCharacteristic =
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BODY_SENSOR_LOCATION_CHARACTERISTIC_UUID]
                                           properties:CBCharacteristicPropertyRead
                                                value:nil
                                          permissions:CBAttributePermissionsReadable];
    
    self.heartRateService.characteristics = @[self.heartRateMeasurementCharacteristic,
                                              self.bodySensorLocationCharacteristic];
    return self.heartRateService;
}

- (void)setOn:(BOOL) on
{
    if (self.on == on)
        return;
    
    super.on = on;
    
    if (on)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(simulateHeartRateFlux)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    else
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (NSData *)getCharacteristicValue:(CBCharacteristic *) characteristic
{
    if ([characteristic.UUID isEqual:self.bodySensorLocationCharacteristic.UUID])
    {
        NSLog(@"Reading body sensor location");
        return [self makeBodySensorLocationPayload];
    }
    return nil;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    if ([characteristic.UUID isEqual:self.heartRateMeasurementCharacteristic.UUID])
    {
        NSLog(@"Subscribed to heart rate characteristic");
        [self sendHeartRateMeasurement];
    }
}

const int fluxEitherSide = 2;



- (void)simulateHeartRateFlux
{
    //if (self.targetHeartRate < fluxEitherSide)
        //return;
    
    //int flux = (arc4random_uniform(fluxEitherSide * 2) - fluxEitherSide);
    //_currentHeartRate = self.targetHeartRate + flux;
    
    int flux = (arc4random_uniform(fluxEitherSide * 2));
    _currentHeartRate = _currentHeartRate + flux;
    _b6 = _b6 + 2;
    
    [self sendHeartRateMeasurement];
}


- (void)sendHeartRateMeasurement
{
    NSLog(@"Sending heart rate measurement");
    
    [self.manager updateValue:[self makeHeartRateMeasurementPayload]
            forCharacteristic:self.heartRateMeasurementCharacteristic
         onSubscribedCentrals:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BTHeartRateChanged"
                                                        object:self];
}

- (NSData *)makeHeartRateMeasurementPayload
{
    // The structure of the heart rate measurement characteristic is described at
    // http://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.heart_rate_measurement.xml
        
    NSMutableData* payload = [NSMutableData dataWithLength:7];
    uint8_t *bytes = [payload mutableBytes];
    bytes[0] = 0x01;
//    bytes[1] = (uint32_t) self.heartRate;
//    bytes[5] = (uint16_t) self.heartRate;
    bytes[1] = (uint8_t) self.heartRate;
        bytes[2] = (uint8_t) 0;
        bytes[3] = (uint8_t) 0;
        bytes[4] = (uint8_t) 0;
    bytes[5] = (uint8_t) _b5;
    bytes[6] = (uint8_t) _b6;
    
    return payload;
}

- (NSData *)makeBodySensorLocationPayload
{
    // The structure of the body sensor location characteristic is described at
    // http://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.body_sensor_location.xml
    
    const uint8_t bytes[] = { self.location };
    return [NSData dataWithBytes:bytes length:sizeof(bytes)];
}

@end
