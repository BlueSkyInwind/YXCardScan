//
//  YXBaseScanManager.m
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/10/30.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "YXBaseScanManager.h"

@implementation YXBaseScanManager

-(AVCaptureSession *)captureSession{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc]init];
        [_captureSession beginConfiguration];
    }
    return _captureSession;
}

-(void)startSession{
    if (![self.captureSession isRunning]) {
        dispatch_async(self.queue, ^{
            [self.captureSession startRunning];
        });
    }
}

-(void)stopSession{
    if ([self.captureSession isRunning]) {
        dispatch_async(self.queue, ^{
            [self.captureSession stopRunning];
        });
    }
}

#pragma mark queue
-(dispatch_queue_t)queue {
    if (_queue == nil) {
        _queue = dispatch_queue_create("www.captureQue.com", NULL);
    }
    return _queue;
}

#pragma mark - AVCaptureDevice 输入设备
-(AVCaptureDevice *)captureDevice{
    if (!_captureDevice) {
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _captureDevice;
}

/**
 活跃设备配置

 @param device 当前设备
 */
-(void)activeDeviceConfigure:(AVCaptureDevice *)device{
    if ([device lockForConfiguration:NULL]) {
        //平滑对焦
        if ([device isSmoothAutoFocusSupported]) {
            device.smoothAutoFocusEnabled = true;
        }
        //自动持续对焦
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        //自动持续曝光
        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        //自动持续白平衡
        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        }
        [device unlockForConfiguration];
    }
}

#pragma mark - AVCaptureVideoDataOutput
-(AVCaptureVideoDataOutput *)videoDataOutput{
    if (!_videoDataOutput) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoDataOutput.alwaysDiscardsLateVideoFrames = YES; //是否可以卡顿时丢帧
        _videoDataOutput.videoSettings =  [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], (id)kCVPixelBufferPixelFormatTypeKey, nil]; //指定用于解码或重新编码视频的设置
    }
    return _videoDataOutput;
}

-(BOOL)configOutPutAtQueue:(dispatch_queue_t)queue{
    [self.videoDataOutput setSampleBufferDelegate:self queue:queue];
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        [self.captureSession addOutput:self.videoDataOutput];
    } else {
        return false;
    }
    return true;
}

#pragma mark - AVCaptureDeviceInput
-(BOOL)configActiveInPutQueue:(dispatch_queue_t)queue activeDevice:(AVCaptureDevice *)captureDevice{
    NSError * error;
    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    } else {
        return false;
    }
    
    if (error && error.description) {
        NSLog(@"%@", error.description);
        return false;
    }
    return true;
}

#pragma mark - AVCaptureConnection
-(void)configureConnection{
    AVCaptureConnection *videoConnection;
    for (AVCaptureConnection *connection in [self.videoDataOutput connections]) {
        for (AVCaptureInputPort *port in[connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
            }
        }
    }
    if ([videoConnection isVideoStabilizationSupported]) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            videoConnection.enablesVideoStabilizationWhenAvailable = YES;
        }
        else {
            videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    [self detectionOfLightIntensity:sampleBuffer];
    CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if ([captureOutput isEqual:self.videoDataOutput] && self.resultBuffer  != nil) {
        self.resultBuffer((__bridge id)(imageBuffer));
    }
}

#pragma mark - 检测光线 强度

-(void)detectionOfLightIntensity:(CMSampleBufferRef)imageBuffer{
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,imageBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    NSLog(@"-----环境亮度-----%f",brightnessValue);

}

//闪光灯
-(void)setFlashMode:(AVCaptureTorchMode)torchMode{
    AVCaptureDevice * activeDevice = self.captureDevice;
    if (activeDevice.torchMode != torchMode && [activeDevice isTorchAvailable]) {
        NSError *error;
        if ([activeDevice lockForConfiguration:&error]) {
            activeDevice.torchMode = torchMode;
            [activeDevice unlockForConfiguration];
        }
        else{
            NSLog(@"%@",error);
        }
    }
}




@end
