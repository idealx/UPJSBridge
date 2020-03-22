# NSURLProtocol WebView Javascript Bridge

基于 NSURLProtocol 实现的 Javascript 与 Native 通信，适用于 iOS Native 端为 Javascript 提供统一的 API，主要特点：

- 全局统一拦截，对于 WebView 相关 Controller 的代码无入侵
- 同时支持 UIWebView 和 WKWebView
- 支持 Javascript 端发起的自定义 URL Scheme 和 AJAX 两种请求的方式
- 支持 iOS 8.4+

## 使用方法

进入 Pages 目录，通过 Python 建一个临时的 HTTP Server：
```shell
cd Pages
python -m SimpleHTTPServer
```

运行项目即可在模拟器中看到 Demo 的效果。
个人不喜欢过渡封装，项目实现了通信的核心流程，代码不多，建议理解后按业务需求做相应调整后使用。

### 代码示例

把项目中 UPJSBridge 文件夹引入到现有工程。

#### 全局注册
在 AppDelegate 中注册 NSURLProtocol 子类：
```objc
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [UPJSBridge start];
    
    return YES;
}

@end
```
#### 只在某个 Controller 中注册
```objc
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UPJSBridge start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UPJSBridge stop];
}
```

Native 端在 JSDataAPI 中实现提供给 Javascript 的方法：
```objc
+ (NSDictionary *)api_version:(NSDictionary *)param {
    return @{@"code": @0, @"version": @"0.1"};
}
```

JS 侧如果使用 URL Scheme 方式的调用，需要通过 WebView 回调数据，所以需要额外的绑定 WebView，在 WebView 相关的 Controller 中：
```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [UPJSBridge bridgeWidthWebView:_webView];
	...
}
```

#### Javascript 调用相应的 Native API

页面引入Pages/UPJSBridge.js，通过以下两种方式调用 Native：

URL Scheme 方式
```javascript
UPJSBridge.callNativeByURL({
  api: 'version',
  params: {
    foo: 'bar'
  },
  callback: function(data) {
    // data: {"code": 0, "version": "0.1"}
  }
});
```
AJAX 请求方式
```javascript
UPJSBridge.callNativeByURL({
  api: 'fooDemo',
  params: {
    foo: 'bar'
  },
  callback: function(data) {
    // data: {"code": 0, "version": "0.1"}
  }
});
```

### 关于模块化
Demo 项目里简单使用 runtime 实现了 API 的分模块实现，统一的 API 在 JSDataAPI 中实现，项目中不同模块提供给 JS 的 API 可通过给 JSDataAPI 加 Category 的方式实现，可参见项目中的 JSDataAPI+ModuleFoo。

### 注意事项
* NSURLProtocol 默认不支持拦截 WKWebView 的请求，需要用到私有 API，可能有一定兼容性及审核的风险，具体参见 [NSURLProtocol-WebKitSupport](https://github.com/yeatse/NSURLProtocol-WebKitSupport)
* 如果 App 内有多个 NSURLProtocol 子类，最后注册的子类最新调用，此时需要统一规划 NSURLProtocol 的注册及使用