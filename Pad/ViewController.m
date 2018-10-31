//
//  ViewController.m
//  Pad
//
//  Created by xianjunwang on 2018/10/23.
//  Copyright © 2018年 xianjunwang. All rights reserved.
//

#import "ViewController.h"
//#import "Masonry.h"
#import "GCDAsyncSocket.h"
#import "MBProgressHUD.h"
#import "UIImageAndLabelBtn.h"

#define BUTTONBASETAG 1120

@interface ViewController ()<GCDAsyncSocketDelegate>{
    
    float firstPadding;//一行三个按钮的按钮间距
    float secondPadding;//一行两个按钮的按钮间距
}

//背景imageView
@property (nonatomic,strong) UIImageView * bgImageView;
//环境按钮
@property (nonatomic,strong) UIImageAndLabelBtn * environmentBtn;
//废弃物收集按钮
@property (nonatomic,strong) UIImageAndLabelBtn * wasteCollectionBtn;
//加工配肥按钮
@property (nonatomic,strong) UIImageAndLabelBtn * processingFertilizerBtn;
//养地施用按钮
@property (nonatomic,strong) UIImageAndLabelBtn * landApplicationBtn;
//农品优选按钮
@property (nonatomic,strong) UIImageAndLabelBtn * agriculturalPreferenceBtn;
//销售平台按钮
@property (nonatomic,strong) UIImageAndLabelBtn * salePlatformBtn;
//自动按钮
@property (nonatomic,strong) UIImageAndLabelBtn * autoBtn;
//关机按钮
@property (nonatomic,strong) UIImageAndLabelBtn * closeBtn;
//右上角，长按弹出修改ip地址的view
@property (nonatomic,strong) UIView * longPressView;

// 客户端socket
@property (strong, nonatomic) GCDAsyncSocket * clientSocket;
// 计时器
@property (nonatomic, strong) NSTimer *connectTimer;
//IP地址
@property (nonatomic,strong) NSString * ipStr;

@end

@implementation ViewController

#pragma mark  ----  生命周期函数

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self bindConstraints];
    
    NSString * IPString = [[NSUserDefaults standardUserDefaults] objectForKey:@"IP"];
    if (IPString) {
        
        self.ipStr = IPString;
    }
    else{
        
        self.ipStr = @"192.168.1.11";
        [[NSUserDefaults standardUserDefaults] setObject:self.ipStr forKey:@"IP"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self setSocket];
    [self check];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  ----  代理
#pragma mark  ---- GCDAsyncSocketDelegate
//成功连接主机对应端口号.
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    
    //链接成功
    [MBProgressHUD displayHudError:@"主机连接成功"];
}


//客户端socket断开
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    //断开连接
    self.clientSocket.delegate = nil;
    self.clientSocket = nil;
    [MBProgressHUD displayHudError:@"断开连接"];
}


#pragma mark  ----  自定义函数

-(void)bindConstraints{
    
    firstPadding = (CGRectGetWidth(self.view.frame) - 100 * 3) / 4.0;
    secondPadding = (CGRectGetWidth(self.view.frame) - 100 * 3) / 2.0;
    [self.view addSubview:self.bgImageView];
    [self.bgImageView addSubview:self.longPressView];
    [self.bgImageView addSubview:self.environmentBtn];
    [self.bgImageView addSubview:self.wasteCollectionBtn];
    [self.bgImageView addSubview:self.processingFertilizerBtn];
    [self.bgImageView addSubview:self.landApplicationBtn];
    [self.bgImageView addSubview:self.agriculturalPreferenceBtn];
    [self.bgImageView addSubview:self.salePlatformBtn];
    [self.bgImageView addSubview:self.closeBtn];
    [self.bgImageView addSubview:self.autoBtn];
}

-(void)buttonClicked:(UIControl *)btn{
 
    if (self.clientSocket.isConnected) {
    
        NSString * code;
        switch (btn.tag - BUTTONBASETAG) {
            case 0:
                code = @"AA0100CC";
                break;
            case 1:
                code = @"AA0200CC";
                break;
            case 2:
                code = @"AA0300CC";
                break;
            case 3:
                code = @"AA0400CC";
                break;
            case 4:
                code = @"AA0500CC";
                break;
            case 5:
                code = @"AA0600CC";
                break;
            case 6:
                code = @"AA0700CC";
                break;
            case 7:
                code = @"AA0800CC";
                break;
            default:
                break;
        }
    
        [self sendMessageForservers:code];
    }
    else{

        //未建立socket连接
        [MBProgressHUD displayHudError:@"未建立连接，稍等"];
        [self setSocket];
    }
}

//向服务器发送指令
//传入16进制字符即ke
//处理数据 根据服务器要求 进行转换即可
- (void)sendMessageForservers:(NSString *)message {
    
    NSString *hexString = message; //16进制字符串
    int j=0;
    Byte bytes[4];//根据自己的要求 设置 位数
    
    for(int i=0;i<[hexString length];i++){
        
        int int_ch;  /// 两位16进制数转化后的10进制数
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;  //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        
        i++;
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;
        
        NSLog(@"int_ch=%d",int_ch);
        
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        
        j++;
    }
    
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:4];//length 根据自己要求设置
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    [self.clientSocket writeData:newData withTimeout:- 1 tag:0];
}


//设置socket
-(void)setSocket{
    
    if (!self.clientSocket) {
        
        //创建socket并指定代理对象为self,代理队列必须为主队列.
        self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    if ([self.clientSocket isConnected]) {
        
        [self.clientSocket disconnect];
    }
    
    //连接指定主机的对应端口.
    NSError *error = nil;
    [self.clientSocket connectToHost:self.ipStr onPort:@"333".integerValue viaInterface:nil withTimeout:-1 error:&error];
}

//有效期校验操作，避免被坑
-(void)check{
    
    NSDate * nowDate = [NSDate date];
    //过期时间
    NSString * lastTimeStr = @"2018-11-10";
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * lastTimeDate = [formatter dateFromString:lastTimeStr];
    if ([nowDate compare:lastTimeDate] >= 0) {
        
        self.view.userInteractionEnabled = NO;
        //已过期
        [MBProgressHUD showHUDText:@"您好，您的项目已过试用期，如需继续使用，请联系开发者" forView:self.view animated:YES];
    }
}

//修改IP手势的响应
-(void)modifyIP{
    
    UIAlertController * alertControl = [UIAlertController alertControllerWithTitle:@"请输入IP地址" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertControl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
       
    }];
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField * tf = alertControl.textFields.firstObject;
        if (tf && [tf isKindOfClass:[UITextField class]]) {
            
            NSString * text = tf.text;
            if (text && [text isKindOfClass:[NSString class]] && text.length > 0) {
                
                self.ipStr = text;
                [self setSocket];
                [[NSUserDefaults standardUserDefaults] setObject:self.ipStr forKey:@"IP"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }];
    
    [alertControl addAction:cancleAction];
    [alertControl addAction:sureAction];
    
    
    [self presentViewController:alertControl animated:YES completion:nil];
}

#pragma mark  ----  懒加载
-(UIImageView *)bgImageView{
    
    if (!_bgImageView) {
        
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-image.png"]];
        _bgImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        _bgImageView.userInteractionEnabled = YES;
    }
    return _bgImageView;
}

-(UIImageAndLabelBtn *)environmentBtn{
    
    if (!_environmentBtn) {
        
        _environmentBtn = [[UIImageAndLabelBtn alloc]initWithFrame:CGRectMake(firstPadding, 175, 104, 142.5) andImageViewFrame:CGRectMake(0, 0, 104, 92.5) andLabelFrame:CGRectMake(0, 92.5 + 25, 104, 25) andImageName:@"img1.png" andHeightImageName:@"img1-1.png" andTitle:@"环境"];
        _environmentBtn.tag = BUTTONBASETAG + 2;
        [_environmentBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _environmentBtn;
}


-(UIImageAndLabelBtn *)wasteCollectionBtn{
    
    if (!_wasteCollectionBtn) {
        
        _wasteCollectionBtn = [[UIImageAndLabelBtn alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.environmentBtn.frame) + firstPadding, CGRectGetMinY(self.environmentBtn.frame), 109.5, 143.5) andImageViewFrame:CGRectMake(8, 0, 93.5, 93.5) andLabelFrame:CGRectMake(0, 93.5 + 25, 109.5, 25) andImageName:@"img2.png" andHeightImageName:@"img2-1.png" andTitle:@"废弃物收集"];
        _wasteCollectionBtn.tag = BUTTONBASETAG + 3;
        [_wasteCollectionBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _wasteCollectionBtn;
}

-(UIImageAndLabelBtn *)processingFertilizerBtn{
    
    if (!_processingFertilizerBtn) {
        
        _processingFertilizerBtn = [[UIImageAndLabelBtn alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.wasteCollectionBtn.frame) + firstPadding, CGRectGetMinY(self.environmentBtn.frame), 109.5, 143.5) andImageViewFrame:CGRectMake(8, 0, 93.5, 93.5) andLabelFrame:CGRectMake(0, 93.5 + 25, 109.5, 25) andImageName:@"img3.png" andHeightImageName:@"img3-1.png" andTitle:@"加工配肥"];
        _processingFertilizerBtn.tag = BUTTONBASETAG + 4;
        [_processingFertilizerBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _processingFertilizerBtn;
}

-(UIImageAndLabelBtn *)landApplicationBtn{
    
    if (!_landApplicationBtn) {
        
        _landApplicationBtn = [[UIImageAndLabelBtn alloc] initWithFrame:CGRectMake(firstPadding, CGRectGetMaxY(self.environmentBtn.frame) + 80, 109.5, 143.5) andImageViewFrame:CGRectMake(8, 0, 93.5, 93.5) andLabelFrame:CGRectMake(0, 93.5 + 25, 109.5, 25) andImageName:@"img4.png" andHeightImageName:@"img4-1.png" andTitle:@"养地施用"];
        _landApplicationBtn.tag = BUTTONBASETAG + 5;
        [_landApplicationBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _landApplicationBtn;
}

-(UIImageAndLabelBtn *)agriculturalPreferenceBtn{
    
    if (!_agriculturalPreferenceBtn) {
        
        _agriculturalPreferenceBtn = [[UIImageAndLabelBtn alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.landApplicationBtn.frame) + firstPadding, CGRectGetMinY(self.landApplicationBtn.frame), 109.5, 143.5) andImageViewFrame:CGRectMake(8, 0, 93.5, 93.5) andLabelFrame:CGRectMake(0, 93.5 + 25, 109.5, 25) andImageName:@"img5.png" andHeightImageName:@"img5-1.png" andTitle:@"农品优选"];
        _agriculturalPreferenceBtn.tag = BUTTONBASETAG + 6;
        [_agriculturalPreferenceBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agriculturalPreferenceBtn;
}

-(UIImageAndLabelBtn *)salePlatformBtn{
    
    if (!_salePlatformBtn) {
        
        _salePlatformBtn = [[UIImageAndLabelBtn alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.agriculturalPreferenceBtn.frame) + firstPadding, CGRectGetMinY(self.landApplicationBtn.frame), 109.5, 143.5) andImageViewFrame:CGRectMake(8, 0, 93.5, 93.5) andLabelFrame:CGRectMake(0, 93.5 + 25, 109.5, 25) andImageName:@"img6.png" andHeightImageName:@"img6-1.png" andTitle:@"销售平台"];
        _salePlatformBtn.tag = BUTTONBASETAG + 7;
        [_salePlatformBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _salePlatformBtn;
}

-(UIImageAndLabelBtn *)autoBtn{
    
    if (!_autoBtn) {
        
        _autoBtn = [[UIImageAndLabelBtn alloc] initWithFrame:CGRectMake(secondPadding, CGRectGetMaxY(self.landApplicationBtn.frame) + 80, 109.5, 143.5) andImageViewFrame:CGRectMake(8, 0, 93.5, 93.5) andLabelFrame:CGRectMake(0, 93.5 + 25, 109.5, 25) andImageName:@"img7.png" andHeightImageName:@"img7-1.png" andTitle:@"自动"];
        _autoBtn.tag = BUTTONBASETAG + 1;
        [_autoBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _autoBtn;
}

-(UIImageAndLabelBtn *)closeBtn{
    
    if (!_closeBtn) {
        
        _closeBtn = [[UIImageAndLabelBtn alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.autoBtn.frame) + 100, CGRectGetMinY(self.autoBtn.frame), 109.5, 143.5) andImageViewFrame:CGRectMake(8, 0, 93.5, 93.5) andLabelFrame:CGRectMake(0, 93.5 + 25, 109.5, 25) andImageName:@"img8.png" andHeightImageName:@"img8-1.png" andTitle:@"关机"];
        _closeBtn.tag = BUTTONBASETAG + 0;
        [_closeBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

-(UIView *)longPressView{
    
    if (!_longPressView) {
        
        _longPressView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 100, 0, 100, 100)];
        _longPressView.alpha = 0.1;
        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(modifyIP)];
        [_longPressView addGestureRecognizer:longPress];
    }
    return _longPressView;
}

@end
