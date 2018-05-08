//
//  YXScanResultViewController.m
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/11/14.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "YXScanResultViewController.h"

@interface YXScanResultViewController ()
@property (weak, nonatomic) IBOutlet UILabel *bankNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bankImage;

@end

@implementation YXScanResultViewController

- (instancetype)init {

    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"YXLibraryResource" ofType:@"bundle"]];
    self = [super initWithNibName:@"YXScanResultViewController" bundle:bundle];
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"扫描结果";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName, nil];
    
    self.bankNameLabel.text = self.bankCardModel.bankName;
    self.bankNumLabel.text = self.bankCardModel.bankNumber;
    self.bankImage.image = self.bankCardModel.bankImage;
    
    [self addBackItem:[YX_BankCardScanManager shareInstance].backImageName];
}

-(void)configureView{
    
    
}
- (IBAction)sureClick:(id)sender {
    [YX_BankCardScanManager shareInstance].resultModel = self.bankCardModel;
    if ( [YX_BankCardScanManager shareInstance].scanResultBlock) {
        [YX_BankCardScanManager shareInstance].scanResultBlock(self.bankCardModel);
        if ([YX_BankCardScanManager shareInstance].isPush) {
            [self.navigationController popToRootViewControllerAnimated:true];
        }else{
            [self.navigationController dismissViewControllerAnimated:true completion:nil];
        }
    }
}

- (void)addBackItem:(NSString *)imageName
{
    
    if (@available(iOS 11.0, *)) {
        UIBarButtonItem *aBarbi = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(popBack)];
        self.navigationItem.leftBarButtonItem = aBarbi;
        return;
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *img = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [btn setImage:img forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 45, 44);
    [btn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    //    修改距离,距离边缘的
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -15;
    self.navigationItem.leftBarButtonItems = @[spaceItem,item];
 
}
-(void)popBack
{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)completeScan{
    [YX_BankCardScanManager shareInstance].resultModel = self.bankCardModel;
    [YX_BankCardScanManager shareInstance].scanResultBlock(self.bankCardModel);
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
