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
#import "excards.h"

//扫描类型
typedef enum : NSUInteger {
    BankScanType,
    IDScanType,
} YScanType;

@interface YXBaseScanManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic,assign)YScanType yScantype;
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

@end
