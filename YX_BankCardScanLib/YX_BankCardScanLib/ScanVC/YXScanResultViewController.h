//
//  YXScanResultViewController.h
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/11/14.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXBankCardModel.h"
#import "YX_BankCardScanManager.h"
#import "UIImage+Extend.h"
@interface YXScanResultViewController : UIViewController

@property (nonatomic,strong)YXBankCardModel * bankCardModel;
@end
