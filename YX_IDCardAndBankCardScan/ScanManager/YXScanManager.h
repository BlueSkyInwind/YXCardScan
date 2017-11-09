//
//  YXScanManager.h
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/10/30.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "YXBaseScanManager.h"
#import "YXScanResultModel.h"
#import "YXBankCardModel.h"

@interface YXScanManager : YXBaseScanManager

#pragma mark - 银行卡
- (BOOL)configBankScanManager;

#pragma mark - 身份证
- (BOOL)configIDScanManager;

#pragma mark - 配置初始化

-(BOOL)configureSession;

- (void)doSomethingWhenWillDisappear;

- (void)doSomethingWhenWillAppear;

-(void)resetParams;

@end
