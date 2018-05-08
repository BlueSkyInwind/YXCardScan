//
//  YX_BankCardScanManager.m
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/11/9.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "YX_BankCardScanManager.h"
#import "YXBankSacnViewController.h"
@interface YX_BankCardScanManager ()
@property (nonatomic,strong)YXBankSacnViewController * bankScanVC;

@end

@implementation YX_BankCardScanManager

static YX_BankCardScanManager * scanManager = nil;
static dispatch_once_t onceToken;
+(YX_BankCardScanManager *)shareInstance
{
    dispatch_once(&onceToken, ^{
        scanManager = [[YX_BankCardScanManager alloc]init];
    });
    return scanManager;
}
+(void)relaseSelf{
    scanManager = nil;
    onceToken = 0l;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self initNav];
    }
    return self;
}

-(void)initNav{
    
    _bankScanVC = [[YXBankSacnViewController alloc]init];
    _nagavigationVC = [[YX_NagavigationViewController alloc]initWithRootViewController:_bankScanVC];

}

-(void)CardStart:(UIViewController *)viewController finish:(ScanResultBlock)finish{
    if (_isPush) {
        [viewController.navigationController pushViewController:_bankScanVC animated:true];
    }else{
        [viewController presentViewController:_nagavigationVC animated:true completion:^{
        }];
    }
    self.scanResultBlock = finish;
}
















@end
