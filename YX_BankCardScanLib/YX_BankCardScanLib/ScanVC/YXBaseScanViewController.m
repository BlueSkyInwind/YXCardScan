//
//  YXBaseScanViewController.m
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/10/31.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "YXBaseScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Extend.h"

@interface YXBaseScanViewController ()
// 是否打开手电筒
@property (nonatomic,assign,getter = isTorchOn) BOOL torchOn;
@end

@implementation YXBaseScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addBackItem:[YX_BankCardScanManager shareInstance].backImageName];
    [self addRightItem];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
}
- (void)addBackItem:(NSString *)imageName
{
    if (@available(iOS 11.0, *)) {
        UIBarButtonItem * aBarbi = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:imageName] imageWithTintColor:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(popBack)];
        self.navigationItem.leftBarButtonItem = aBarbi;
        return;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *img = [[UIImage imageNamed:imageName] imageWithTintColor:[UIColor whiteColor]];
    [btn setImage:img forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 45, 44);
    [btn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    //    修改距离,距离边缘的
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -15;
    self.navigationItem.leftBarButtonItems = @[spaceItem,item];
    
}
-(void)popBack{
    if ([YX_BankCardScanManager shareInstance].isPush) {
        [self.navigationController popViewControllerAnimated:true];
    }
    else{
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

-(void)addRightItem{
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"YXLibraryResource" ofType:@"bundle"]];
    UIImage *defaultImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"nav_torch_off" ofType:@"png"]];
    UIBarButtonItem *aBarbi = [[UIBarButtonItem alloc]initWithImage:[defaultImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(addTorchOnTorchClick)];
    self.navigationItem.rightBarButtonItem = aBarbi;
    
}

-(void)addTorchOnTorchClick{
    self.torchOn = !self.isTorchOn;
    if (self.isTorchOn) {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"YXLibraryResource" ofType:@"bundle"]];
        UIImage *defaultImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"nav_torch_on" ofType:@"png"]];
        self.navigationItem.rightBarButtonItem.image = [defaultImage originalImage];
        [self.scanManager setFlashMode:AVCaptureTorchModeOn];
    }else{
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"YXLibraryResource" ofType:@"bundle"]];
        UIImage *defaultImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"nav_torch_off" ofType:@"png"]];
        self.navigationItem.rightBarButtonItem.image = [defaultImage originalImage];
        [self.scanManager setFlashMode:AVCaptureTorchModeOff];
    }
}

-(YXScanManager *)scanManager{
    if (!_scanManager) {
        _scanManager = [[YXScanManager alloc]init];
    }
    return _scanManager;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkAuthorizationStatus];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.scanManager doSomethingWhenWillDisappear];
}
#pragma mark - 检测摄像头权限
-(void)checkAuthorizationStatus {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined:[self showAuthorizationNotDetermined]; break;// 用户尚未决定授权与否，那就请求授权
        case AVAuthorizationStatusAuthorized:[self showAuthorizationAuthorized]; break;// 用户已授权，那就立即使用
        case AVAuthorizationStatusDenied:[self showAuthorizationDenied]; break;// 用户明确地拒绝授权，那就展示提示
        case AVAuthorizationStatusRestricted:[self showAuthorizationRestricted]; break;// 无法访问相机设备，那就展示提示
    }
}
#pragma mark 用户还未决定是否授权使用相机
-(void)showAuthorizationNotDetermined {
    __weak __typeof__(self) weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        granted? [weakSelf showAuthorizationAuthorized]: [weakSelf showAuthorizationDenied];
    }];
}
#pragma mark 被授权使用相机
-(void)showAuthorizationAuthorized {
    [self.scanManager doSomethingWhenWillAppear];
}
#pragma mark 未被授权使用相机
-(void)showAuthorizationDenied {
    
    NSString *title = @"相机未授权";
    NSString *message = @"请到系统的“设置-隐私-相机”中授权此应用使用您的相机";
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 跳转到该应用的隐私设授权置界面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertController * alertC =  [UIAlertController alertControllerWithTitle:title message:message okAction:okAction cancelAction:cancelAction];
    [self presentViewController:alertC animated:true completion:nil];
}
#pragma mark 使用相机设备受限
-(void)showAuthorizationRestricted {
    NSString *title = @"相机设备受限";
    NSString *message = @"请检查您的手机硬件或设置";
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
   UIAlertController * alertC =  [UIAlertController alertControllerWithTitle:title message:message okAction:okAction cancelAction:nil];
    [self presentViewController:alertC animated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
