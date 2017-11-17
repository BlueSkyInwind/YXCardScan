//
//  YXScanManager.m
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/10/30.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "YXScanManager.h"

@implementation YXScanManager
#pragma mark - 检测是模拟器还是真机
#if TARGET_IPHONE_SIMULATOR
// 是模拟器的话，提示“请使用真机测试！！！”


#else
#pragma mark device
#pragma mark - 银行卡
- (BOOL)configBankScanManager {
    self.yScantype = BankScanType;
    return [self configureSession];
}

#pragma mark - 身份证
- (BOOL)configIDScanManager {
    [self configIDScan];
    self.yScantype = IDScanType;
    return [self configureSession];
}

static bool initFlag = NO;
- (void)configIDScan {
    if (!initFlag) {
        const char *thePath = [[[NSBundle mainBundle] resourcePath] UTF8String];
        int ret = EXCARDS_Init(thePath);
        if (ret != 0) {
            NSLog(@"初始化失败：ret=%d", ret);
        }
        initFlag = YES;
    }
}
#pragma mark - 配置初始化

- (void)doSomethingWhenWillDisappear {
    if ([self.captureSession isRunning]) {
        [self stopSession];
        [self resetParams];
    }
}

- (void)doSomethingWhenWillAppear {
    if (![self.captureSession isRunning]) {
        [self startSession];
        [self resetParams];
    }
}
-(void)resetParams{
    self.isInProcessing = NO;
    self.isHasResult = NO;
}
-(BOOL)configureSession{
    
    self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    if (![self configOutPutAtQueue:self.queue] || ![self configActiveInPutQueue:self.queue activeDevice:self.captureDevice]) {
        return false;
    }
    [self configureConnection];
    [self activeDeviceConfigure:self.captureDevice];
    [self.captureSession commitConfiguration];
    __weak typeof (self) weakSelf = self;
    self.resultBuffer = ^(id imageBuffer) {
        CVImageBufferRef resimageBuffer = (__bridge CVImageBufferRef)(imageBuffer);
        [weakSelf doResult:resimageBuffer];
    };
    return true;
}

- (void)doResult:(CVImageBufferRef)imageBuffer {
    @synchronized(self) {
        self.isInProcessing = YES;
        if (self.isHasResult) {
            return;
        }
        CVBufferRetain(imageBuffer);
        if(CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
            switch (self.yScantype) {
                case BankScanType: {
                    [self parseBankImageBuffer:imageBuffer];
                }
                    break;
                case IDScanType: {
                    [self parseIDCardImageBuffer:imageBuffer];
                }
                    break;
                default:
                    break;
            }
        }
        CVBufferRelease(imageBuffer);
    }
}

- (void)parseBankImageBuffer:(CVImageBufferRef)imageBuffer {
    
    size_t width_t= CVPixelBufferGetWidth(imageBuffer);
    size_t height_t = CVPixelBufferGetHeight(imageBuffer);
    // YCbCr与YPbPr则是用来描述数位的影像信号，等都可以称为YUV，彼此有重叠； Y表示明亮度(Luminance、Luma)，U和V则是色度、浓度(Chrominance、Chroma)
    //返回imageBuffer 数据的 YCbCr 格式；
    CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
     //内存中 视频缓存数据的 Y分量上初始地址 距 这个平面 地址的偏移
    size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);
    //内存中 视频缓存数据的 Y分量上初始地址
    unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
    //  Y分量 上这个平面 内存地址
    unsigned char* pixelAddress = baseAddress + offset;
    
    //内存中 视频缓存数据的 CbCr分量上初始地址 距 这个平面 地址的偏移
    size_t cbCrOffset = NSSwapBigIntToHost(planar->componentInfoCbCr.offset);
    // CbCr分量上这个平面 内存地址
    uint8_t *cbCrBuffer = baseAddress + cbCrOffset;
    
    CGSize size = CGSizeMake(width_t, height_t);
    CGRect effectRect = [RectManager getEffectImageRect:size];
    //引导认证区域的范围
    CGRect rect = [RectManager getGuideFrame:effectRect];
    //对数据进行向上取整
    int width = ceilf(width_t);
    int height = ceilf(height_t);
    
    unsigned char result [512];
    int resultLen = BankCardNV12(result, 512, pixelAddress, cbCrBuffer, width, height, rect.origin.x, rect.origin.y, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
    
    if(resultLen > 0) {
        
        int charCount = [RectManager docode:result len:resultLen];
        if(charCount > 0) {
            CGRect subRect = [RectManager getCorpCardRect:width height:height guideRect:rect charCount:charCount];
            self.isHasResult = YES;
            //将捕获到缓存数据转化为图片
            UIImage *image = [UIImage getImageStream:imageBuffer];
            //截取银行卡区域的图像
            __block UIImage *subImg = [UIImage getSubImage:rect inImage:image];
            //获取银行卡上的所有字符
            char *numbers = [RectManager getNumbers];
            //获取银行卡号
            NSString *numberStr = [NSString stringWithCString:numbers encoding:NSASCIIStringEncoding];
            //匹配银行卡名
            NSString *bank = [BankCardSearch getBankNameByBin:numbers count:charCount];
            
            NSMutableDictionary * resultDic = [NSMutableDictionary dictionary];
            [resultDic setValue:numberStr forKey:@"bankNumber"];
            [resultDic setValue:bank forKey:@"bankName"];
            [resultDic setValue:image forKey:@"bankImage"];
            
            YXBankCardModel * bankCardM = [[YXBankCardModel alloc]init];
            bankCardM.bankName = bank;
            bankCardM.bankNumber = numberStr;
            bankCardM.bankImage = subImg;

            dispatch_async(dispatch_get_main_queue(), ^{
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                if (self.bankCardesult) {
                    self.bankCardesult(bankCardM);
                }
            });
        }
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    self.isInProcessing = NO;
}

- (void)parseIDCardImageBuffer:(CVImageBufferRef)imageBuffer {
    
    YXScanResultModel *idInfo = nil;
    
    size_t width= CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);
    size_t rowBytes = NSSwapBigIntToHost(planar->componentInfoY.rowBytes);
    unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
    unsigned char* pixelAddress = baseAddress + offset;
    
    static unsigned char *buffer = NULL;
    if (buffer == NULL) {
        buffer = (unsigned char*)malloc(sizeof(unsigned char) * width * height);
    }
    memcpy(buffer, pixelAddress, sizeof(unsigned char) * width * height);
    
    unsigned char pResult[1024];
    int ret = EXCARDS_RecoIDCardData(buffer, (int)width, (int)height, (int)rowBytes, (int)8, (char*)pResult, sizeof(pResult));
    if (ret <= 0) {
        //        NSLog(@"ret=[%d]", ret);
    }
    else {
        NSLog(@"ret=[%d]", ret);
        char ctype;
        char content[256];
        int xlen;
        int i = 0;
        
        idInfo = [YXScanResultModel new];
        ctype = pResult[i++];
        idInfo.type = ctype;
        while(i < ret){
            ctype = pResult[i++];
            for(xlen = 0; i < ret; ++i){
                if(pResult[i] == ' ') { ++i; break; }
                content[xlen++] = pResult[i];
            }
            content[xlen] = 0;
            if(xlen) {
                NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                if(ctype == 0x21)
                    idInfo.code = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                else if(ctype == 0x22)
                    idInfo.name = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                else if(ctype == 0x23)
                    idInfo.gender = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                else if(ctype == 0x24)
                    idInfo.nation = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                else if(ctype == 0x25)
                    idInfo.address = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                else if(ctype == 0x26)
                    idInfo.issue = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                else if(ctype == 0x27)
                    idInfo.valid = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
            }
        }
        
        static YXScanResultModel *lastIdInfo = nil;
        if (lastIdInfo == nil) {
            lastIdInfo = idInfo;
            idInfo = nil;
        }
        else{
            if (![lastIdInfo isEqual:idInfo]){
                lastIdInfo = idInfo;
                idInfo = nil;
            }
        }
        if ([lastIdInfo isOK]) {
            NSLog(@"%@", [lastIdInfo toString]);
        } else {
            idInfo = nil;
        }
    }
    if (idInfo != nil) {
        CGSize size = CGSizeMake(width, height);
        CGRect effectRect = [RectManager getEffectImageRect:size];
        CGRect rect = [RectManager getGuideFrame:effectRect];
        UIImage *image = [UIImage getImageStream:imageBuffer];
        UIImage *subImg = [UIImage getSubImage:rect inImage:image];
        idInfo.idImage = subImg;
        dispatch_async(dispatch_get_main_queue(), ^{
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
        });
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    self.isInProcessing = NO;
}

#endif
@end
