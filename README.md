# TransformWebPageToPDF
将web网页保存为pdf文件

序言：Extension是iOS 8中引入的一个非常重要的新特性,这里记录一次action extension的集成过程。该action extension是把web网页转换成pdf文档并保存到我们自己的App中，功能跟苹果原生的把网页保存pdf到ibooks一样。
下载Demo-[github地址](https://github.com/yehkong/TransformWebPageToPDF)

集成过程：
* 1.File -->New -->Target
> ![new target.png](http://upload-images.jianshu.io/upload_images/2737326-1640d226b13db0bc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* 2.填好名字等候点击next，下图为action extension目录结构
> ![dirStructure.png](http://upload-images.jianshu.io/upload_images/2737326-7e7e6cd4fcf443e1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* 3.这里有几个主要涉及的类，这个方法处理寄主程序（这里为safari）传过来的数据
> ![viewDidLoad.png](http://upload-images.jianshu.io/upload_images/2737326-e8d30550b2458c53.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
> * NSExtensionContext 扩展上下文；对应self(viewController)的extensionContext(NSExtensionContext)属性。
> * NSExtensionItem 扩展的项目内容；对应extensionContext的inputItems属性，这是个数组。
> * NSItemProvider 项目的提供者抽象化；通过extensionItem的attachments属性或者，这也是个数组。
> * 通过NSItemProvider的实例方法获得具体的项目数据。
```
 -(void)loadItemForTypeIdentifier:(NSString *)typeIdentifier options:(nullable NSDictionary *)options completionHandler:(nullable NSItemProviderCompletionHandler)completionHandler;
```
* 4.完善extension UI界面设计。
> ![StoryBoard.png](http://upload-images.jianshu.io/upload_images/2737326-4786b3d7ca53af82.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* 5.设置App Group Capability,这个是在app和app之间共享数据的区域，是沙盒机制的补充。
> ![appgroup.png](http://upload-images.jianshu.io/upload_images/2737326-f20916d0b59053f5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* 6.在App Group中进行数据的处理和存取，已到达数据的共享和传输。

```
-(IBAction)saveToPdf:(UIBarButtonItem *)sender {
    self.coverView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.2];
    self.coverView.hidden = NO;

    NSUserDefaults * extensionDefault = [[NSUserDefaults alloc]initWithSuiteName:@"group.yehkong"];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HHmmss"];
    NSString * fileName = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString * ktitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    fileName = [NSString stringWithFormat:@"%@-%@",ktitle,fileName];
    
    NSDictionary * infoDict = [[NSDictionary alloc]initWithObjectsAndKeys:fileName, @"fileName", nil];
    NSMutableArray * mutableArray = [[extensionDefault objectForKey:@"infos"]mutableCopy];
    if (!mutableArray) {
        mutableArray = [NSMutableArray array];
    }

    [mutableArray addObject:infoDict];
    [extensionDefault setObject:[mutableArray copy] forKey:@"infos"];
    [extensionDefault synchronize];
   
    NSData * data = [self.webView pdfDataWithSize:kPaperSizeA4];

    NSURL * storeUrl = [[NSFileManager defaultManager]containerURLForSecurityApplicationGroupIdentifier:@"group.yehkong"];
    NSURL * fileUrl = [storeUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.PDF",fileName]];
    if (data) {
        [data writeToURL:fileUrl  atomically:YES];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
    });   
 }

```
* 7.设置extension的本地化名字
> ![](http://upload-images.jianshu.io/upload_images/2737326-50587cbcce968670.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* 8.设置extension 的version必须和host app一致。
> ![version.png](http://upload-images.jianshu.io/upload_images/2737326-d3fd14be6bd29919.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

总结：action extension主要的集成步骤就是这些，但是实际运用过程中还有很多小细节，具体参见demo-[github地址](https://github.com/yehkong/TransformWebPageToPDF)，可以直接拖入项目简单配置就可以使用该功能。
