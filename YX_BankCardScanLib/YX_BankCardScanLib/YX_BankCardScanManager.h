//
//  YX_BankCardScanManager.h
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/11/9.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YX_NagavigationViewController.h"
#import "YXBankCardModel.h"

typedef  void (^ScanResultBlock)(YXBankCardModel * _Nonnull model);
@interface YX_BankCardScanManager : NSObject

@property(nonatomic,strong)YXBankCardModel * _Nonnull resultModel;

@property(nonatomic,copy)ScanResultBlock _Nullable scanResultBlock;

@property(nonatomic,strong)YX_NagavigationViewController * _Nullable nagavigationVC;

@property(nonatomic,strong)NSString * _Nullable backImageName;

@property(nonatomic,assign)BOOL isPush;

+(YX_BankCardScanManager *_Nullable)shareInstance;

+(void)relaseSelf;

- (void)CardStart:(nonnull UIViewController *)viewController
           finish:(void(^ _Nullable)(YXBankCardModel * _Nullable result))finish;

@end




