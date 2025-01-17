//
//  NativeAdSample2ViewController.m
//  ios-sdk-demo
//
//  Created by DaidoujiChen on 2016/5/24.
//  Copyright © 2016年 DaidoujiChen. All rights reserved.
//

#import "NativeAdSample2ViewController.h"
#import "SampleView2.h"

@interface NativeAdSample2ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) VANativeAd *nativeAd;
@property (nonatomic, strong) SampleView2 *adView;
@property (nonatomic, assign) BOOL isAdReady;

// dummy data
@property (nonatomic, strong) NSArray<NSString *> *titles;

@end

@implementation NativeAdSample2ViewController

#pragma mark - VANativeAdDelegate

- (void)nativeAdDidLoad:(VANativeAd *)nativeAd {
    VANativeAdViewRender *render;
    if (!self.adView) {
        render = [[VANativeAdViewRender alloc] initWithNativeAd:nativeAd customizedAdViewClass:[SampleView2 class]];
    }
    else {
        render = [[VANativeAdViewRender alloc] initWithNativeAd:nativeAd customAdView:self.adView];
    }
    
    __weak NativeAdSample2ViewController *weakSelf = self;
    [render renderWithCompleteHandler: ^(UIView<VANativeAdViewRenderProtocol> *view, NSError *error) {
        
        if (!error) {
            weakSelf.adView = (SampleView2 *)view;
            weakSelf.adView.onClose = ^{
                [weakSelf hideAd];
            };
        }
        else {
            NSLog(@"Error : %@", error);
        }
        weakSelf.isAdReady = (error == nil);
        [weakSelf.tableView reloadData];
    }];
}

- (void)nativeAd:(VANativeAd *)nativeAd didFailedWithError:(NSError *)error {
    NSLog(@"%s %@", sel_getName(_cmd), error);
}

- (void)nativeAdDidClick:(VANativeAd *)nativeAd {
    NSLog(@"%s", sel_getName(_cmd));
}

- (void)nativeAdDidFinishHandlingClick:(VANativeAd *)nativeAd {
    NSLog(@"%s", sel_getName(_cmd));
}

-(void)nativeAdBeImpressed:(VANativeAd *)nativeAd {
    NSLog(@"%s", sel_getName(_cmd));
}

- (void)nativeAdDidFinishImpression:(VANativeAd *)nativeAd {
    NSLog(@"%s", sel_getName(_cmd));
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count + self.isAdReady;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    if (self.isAdReady && indexPath.row == 0) {
        cell.textLabel.text = self.adView.titleLabel.text;
    }
    else {
        cell.textLabel.text = self.titles[indexPath.row - self.isAdReady];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isAdReady && indexPath.row == 0) {
        [self showAd];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"點到了" message:self.titles[indexPath.row - self.isAdReady] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Private Instance Method

- (void)loadNativaAd {
    self.nativeAd = [[VANativeAd alloc] initWithPlacement:@"VMFiveAdNetwork_NativeAdSample2" adType:kVAAdTypeVideoCard];
    self.nativeAd.testMode = YES;
    self.nativeAd.apiKey = @"YOUR API KEY HERE";
    self.nativeAd.delegate = self;
    [self.nativeAd loadAd];
}

- (void)showAd {
    [self.view addSubview:self.adView];
    
    // autolayout 設定, 固定大小, 水平垂直置中
    self.adView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.adView addConstraint:[NSLayoutConstraint constraintWithItem:self.adView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:CGRectGetWidth(self.adView.bounds)]];
    [self.adView addConstraint:[NSLayoutConstraint constraintWithItem:self.adView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:CGRectGetHeight(self.adView.bounds)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.adView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.adView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0]];
    [self.view layoutIfNeeded];
    
    __weak NativeAdSample2ViewController *weakSelf = self;
    self.adView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
    [UIView animateWithDuration:0.15f animations: ^{
        weakSelf.adView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2f, 1.2f);
    } completion: ^(BOOL finished) {
        [UIView animateWithDuration:0.15f animations: ^{
            weakSelf.adView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
        } completion: ^(BOOL finished) {
        }];
    }];
}

- (void)hideAd {
    __weak NativeAdSample2ViewController *weakSelf = self;
    [UIView animateWithDuration:0.15f animations: ^{
        weakSelf.adView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2f, 1.2f);
    } completion: ^(BOOL finished) {
        [UIView animateWithDuration:0.15f animations: ^{
            weakSelf.adView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.2f, 0.2f);
        } completion: ^(BOOL finished) {
            [weakSelf.adView removeFromSuperview];
            [weakSelf.nativeAd loadAd];
        }];
    }];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"NativeAdSample2";
    
    // init values
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.isAdReady = NO;
    self.titles = @[ @"第四集", @"第三集", @"第二集", @"第一集"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadNativaAd];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.nativeAd unloadAd];
}

@end
