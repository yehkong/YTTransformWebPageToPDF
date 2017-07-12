//
//  UIWebView+YIPdf.h
//  Transform2PdfAction
//
//  Created by Geson on 2017/7/12.
//  Copyright © 2017年 yetaiwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (YIPdf)
- (NSData *)pdfDataWithSize:(CGSize)size;
@end
