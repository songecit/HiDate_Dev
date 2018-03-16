//
//  HDShareViewController.swift
//  HiParty
//
//  Created by HiDate on 16/3/10.
//  Copyright © 2016年 830clock. All rights reserved.
//

import UIKit

class HDShareViewController: UIViewController {

    var shareButtonClicked: ((_ btnIndex: Int) -> Void)?
    var shareButtonOptions: NSArray?
    
    @IBOutlet weak var buttonContentView: UIView!
    @IBOutlet var wechatButton: UIButton!
    @IBOutlet var pengyouquanButton: UIButton!
    @IBOutlet var qqButton: UIButton!
    @IBOutlet var sinaWeiboButton: UIButton!
    
    @IBOutlet weak var buttonContentViewLeftLC: NSLayoutConstraint!
    @IBOutlet weak var buttonContentViewRightLC: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var shareContentViewBottomLC: NSLayoutConstraint!
    @IBOutlet fileprivate weak var bottomLineLayoutConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var shareContentView: UIView!
    @IBOutlet fileprivate weak var cancelButton: UIButton!
    
    class func showShareViewWithAnimated(_ animate: Bool, shareButtonClick clickedBlock: ((Int) -> Void)?) {
        // UIViewController.enableMainNavigationInteractivePopGesture(false)

        let theOptions = NSArray.init(objects: 1,2,4,8)
        showShareViewWithAnimated(animate, shareChannelOptions: theOptions, shareButtonClick: clickedBlock)
    }
    
    class func showShareViewWithAnimated(_ animate: Bool, shareChannelOptions options: NSArray, shareButtonClick clickedBlock: ((Int) -> Void)?) {
        let shareVC = HDShareViewController(nibName: "HDShareViewController", bundle: nil)
        shareVC.shareButtonClicked = clickedBlock
        shareVC.shareButtonOptions = options
        
        let appdelegate = UIApplication.shared.delegate as? AppDelegate
        let window = appdelegate?.window
        let rootVC = window?.rootViewController
        let top = rootVC as! UINavigationController
        // let top = topVC.topViewController
        
        top.addChildViewController(shareVC)
        top.view.addSubview(shareVC.view)
        shareVC.view.frame = UIScreen.main.bounds
        shareVC.didMove(toParentViewController: top)
    }
    
    @IBAction fileprivate func maskViewClicked(_ sender: AnyObject) {
        cancelButtonClicked(sender)
    }
    
    deinit {
        print("HDShareViewController has deinit")
        self.cancelButton.removeObserver(self, forKeyPath: "highlighted")
    }

    
    func setupShareButtonWithOptions(_ options: NSArray) {
        
        let screenWidth = UIScreen.main.bounds.width
        let spaceValue = (screenWidth - 50 * 4) / 5.0
        
        
        //确定分享按钮的个数和位置
        let tmpButtonArray = NSMutableArray()
        for num in options {
            let optionInt = (num as AnyObject).int32Value
            if optionInt == 1 {
                tmpButtonArray.add(wechatButton)
            } else if optionInt == 2 {
                tmpButtonArray.add(pengyouquanButton)
            } else if optionInt == 4 {
                tmpButtonArray.add(qqButton)
            } else if optionInt == 8 {
                tmpButtonArray.add(sinaWeiboButton)
            }
        }
        
        // 居中
        let buttonCount = CGFloat(tmpButtonArray.count);
        let allButtonWidth = 50.0 * buttonCount + spaceValue * (buttonCount - 1);
        let edgeSpace = (screenWidth - allButtonWidth) / 2.0;
        
        //确定buttonContentView的约束
        buttonContentViewLeftLC.constant = edgeSpace
        buttonContentViewRightLC.constant = edgeSpace
        
        for index in 0 ..< tmpButtonArray.count {
            let button: UIView = tmpButtonArray.object(at: index) as! UIView
            buttonContentView.addSubview(button)
            button.isHidden = false
            
            button.frame = CGRect(x: CGFloat(index) * (50 + spaceValue), y: 0, width: 50, height: 70)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupShareButtonWithOptions(shareButtonOptions!)
        
        //"取消"上面的那条线保持1像素
        onePixelLine()
    
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        popupShareContentView(true, withAnimated: true, withAnimationCompleteBlock: nil)
        
        self.cancelButton.addObserver(self, forKeyPath: "highlighted", options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "highlighted" {
            
            var isNew = 0;
            let newValue = change?[.newKey];
            if newValue != nil {
                isNew = newValue as! Int
            }
            self.cancelButton.backgroundColor = isNew == 1 ? hexStringToColor("131318") : UIColor.clear
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction fileprivate func cancelButtonClicked(_ sender: AnyObject) {
        popupShareContentView(false, withAnimated: true) { (finish: Bool) -> Void in
            // UIViewController.enableMainNavigationInteractivePopGesture(true)

            self.willMove(toParentViewController: nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            
        }
    }
    
   fileprivate func onePixelLine() {
        bottomLineLayoutConstraint.constant = ThinLineHeight
    }
    
   fileprivate func popupShareContentView(_ popup: Bool, withAnimated animated: Bool, withAnimationCompleteBlock completion: ((Bool) -> Void)?) {
        shareContentViewBottomLC.constant = popup ? 0.0 : -180.0
    
        if popup {
            self.view.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        }
    
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.view.layoutIfNeeded()
                
                if popup {
                    self.view.backgroundColor = UIColor.init(white: 0.0, alpha: 0.7)
                } else {
                    self.view.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
                }
                
                }, completion: { (finish: Bool) -> Void in
                    
                    if (completion != nil) {
                        completion!(finish)
                    }
            })

        } else {
            if popup {
                self.view.backgroundColor = UIColor.init(white: 0.0, alpha: 0.7)
            } else {
                self.view.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
            }
            if (completion != nil) {
                completion!(true)
            }
        }
    }
    
    @IBAction fileprivate func shareButtonClicked(_ sender: UIButton) {
        
        //base tag is 10
        let btnIndex = sender.tag - 10
        
        if shareButtonClicked != nil {
            shareButtonClicked!(btnIndex)
        }
        
//        popupShareContentView(false, withAnimated: true, withAnimationCompleteBlock: nil)
    }


}
