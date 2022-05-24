import 'package:dio/dio.dart';
import 'dart:convert' as convert;
import 'package:flutter_demo/utils/toast.dart';

class HttpUtil {
  factory HttpUtil() => getInstance();
  static HttpUtil? instance;
  static Dio? dio;
  static BaseOptions? options;

  CancelToken cancelToken = CancelToken();

  HttpUtil._internal(){
    //BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    options = BaseOptions(
      //请求基地址,可以包含子路径
      baseUrl: '',
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: 10000,
      //响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: 5000,
      //Http请求头.
      headers: {},
      //请求的Content-Type，默认值是[ContentType.json]. 也可以用ContentType.parse("application/x-www-form-urlencoded")
      // contentType: 'ContentType.json',
      //表示期望以那种格式(方式)接受响应数据。接受三种类型 `json`, `stream`, `plain`, `bytes`. 默认值是 `json`,
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    //Cookie管理
    // dio.interceptors.add(CookieManager(CookieJar()));

    //添加拦截器
    dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: ( // 请求之前
            RequestOptions options,
            RequestInterceptorHandler handler,) =>
            requestInterceptor(options, handler),
        onResponse: ( // 响应之前
            Response response,
            ResponseInterceptorHandler handler,) =>
            responseInterceptor(response, handler),
        onError: ( // 错误之
            DioError err,
            ErrorInterceptorHandler handler,) =>
            errorInterceptor(err, handler),
      ),
    );
  }

  static getInstance() {
    instance ??= HttpUtil._internal();
    return instance;
  }

  static requestInterceptor(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    // if (options.path != '/user/login') {
    //   print('token ${Store.userStore.token}');
    //   options.headers.addAll({'token': Store.userStore.token});
    // }
    handler.next(options);
  }
  static responseInterceptor(
      Response response,
      ResponseInterceptorHandler handler,
      ) async {
    if (response.data['code'] == 500) {
      print('ERROR URL: ${response.realUri}');
      print('ERROR response.data: ${response.data}');
      AlertUtil.toast(response.data['msg']);
      handler.reject(DioError(error: response, requestOptions: Map as RequestOptions));
    } else {
      handler.next(response);
    }
  }
  static errorInterceptor(
      DioError err,
      ErrorInterceptorHandler handler,
      ) async {
    print('errorInterceptor: $err');
    handler.next(err);
  }

  /*
   * get请求
   */
  get(url, {data, headers, cancelToken}) async {
    Response? response;
    try {
      print('get请求-----$url ${convert.jsonEncode(data)}');
      response = await dio?.get(url,
          queryParameters: {...data}, options: Options(headers:headers), cancelToken: cancelToken);
      print('get success------${url} --${response?.data}');
      if(response?.statusCode!=200){
        AlertUtil.toast("请求失败，请刷新重试");
        return {};
      }
//    response.data; 响应体
//    response.headers; 响应头
//    response.request; 请求体
//    response.statusCode; 状态码
      return response?.data;
    } on DioError catch (e) {
      print('get error---------$e');
      formatError(e);
    }
  }

  /*
   * post请求
   */
  post(url, {data, headers, cancelToken}) async {
    Response? response;
    try {
      print('post请求-----$url ${convert.jsonEncode(data)}');
      response = await dio?.post(url,
          data: data, options: Options(headers:headers), cancelToken: cancelToken);
      if(response?.statusCode!=200){
        AlertUtil.toast("请求失败，请刷新重试");
        return {};
      }
      print('post success------$url --${response?.data}');
      return response?.data;
    } on DioError catch (e) {
      print('post error---------$e');
      formatError(e);
    }
  }

  /*
   * 下载文件
   */
  downloadFile(urlPath, savePath) async {
    Response? response;
    try {
      response = await dio?.download(urlPath, savePath,
          onReceiveProgress: (int count, int total) {
            //进度
            print("$count $total");
          });
      print('downloadFile success---------${response?.data}');
      return response?.data;
    } on DioError catch (e) {
      print('downloadFile error---------$e');
      formatError(e);
    }
  }

  /*
   * error统一处理
   */
  static void formatError(DioError e) {
    print('e.type');
    if (e.type == DioErrorType.connectTimeout) {
      // It occurs when url is opened timeout.
      AlertUtil.toast("连接超时");
    } else if (e.type == DioErrorType.sendTimeout) {
      // It occurs when url is sent timeout.
      AlertUtil.toast("请求超时");
    } else if (e.type == DioErrorType.receiveTimeout) {
      //It occurs when receiving timeout
      AlertUtil.toast("响应超时");
    } else if (e.type == DioErrorType.response) {
      // When the server response, but with a incorrect status, such as 404, 503...
      AlertUtil.toast("出现异常");
    } else if (e.type == DioErrorType.cancel) {
      // When the request is cancelled, dio will throw a error with this type.
      AlertUtil.toast("请求取消");
    } else {
      //DEFAULT Default error type, Some other Error. In this case, you can read the DioError.error if it is not null.
      AlertUtil.toast("未知错误");
    }
  }

  /*
   * 取消请求
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }
}
