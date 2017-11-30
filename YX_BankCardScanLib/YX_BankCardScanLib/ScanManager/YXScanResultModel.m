//
//  YXScanResultModel.m
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/11/1.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "YXScanResultModel.h"

@implementation YXScanResultModel
- (NSString *)toString {
    return [NSString stringWithFormat:@"身份证号:%@\n姓名:%@\n性别:%@\n民族:%@\n地址:%@\n签发机关:%@\n有效期:%@",
            _code, _name, _gender, _nation, _address, _issue, _valid];
}

- (BOOL)isOK {
    if (_code !=nil && _name!=nil && _gender!=nil && _nation!=nil && _address!=nil) {
        if (_code.length>0 && _name.length >0 && _gender.length>0 && _nation.length>0 && _address.length>0) {
            return YES;
        }
    }
    else if (_issue !=nil && _valid!=nil) {
        if (_issue.length>0 && _valid.length >0) {
            return YES;
        }
    }
    return NO;
}
@end
