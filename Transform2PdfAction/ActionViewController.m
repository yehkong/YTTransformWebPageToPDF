//
//  ActionViewController.m
//  Transform2PdfAction
//
//  Created by Geson on 2017/7/12.
//  Copyright © 2017年 yetaiwen. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIWebView+YIPdf.h"

#define kPaperSizeA4 CGSizeMake(595.2,841.8)

@interface ActionViewController ()<UIWebViewDelegate>
{
    BOOL _isSuccessful;
}
@property (weak, nonatomic) IBOutlet UIWebView *webPageView;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UILabel *succLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;


@end

@implementation ActionViewController

- (IBAction)SaveToHD:(UIBarButtonItem *)sender {
    if (!_isSuccessful) {
        self.succLabel.text = @"FAIL";
    }
    self.coverView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.2];
    self.coverView.hidden = NO;
    
    
    NSUserDefaults * extensionDefault = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.0101.yetaiwen.Transform2PdfHostApp.Transform2PdfAction"];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HHmmss"];
    NSString * fileName = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString * ktitle = [self.webPageView stringByEvaluatingJavaScriptFromString:@"document.title"];
    fileName = [NSString stringWithFormat:@"%@-%@",ktitle,fileName];
    
    NSDictionary * infoDict = [[NSDictionary alloc]initWithObjectsAndKeys:fileName, @"fileName", nil];
    NSMutableArray * mutableArray = [[extensionDefault objectForKey:@"infos"]mutableCopy];
    if (!mutableArray) {
        mutableArray = [NSMutableArray array];
    }
    
    [mutableArray addObject:infoDict];
    
    
    [extensionDefault setObject:[mutableArray copy] forKey:@"infos"];
    [extensionDefault synchronize];
    
    NSData * data = [self.webPageView pdfDataWithSize:kPaperSizeA4];
    
    NSURL * storeUrl = [[NSFileManager defaultManager]containerURLForSecurityApplicationGroupIdentifier:@"group.com.0101.yetaiwen.Transform2PdfHostApp.Transform2PdfAction"];
    NSURL * fileUrl = [storeUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.PDF",fileName]];
    if (data) {
        [data writeToURL:fileUrl  atomically:YES];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
        if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"yehkong://"]]) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"yehkong://"] options:@{} completionHandler:nil];
        }
    });
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webPageView.delegate = self;
    self.coverView.hidden = YES;
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    
    __weak typeof(self) weakSelf = self;
    BOOL urlFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                // This is an image. We'll load it, then place it in our image view.
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
                    if(url) {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [weakSelf.webPageView loadRequest:[NSURLRequest requestWithURL:url]];
                            [weakSelf.activityView startAnimating];
                        }];
                    }
                }];
                
                urlFound = YES;
                break;
            }
        }
        
        if (urlFound) {
            // We only handle one image, so stop looking for more.
            break;
        }
    }
    
}
#pragma mark - uiwedviewdelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
    _isSuccessful = YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
    self.succLabel.numberOfLines = 0;
    self.succLabel.text = [NSString stringWithFormat:@"Fail!%@",error.localizedDescription];
    self.coverView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.2];
    self.coverView.hidden = NO;
    _isSuccessful = NO;
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
    //    });
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
    
}

@end
