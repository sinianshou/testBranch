//
//  ViewController.m
//  testBranch
//
//  Created by Easer on 2018/1/31.
//  Copyright © 2018年 Easer. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveViewModel.h>
#import <ReactiveCocoa.h>
//#import <ReactiveObjC.h>
#import <Masonry.h>
#import "PerViewModel.h"

typedef enum {
    ReacTiveTestTypeRACCommand,
    ReacTiveTestTypeCombineLatest
}ReacTiveTestType;

@interface ViewController ()

@property (nonatomic, assign) ReacTiveTestType reacTiveTestType;
@property (nonatomic, strong) PerViewModel *model;

@property (nonatomic, strong) UIButton *bn1;
@property (nonatomic, strong) UIButton *bn2;

@property (nonatomic, strong) RACSignal *s1;
@property (nonatomic, strong) RACSignal *s2;
@property (nonatomic, strong) RACSignal *sC;

@property (nonatomic, strong) id<RACSubscriber> subscriber1;
@property (nonatomic, strong) id<RACSubscriber> subscriber2;
@property (nonatomic, strong) id<RACSubscriber> subscriberC;


@property (nonatomic, strong) RACCommand *bnCommand;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.model = [[PerViewModel alloc] init];
    self.model.str1 = @"0";
    self.model.str2 = @"0";
    self.model.str3 = @"0";
    
    UIButton *bnNum1 = [[UIButton alloc] init];
    self.bn1 = bnNum1;
    bnNum1.backgroundColor = [UIColor blueColor];
    [bnNum1 setTitle:self.model.str1 forState:UIControlStateNormal];
    [self.view addSubview:bnNum1];
    [bnNum1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(50);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
    UIButton *bnNum2 = [[UIButton alloc] init];
    self.bn2 = bnNum2;
    bnNum2.backgroundColor = [UIColor redColor];
    [bnNum2 setTitle:self.model.str2 forState:UIControlStateNormal];
    [self.view addSubview:bnNum2];
    [bnNum2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bnNum1.mas_top);
        make.left.mas_equalTo(bnNum1.mas_right).mas_offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
    
    UILabel *laNum0 = [[UILabel alloc] init];
    laNum0.backgroundColor = [UIColor redColor];
    laNum0.text = @"0";
    [self.view addSubview:laNum0];
    [laNum0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bnNum1.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(bnNum1.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    RAC(laNum0, text) = RACObserve(self, model.str3);
    
    self.reacTiveTestType = ReacTiveTestTypeCombineLatest;
}

-(void)changeToReacTiveTestTypeRACCommand{
    self.bn1.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(UIButton *bn) {
        NSMutableArray *arrM = [NSMutableArray array];
        RACSignal *signalCombine = nil;
        for (int i=0; i<10; ++i) {
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                NSURLSession *session = [NSURLSession sharedSession];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://test-api-shop.9h-sports.com/api/Cart/CartItemListById?nhid=53449f67-895e-46ec-93f3-b069f5be8322&shop_id=3"]];
                NSURLSessionDataTask * dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    [NSThread sleepForTimeInterval:1];
                    NSLog(@"%@ complete before", [NSString stringWithFormat:@"dataTask%d", i]);
                    [subscriber sendNext:[NSString stringWithFormat:@"dataTask%d", i]];
                    [subscriber sendCompleted];
                }];
                [dataTask resume];
                return nil;
            }];
            //            [signal subscribeCompleted:^{
            //                NSLog(@"%@ complete", [NSString stringWithFormat:@"signal%d", i]);
            //            }];
            //            [signal subscribeNext:^(id x) {
            //                NSLog(@"%@ Next, x is %@", [NSString stringWithFormat:@"signal%d", i], x);
            //            }];
            [arrM addObject:signal];
        }
        
        signalCombine = [RACSignal combineLatest:arrM reduce:^id{
            return nil;
        }];
        return signalCombine;
        
    }];
    [_bn1.rac_command setAllowsConcurrentExecution:YES];
    [_bn1.rac_command.executionSignals subscribeNext:^(RACSignal *signal) {
        [signal subscribeCompleted:^{
            NSLog(@"all signal complete");
        }];
        [signal subscribeNext:^(id x) {
            NSLog(@"all signal Next");
        }];
    }];
}

-(void)changeToReacTiveTestTypeCombineLatest{
    
    self.s1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        self.subscriber1 = subscriber;
        return nil;
    }];
    
    [self.s1 subscribeNext:^(id x) {
        NSLog(@"self.s1 subscribeNext1");
    }];
    [self.s1 subscribeCompleted:^{
        NSLog(@"self.s1 subscribeCompleted");
    }];
    self.s2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        self.subscriber2 = subscriber;
        return nil;
    }];
    self.bn1.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(UIButton *bn) {
        self.model.str1 = [NSString stringWithFormat:@"%d", self.model.str1.intValue+1];
        [_bn1 setTitle:self.model.str1 forState:UIControlStateNormal];
        [self.subscriber1 sendNext:self.model.str1];
        
        return [RACSignal empty];
    }];
    [_bn1.rac_command setAllowsConcurrentExecution:YES];
    [_bn1.rac_command.executionSignals subscribeNext:^(RACSignal *signal) {
    }];
    
    self.bn2.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(UIButton *bn) {
        self.model.str2 = [NSString stringWithFormat:@"%d", self.model.str2.intValue+1];
        [_bn2 setTitle:self.model.str2 forState:UIControlStateNormal];
        [self.subscriber1 sendNext:self.model.str2];
        return [RACSignal empty];
    }];
    [_bn2.rac_command setAllowsConcurrentExecution:YES];
    [_bn2.rac_command.executionSignals subscribeNext:^(id x) {
    }];
    //    self.s1 = RACObserve(self, model.str1);
    //    self.s2 = RACObserve(self, model.str2);
    
    self.sC = [RACSignal combineLatest:@[RACObserve(self, model.str1), RACObserve(self, model.str2)] reduce:^id (NSString *str1, NSString *str2){
        return [NSString stringWithFormat:@"%d", str1.intValue + str2.intValue];
    }];
    [self.sC subscribeNext:^(NSString *str3) {
        self.model.str3 = str3;
        NSLog(@"sC = %@",str3);
    }];
}

-(void)setReacTiveTestType:(ReacTiveTestType)reacTiveTestType{
    _reacTiveTestType = reacTiveTestType;
    switch (_reacTiveTestType) {
        case ReacTiveTestTypeRACCommand:
            [self changeToReacTiveTestTypeRACCommand];
            break;
        case ReacTiveTestTypeCombineLatest:
            [self changeToReacTiveTestTypeCombineLatest];
            break;
            
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
