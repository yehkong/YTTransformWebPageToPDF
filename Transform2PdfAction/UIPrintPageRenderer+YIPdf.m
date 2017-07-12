//
//  UIPrintPageRenderer+YIPdf.m
//  Transform2PdfAction
//
//  Created by Geson on 2017/7/12.
//  Copyright © 2017年 yetaiwen. All rights reserved.
//

#import "UIPrintPageRenderer+YIPdf.h"

@implementation UIPrintPageRenderer (YIPdf)

- (NSData *)dataFromRender{
    NSMutableData * pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, self.paperRect, nil);
    [self prepareForDrawingPages:NSMakeRange(0, self.numberOfPages)];
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    NSUInteger page = self.numberOfPages;
    for (int i = 0;i < page;i++) {
        UIGraphicsBeginPDFPage();
        [self drawPageAtIndex:i inRect:bounds];
    }
    UIGraphicsEndPDFContext();
    return pdfData;
}

@end
