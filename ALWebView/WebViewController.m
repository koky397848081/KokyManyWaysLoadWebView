//
//  ViewController.m
//  ALWebView
//
//  Created by xujing on 17/2/13.
//  Copyright © 2017年 xujing. All rights reserved.
//

#import "WebViewController.h"
#import <BmobSDK/Bmob.h>
#import <WebKit/WebKit.h>

@interface WebViewController ()<WKNavigationDelegate,UIWebViewDelegate>
{
    NSString *_htmlContent;
    WKWebView *_webView;
    UIWebView *_uiWebV;
    NSDate* tmpStartData;
    __weak IBOutlet UILabel *timeLabel;
}

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    //创建wkwebView
    _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height - 120)];
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    
    //通过url获取html源码并存到bmob云服务器
    //   [self creatHtmlWithUrlString:@"https://www.liyi.top/front/info/58981ff49fe680cc03f4f376/app/content.html"];
    
    //设置时间统计开始
    tmpStartData = [NSDate date];
    
    //查找GameScore表，获取html源码
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"WebData"];
    //查找GameScore表里面id为0c6db13c的数据
    [bquery getObjectInBackgroundWithId:@"76f98d21f5" block:^(BmobObject *object,NSError *error){
        if (error){
            //进行错误处理
        }else{
            if (object) {
                //得到playerName和cheatMode
                NSString *playerName = [object objectForKey:@"WebName"];
                NSString *content = [object objectForKey:@"content"];
                NSLog(@"%@----%@",playerName,content);
                _htmlContent = content;
            }
        }
    }];
}

- (void)creatHtmlWithUrlString:(NSString *)urlString{
    
    NSString * appConnect = [[NSString alloc]
                             initWithContentsOfURL:[NSURL URLWithString:@""]
                             encoding:NSUTF8StringEncoding
                             error:nil];
    
    
    BmobObject *gameScore = [BmobObject objectWithClassName:@"WebData"];
    [gameScore setObject:@"媒体：二月二龙抬头" forKey:@"WebName"];
    [gameScore setObject:appConnect forKey:@"content"];
    [gameScore saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        //进行操作
    }];
}

//方法1.
//读取本地html文件方式：UIWebview
- (IBAction)loadHtmlWithSourceFileInWIthUIWebview:(id)sender {
    tmpStartData = [NSDate date];

    _uiWebV = [[UIWebView alloc]initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height - 120)];
    _uiWebV.delegate = self;
    [self.view addSubview:_uiWebV];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"AskPublishGuard.html"];
    NSString *html = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    [_uiWebV loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];  //UIWebview读取本地
}

//方法2.
//读取本地html文件方式：  WKWebView
- (IBAction)loadHtmlWithSourceFileWithWKWebview:(id)sender {
    tmpStartData = [NSDate date];

        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *filePath = [resourcePath stringByAppendingPathComponent:@"AskPublishGuard.html"];
        NSString *html = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
        [_webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]]; //WKWebview读取本地
}

//方法3.
//通过本地放两部分（大部分）源码，拼接部分网络请求源码
- (IBAction)loadHtmlInterfaceWithAppendHtml:(id)sender {
    tmpStartData = [NSDate date];

    NSString *htmlSting = [NSString stringWithFormat:@"%@%@%@",[self htmlString:@"header.txt"],_htmlContent,[self htmlString:@"footer.txt"]];
    [_webView loadHTMLString:htmlSting baseURL:nil];//WKWebview直接读取html
}

//方法4.
//WKWebview直接读取html
- (IBAction)loadHtmlWithHtmlString:(id)sender {
    tmpStartData = [NSDate date];
        [_webView loadHTMLString:_htmlContent baseURL:nil];
}

//方法5.
//WKWebview读取url
- (IBAction)loadHtmlWithUrlString:(id)sender {
    tmpStartData = [NSDate date];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.liyi.top/front/info/58981ff49fe680cc03f4f376/app/content.html"]];
    [_webView loadRequest:request];
}

//方法6.
//vasSonic
- (IBAction)vasSonicButtonClick:(id)sender {
    tmpStartData = [NSDate date];
    NSString *urlString = @"https://www.liyi.top/front/info/58981ff49fe680cc03f4f376/app/content.html";
    [[SonicClient sharedClient] createSessionWithUrl:urlString withWebDelegate:self];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    if ([[SonicClient sharedClient] sessionWithWebDelegate:self]) {
        [_webView loadRequest:sonicWebRequest(request)];
    }else{
        [_webView loadRequest:request];
    }
}
- (IBAction)cleanCacheButtonClick:(id)sender {
    [[SonicClient sharedClient] clearAllCache];
    [self alertMessage:@"Clear Success!"];
}

- (void)alertMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
    [alert show];
}
//- (void)loadHtmlInterface{
//    //方法1.
//    //两种读取本地html文件方式：UIWebview / WKWebView
//    
//    //    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
//    //    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"AskPublishGuard.html"];
//    //    NSString *html = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    
//    //    [_webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];  //UIWebview读取本地
//    //    [_webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]]; //WKWebview读取本地
//    
//    //方法2.
//    //     [_webView loadHTMLString:_htmlContent baseURL:nil];//WKWebview直接读取html
//    
//    //方法3.
//    // [self loadHtmlWithUrl];//直接加载完整的url来请求
//    
//    //方法4.
//    [self loadHtmlInterfaceWithHeaderAndFooterText];
//}

//根据本地文件拼接完整的html源码
- (NSString *)htmlString:(NSString *)fileNameString{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:fileNameString];
    NSString *html = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return html;
}

- (void)dealloc
{
    [[SonicClient sharedClient] removeSessionWithWebDelegate:self];
}
#pragma mark
#pragma mark WKNavigationDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView{
 
    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    timeLabel.text = [NSString stringWithFormat:@"cost time:%f",deltaTime];

}

#pragma mark
#pragma mark WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
    //    tmpStartData = [NSDate date];//从加载开始计时,不包含请求
    [_uiWebV removeFromSuperview];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    //You code here...
    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    NSLog(@">>>>>>>>>>cost time = %f", deltaTime);
    timeLabel.text = [NSString stringWithFormat:@"cost time:%f",deltaTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Sonic Session Delegate

- (void)sessionWillRequest:(SonicSession *)session
{
//可以在请求发起前同步Cookie等信息
}

- (void)session:(SonicSession *)session requireWebViewReload:(NSURLRequest *)request
{
    [_webView loadRequest:request];
}
/*
- (void)getDiffData:(NSDictionary *)option withCallBack:(JSValue *)jscallback
{
 
    [[SonicClient sharedClient] sonicUpdateDiffDataByWebDelegate:self.owner completion:^(NSDictionary *result) {
 
        NSData *json = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc]initWithData:json encoding:NSUTF8StringEncoding];
        
        JSValue *callback = self.owner.jscontext.globalObject;
        [callback invokeMethod:@"getDiffDataCallback" withArguments:@[jsonStr]];
        
    }];
}
*/
@end
