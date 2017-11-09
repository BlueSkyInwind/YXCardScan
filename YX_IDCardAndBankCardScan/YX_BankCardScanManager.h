//
//  YX_BankCardScanManager.h
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/11/9.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#
typedef void (^ScanResultBuffer)(id imageBuffer) ;

@interface YX_BankCardScanManager : NSObject

- (void)CardStart:(nonnull UIViewController *)viewController
           finish:(void(^ _Nullable)(MGBankCardModel * _Nullable result))finish;



@end
