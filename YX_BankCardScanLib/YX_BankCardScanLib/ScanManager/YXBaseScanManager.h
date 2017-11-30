//
//  YXBaseScanManager.h
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/10/30.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "RectManager.h"
#import "BankCardSearch.h"
#import "UIImage+Extend.h"
#import "exbankcard.h"

//扫描类型
typedef enum : NSUInteger {
    BankScanType,
    IDScanType,
} YScanType;

typedef void (^ScanResultBuffer)(id imageBuffer) ;
typedef void (^ScanBankCardResult)(id result) ;
typedef void (^ScanIDCardResult)(id result) ;

@interface YXBaseScanManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic,copy)ScanResultBuffer resultBuffer;

@property(nonatomic,copy)ScanBankCardResult bankCardesult;

@property(nonatomic,copy)ScanIDCardResult IDCardesult;

//扫描类型
@property(nonatomic,assign)YScanType yScantype;

@property (nonatomic, assign) BOOL isInProcessing;

@property (nonatomic, assign) BOOL isHasResult;
//输出流
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
//输入流
@property (nonatomic, strong) AVCaptureDeviceInput *activeVideoInput;
// 图片质量
@property (nonatomic, copy) NSString *sessionPreset;
//中心类
@property (nonatomic, strong) AVCaptureSession *captureSession;
//设备
@property (nonatomic, strong) AVCaptureDevice * captureDevice;
// 队列
@property (nonatomic,strong) dispatch_queue_t queue;
/**
 活跃设备配置
 
 @param device 当前设备
 */
-(void)activeDeviceConfigure:(AVCaptureDevice *)device;
//启动、停止 服务
-(void)startSession;
-(void)stopSession;
//视频采集输出
-(BOOL)configOutPutAtQueue:(dispatch_queue_t)queue;
//视频采集输入
-(BOOL)configActiveInPutQueue:(dispatch_queue_t)queue activeDevice:(AVCaptureDevice *)captureDevice;

//AVCaptureConnection
-(void)configureConnection;
// 闪关灯
- (void)setFlashMode:(AVCaptureTorchMode)flashMode;


@end
