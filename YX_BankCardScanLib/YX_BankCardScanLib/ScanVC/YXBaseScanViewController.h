//
//  YXBaseScanViewController.h
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/10/31.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXScanManager.h"
#import "YX_BankCardScanManager.h"
#import "UIAlertController+Extend.h"
@interface YXBaseScanViewController : UIViewController

@property (nonatomic,strong)YXScanManager * scanManager;

@end
