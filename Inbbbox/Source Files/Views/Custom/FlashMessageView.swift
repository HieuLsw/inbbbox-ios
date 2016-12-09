//
//  FlasMessage.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 11/2/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

final class FlashMessageView: UIView {
    
    fileprivate let defaultPadding:CGFloat = 15.0
    
    /// Struct for styling message
    struct Style {
        /// background color of message view
        let backgroundColor: UIColor
        /// text color of title in message view
        let textColor: UIColor
        /// font used for title in messsage view
        let titleFont: UIFont?
        /// array of corners that will be rounded, by default is nil
        let roundedCorners: UIRectCorner?
        /// vartical and horizontal size for rouded corners
        let roundSize: CGSize?
        /// padding for title in message view, by default is 15.0
        let padding: CGFloat
        
        /// Initializer for sytle with default values for majority of parameters
        ///
        /// - parameter background:         background color of message view
        /// - parameter textColor:          text color of title in message view
        /// - parameter titleFont:          font used for title in messsage view
        /// - parameter roundedCorners:     array of corners that will be rounded, by default is nil
        /// - parameter roundSize:          vartical and horizontal size for rouded corners
        /// - parameter padding:            padding for title in message view, by default is 15.0
        init (backgroundColor: UIColor, textColor: UIColor, titleFont: UIFont? = nil, roundedCorners: UIRectCorner? = nil, roundSize: CGSize? = nil, padding: CGFloat = 15.0){
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.titleFont = titleFont
            self.roundedCorners = roundedCorners
            self.roundSize = roundSize
            self.padding = padding
        }
    }
    
    /// The displayed title of this message
    let title: String
    
    /// The view controller this message is displayed in
    weak var viewController: UIViewController?

    /// View that message will be displayed in. Based on displayInViewController
    var displayInView: UIView? {
        return displayInViewController ? viewController?.view : UIApplication.shared.keyWindow
    }
    
    /// Flag for view if you want to display message in view or current keyWindow
    var displayInViewController: Bool = true
    
    /// The duration of the displayed message.
    var duration: FlashMessageDuration = .automatic
    
    /// The position of the message (top or bottom or as overlay)
    var messagePosition: FlashMessageNotificationPosition
    
    /// Is the message currenlty fully displayed? Is set as soon as the message is really fully visible
    var messageIsFullyDisplayed = false
    
    
    /// Function to customize style globally, initialized to default style. Priority will be This  customOptions in init > styleForMessageType
    static var defaultStyle: Style = {
        return Style(
            backgroundColor: UIColor.black,
            textColor: UIColor.white,
            titleFont: UIFont.systemFont(ofSize: 16)
        )
    }()
    
    /// Method called when user use gesture to dissmis message by himself
    var fadeOut: (() -> Void)?
    
    fileprivate let titleLabel = UILabel()
    fileprivate let backgroundView = UIView()
    fileprivate var textSpaceLeft: CGFloat = 0
    fileprivate var textSpaceRight: CGFloat = 0
    fileprivate var callback: (()-> Void)?
    fileprivate let padding: CGFloat
    fileprivate let style: Style!
    
    // MARK: Lifecycle
    
    /// Inits the notification view. Do not call this from outside this library.
    ///
    /// - parameter title:  The title of the notification view
    /// - parameter duration:  The duration this notification should be displayed
    /// - parameter viewController:  The view controller this message should be displayed in
    /// - parameter callback:  The block that should be executed, when the user tapped on the message
    /// - parameter position:  The position of the message on the screen
    /// - parameter dismissingEnabled:  Should this message be dismissed when the user taps/swipes it?
    /// - parameter style:  Override default/global style
    init(viewController: UIViewController?, title: String, duration: FlashMessageDuration?, position: FlashMessageNotificationPosition, style customStyle: Style?, dismissingEnabled: Bool, displayInViewController: Bool, callback: (()-> Void)?) {
        
        self.style = customStyle ?? FlashMessageView.defaultStyle
        self.title = title
        self.duration = duration ?? .automatic
        self.viewController = viewController
        self.messagePosition = position
        self.callback = callback
        self.displayInViewController = displayInViewController
        self.padding = messagePosition == .navigationBarOverlay ? style.padding + 10 : style.padding
        super.init(frame: CGRect.zero)
        
        setupBackground()
        setupTitle()
        setupPosition()
        setupGestureForDismiss(ifNeeded: dismissingEnabled)
        
    }
    
    @available(*, unavailable, message: "Use init(viewController:title:duration:position:style:dismissingEnabled:callback:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let roundedCorners = style.roundedCorners, let roundSize = style.roundSize else {
            return
        }
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundedCorners, cornerRadii: roundSize)
        let mask = CAShapeLayer()
        mask.frame = bounds
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _ = updateHeightOfMessageView()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if duration == .endless && superview != nil && window == nil {
            // view controller was dismissed, let's fade out
            fadeMeOut()
        }
    }
    
    // MARK: Setups
    
    fileprivate func setupBackground() {
        backgroundColor = UIColor.clear
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.backgroundColor = style.backgroundColor
        addSubview(backgroundView)
    }
    
    fileprivate func setupTitle() {
        let fontColor = style.textColor
        textSpaceLeft = padding
        
        titleLabel.text = title
        titleLabel.textColor = fontColor
        titleLabel.backgroundColor = UIColor.clear
        
        titleLabel.font = style.titleFont ?? UIFont.systemFont(ofSize: 14, weight: UIFontWeightBold)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        addSubview(titleLabel)

    }
    
    fileprivate func setupPosition() {

        let screenWidth = displayInView?.bounds.size.width ?? 0
        let actualHeight = updateHeightOfMessageView()
        
        var topPosition = -actualHeight
        if messagePosition == .bottom {
            topPosition = displayInView?.bounds.size.height ?? 0
        }
        
        frame = CGRect(x: 0.0, y: topPosition, width: screenWidth, height: actualHeight)
        autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin]
    }
    
    fileprivate func setupGestureForDismiss(ifNeeded dismissingEnabled: Bool) {
        guard dismissingEnabled else {
            return
        }
        
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(fadeMeOut))
        gestureRecognizer.direction = (messagePosition == .top ? .up : .down)
        addGestureRecognizer(gestureRecognizer)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(fadeMeOut))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: Private methods
    
    fileprivate func updateHeightOfMessageView() -> CGFloat {
        
        let screenWidth = displayInView?.bounds.size.width ?? 0
        titleLabel.frame = CGRect(x: textSpaceLeft, y: padding, width: screenWidth - padding - textSpaceLeft - textSpaceRight, height: 0.0)
        titleLabel.sizeToFit()
        
        var currentHeight = titleLabel.frame.origin.y + titleLabel.frame.size.height
        currentHeight += padding
        
        frame = CGRect(x: 0.0, y: frame.origin.y, width: frame.size.width, height: currentHeight)
        
        var backgroundFrame = CGRect(x: 0, y: 0, width: screenWidth, height: currentHeight)
        // increase frame of background view because of the spring animation
        if messagePosition == .top {
            var topOffset: CGFloat = 0.0
            let navigationController: UINavigationController? = viewController as? UINavigationController ?? viewController?.navigationController
            
            if let navigationController = navigationController {
                let isNavigationBarHidden =  navigationController.isNavigationBarHidden || navigationController.navigationBar.isHidden
                let isNavigationBarOpaque = !navigationController.navigationBar.isTranslucent && navigationController.navigationBar.alpha == 1
                if isNavigationBarHidden || isNavigationBarOpaque {
                    topOffset = -30.0
                }
            }
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(topOffset, 0.0, 0.0, 0.0))
        } else if messagePosition == .bottom {
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(0.0, 0.0, -30.0, 0.0))
        }
        backgroundView.frame = backgroundFrame
        return currentHeight
    }
    
    @objc fileprivate func fadeMeOut() {
        fadeOut?()
    }
}

// MARK: UIGestureRecognizerDelegate
extension FlashMessageView: UIGestureRecognizerDelegate {
    func handleTap(_ tapGesture: UITapGestureRecognizer) {
        if tapGesture.state == .recognized {
            callback?()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view is UIControl
    }
}
