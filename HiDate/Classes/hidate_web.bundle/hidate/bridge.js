(function (global, factory) {
    if (typeof module === "object" && typeof module.exports === "object") {
        module.exports = global.document ?
            factory(global, true) :
            function (w) {
                if (!w.document) {
                    throw new Error("HP requires a window with a document");
                }
                return factory(w);
            };
    } else {
        factory(global);
    }

}(typeof window !== "undefined" ? window : this, function (window, noGlobal) {

    /**
     说明:

     JS端有两个默认的Handler
     第一个:HandlerName固定为"btnClickHandler",参数接收一个整型的值(取值为按钮编号).
     即:外壳在用户点击菜单栏中某个按钮时,需要调用callHandler,并把按钮编号作为参数.
     第二个:HandlerName固定为"onResumeHandler",无任何参数
     外壳只需要在本页面打开一个新页面后新页面关闭回到本页面时,去调用这个callHandler

     i开头表示整型
     s开头表示字符串
     e开头表示枚举
     f开头表示方法
     c开头表示一个类型
     b开头表示布尔类型
     */
    var Bridge = (function () {
        var HANDLER_NAME = {
            SET_TITLE: "SET_TITLE",
            CLOSE_PAGE: "CLOSE_PAGE",
            OPEN_PAGE: "OPEN_PAGE",
            UPLOAD_VIDEO: "UPLOAD_VIDEO",
            CLIPBOARD_HANDLER: "CLIPBOARD_HANDLER",
            SHARE_SINGLE:"SHARE_SINGLE",
            SET_NAV_RIGHT_BAR_ITEM:"SET_NAV_RIGHT_BAR_ITEM",
            SHARE_GROUP:"SHARE_GROUP",
            GEOLOCATION_GET_CURRENT_POSITION:"GEOLOCATION_GET_CURRENT_POSITION"
        };

        var that;
        var obj = function (fBrigeReadyCallback, fOnBackCallback, fOnResumeCallback,fOnPushMsgCallback) {
            this.fBrigeReadyCallback = fBrigeReadyCallback;
            this.fOnBackCallback = fOnBackCallback;
            this.fOnResumeCallback = fOnResumeCallback;
            this.fOnPushMsgCallback=fOnPushMsgCallback;
            that = this;
            that._init(that._onWebViewJavascriptBridgeReady);
            that.setupWebViewJavascriptBridge(that._onWebViewJavascriptBridgeReady);
            that._btnClickCallbacks = {};
        };
        obj.prototype = {
            _init: function (callback) {
                if (window.WebViewJavascriptBridge) {
                    callback(WebViewJavascriptBridge)
                } else {
                    document.addEventListener('WebViewJavascriptBridgeReady', function () {
                        callback(WebViewJavascriptBridge)
                    }, false);
                }
            },
            setupWebViewJavascriptBridge : function (callback) {
                            if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
                            if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
                            window.WVJBCallbacks = [callback];
                            var WVJBIframe = document.createElement('iframe');
                            WVJBIframe.style.display = 'none';
                            WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
                            document.documentElement.appendChild(WVJBIframe);
                            setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0);
                        },
            _onWebViewJavascriptBridgeReady: function (bridge) {
                that.bridge = bridge;
                bridge.registerHandler('back_btn_handler', function (result) {
                    that.fOnBackCallback(result && result.param);
                });
                bridge.registerHandler('onResumeHandler', function (result) {
                    that.fOnResumeCallback && that.fOnResumeCallback(JSON.parse(result).param);
                });
                 bridge.registerHandler('onPushMsgHandler', function (result) {
                     that.fOnPushMsgCallback && that.fOnPushMsgCallback(result);
                });
                bridge.init(function (message, responseCallback) {
                    responseCallback(null);
                });

                that.fBrigeReadyCallback && that.fBrigeReadyCallback();
            },
            /**
             * 设置标题栏的标题
             * @param sTitle 标题文字
             */
            setTitle: function (sTitle) {
                that.bridge.callHandler(HANDLER_NAME.SET_TITLE, {title: sTitle}, null);
            },
            /**
             * 关闭当前页面
             */
            close: function (data) {
                if(window.history.length>1){
                    window.history.back();
                }else{
                    that.bridge.callHandler(HANDLER_NAME.CLOSE_PAGE, {param: data}, null);
                }
            },
            /**
             * 打开新页面
             * @param pageTo 新页面的URL
             */
            open: function (pageTo, closeBefore) {
                that.bridge.callHandler(HANDLER_NAME.OPEN_PAGE, {
                    pageTo: pageTo,
                    isCloseBefore: (closeBefore === undefined ? false : closeBefore)
                }, null);
            },

             setNavRightBarItem:function (setRightBarItem,fCallback){
                             that.bridge.callHandler(HANDLER_NAME.SET_NAV_RIGHT_BAR_ITEM, {
                                       barItemList: setRightBarItem
                                       },function(response){
                                         var result;
                                         response !== undefined && (result = JSON.parse(response));
                                         fCallback && fCallback(result);
                                        });
                                   },


            clipboard:function (copyValue,fCallback){
                 that.bridge.callHandler(HANDLER_NAME.CLIPBOARD_HANDLER, {
                           copyText: copyValue
                           },function(response){
                             var result;
                             response !== undefined && (result = JSON.parse(response));
                             fCallback && fCallback(result);
                            });
                       },

            share:function (contentValue,titleValue,urlValue,imageUrlValue,channelValue,fCallback){
                     that.bridge.callHandler(HANDLER_NAME.SHARE, {
                                                  content: contentValue,
                                                  title: titleValue,
                                                  url:urlValue,
                                                  imageUrl:imageUrlValue,
                                                  channel:channelValue
                                                  },function(response){
                                                    var result;
                                                    response !== undefined && (result = JSON.parse(response));
                                                    fCallback && fCallback(result);
                                                   });
                                              },

            shareGroup:function (contentValue,titleValue,urlValue,imageUrlValue,channelValue,fCallback){
                      that.bridge.callHandler(HANDLER_NAME.SHARE_GROUP, {
                                                              content: contentValue,
                                                               title: titleValue,
                                                                url:urlValue,
                                                                imageUrl:imageUrlValue,
                                                                channel:channelValue
                                                                 },function(response){
                                                                      var result;
                                                                      response !== undefined && (result = JSON.parse(response));
                                                                       fCallback && fCallback(result);
                                                                     });

                                                                },
            uploadVideo: function (accessToken, userId, fCallback) {
                //1:选择视频  2:拍摄视频
                that.bridge.callHandler(HANDLER_NAME.UPLOAD_VIDEO, {
                    accessToken: accessToken,
                    userId: userId
                }, function (response) {
                    //上传之后的路径，本地路径  remoteUrl,localeUrl
                    var result;
                    response !== undefined && (result = JSON.parse(response));
                    fCallback && fCallback(result);
                });
            },
            getCurrentLocationPos:function(enableHighAccuracy,timeout,fCallback){
                            that.bridge.callHandler(HANDLER_NAME.GEOLOCATION_GET_CURRENT_POSITION, {
                                enableHighAccuracy: enableHighAccuracy,
                                timeout: timeout
                            },function (result) {
                                fCallback && fCallback(JSON.parse(result));
                            });
                        }
        };
        return obj;
    })();

    if (typeof define === "function" && define.amd) {
        define("Bridge", [], function () {
            return Bridge;
        });
    }

    if (typeof noGlobal === typeof undefined) {
        window.Bridge = Bridge;
    }

    return Bridge;

}));
