//
//  ViewController.m
//  Transform2PdfHostApp
//
//  Created by Geson on 2017/7/12.
//  Copyright © 2017年 yetaiwen. All rights reserved.
//

#import "ViewController.h"
#import <QuickLook/QuickLook.h>

#define PdfsDir [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject]stringByAppendingPathComponent:@"Saved Pdfs"]

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    NSURL *_url;
}
@property (nonatomic,strong) NSMutableArray *pdfData;
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addNewCreatedPdfs];
    [self preParePdfData];
}
- (void)preParePdfData
{
    NSError *err;
    NSArray *contents = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:PdfsDir error:&err];
    if (err) {
        NSLog(@"occur error:%@",err.localizedDescription);
    }else{
        _pdfData = [[NSMutableArray alloc]initWithArray:contents.copy];
        [self.tableView reloadData];
    }
}

- (void)addNewCreatedPdfs
{
    NSUserDefaults * extensionDefault = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.yetaiwen.Transform2PdfHostApp.Transform2PdfAction"];
    NSURL * storeUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.yetaiwen.Transform2PdfHostApp.Transform2PdfAction"];
    if (![[NSFileManager defaultManager]fileExistsAtPath:PdfsDir]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:PdfsDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSArray * dicts = [extensionDefault objectForKey:@"infos"];
    if (dicts) {
        for (NSDictionary * dic in dicts) {
            NSString * fileName = [dic objectForKey:@"fileName"];
            NSString * targetPath = [PdfsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.PDF",fileName]];
            NSURL * targetUrl = [NSURL fileURLWithPath:targetPath];
            NSURL * fileStoreUrl = [storeUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.PDF",fileName]];
            [[NSFileManager defaultManager] copyItemAtURL:fileStoreUrl toURL:targetUrl error:nil];
        }
        [extensionDefault removeObjectForKey:@"infos"];
        
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _pdfData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *filePath = _pdfData[indexPath.row];
    cell.textLabel.text = filePath.lastPathComponent;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _url = [NSURL fileURLWithPath:_pdfData[indexPath.row]];
    
    QLPreviewController *previewController = [[QLPreviewController alloc]init];
    previewController.dataSource = self;
    previewController.delegate = self;
    
    [self.navigationController pushViewController:previewController animated:YES];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return _url;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
