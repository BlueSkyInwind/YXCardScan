//
//  YXBankCardModel.h
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/11/9.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YXBankCardModel : NSObject

@property (nonatomic, copy) NSString *bankNumber;

@property (nonatomic, copy) NSString *bankName;

@property (nonatomic, strong) UIImage *bankImage;

@end
