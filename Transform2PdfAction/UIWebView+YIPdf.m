//
//  UIWebView+YIPdf.m
//  Transform2PdfAction
//
//  Created by Geson on 2017/7/12.
//  Copyright © 2017年 yetaiwen. All rights reserved.
//

#import "UIWebView+YIPdf.h"
#import "UIPrintPageRenderer+YIPdf.h"

@implementation UIWebView (YIPdf)

- (NSData *)pdfDataWithSize:(CGSize)size{
    
    UIPrintPageRenderer * printRenderer = [[UIPrintPageRenderer alloc]init];
    [printRenderer addPrintFormatter:self.viewPrintFormatter startingAtPageAtIndex:0];
    CGRect pagePrintableRect = CGRectMake(10, 10, size.width - 20, size.height -20);
    CGRect contentRect = CGRectMake(0, 0, size.width, size.height);
    [printRenderer setValue:[NSValue valueWithCGRect:pagePrintableRect] forKey:@"printableRect"];
    [printRenderer setValue:[NSValue valueWithCGRect:contentRect] forKey:@"paperRect"];
    return [printRenderer dataFromRender];
    
}

@end
