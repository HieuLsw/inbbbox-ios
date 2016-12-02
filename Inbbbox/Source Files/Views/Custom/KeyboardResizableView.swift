//
//  KeyboardResizableView.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 18/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

enum KeyboardState {
    case willAppear, willDisappear, didAppear, didDisappear
}

protocol KeyboardResizableViewDelegate: class {

    /**
    Invokes when *KeyboardResizableView* is going to relayout itself (when keyboard will (dis)appear).

    - parameter view:  KeyboardResizableView instance.
    - parameter state: Indicates state of keyboard.
    */
    func keyboardResizableView(_ view: KeyboardResizableView, willRelayoutSubviewsWithState state: KeyboardState)

    /**
     Invokes when *KeyboardResizableView* did relayout itself (when keyboard did (dis)appear).

     - parameter view:  KeyboardResizableView instance.
     - parameter state: Indicates state of keyboard.
     */
    func keyboardResizableView(_ view: KeyboardResizableView, didRelayoutSubviewsWithState state: KeyboardState)
}

extension KeyboardResizableViewDelegate {
    func keyboardResizableView(_ view: KeyboardResizableView, didRelayoutSubviewsWithState state: KeyboardState) { }
}

class KeyboardResizableView: UIView {

    /**
     The KeyboardResizableView's delegate object
     */
    weak var delegate: KeyboardResizableViewDelegate?

    /**
     Indicates whether keyboard is present or not.
     */
    fileprivate(set) var isKeyboardPresent = false {
        willSet(newValue) {
            if !newValue {
                snapOffset = 0
            }
        }
    }

    /**
     Indicates whether *KeyboardResizableView* should snap to top edge of keyboard. Default `false`

     **Important**: when true, will ignore value of `bottomEdgeOffset` and treats it as `0`.
     */
    var automaticallySnapToKeyboardTopEdge = false

    /**
     Offset from keyboards top edge to bottom edge of *KeyboardResizableView*. Default `0`.
     */
    var bottomEdgeOffset = CGFloat(0)

    // Private variables:
    fileprivate var initialBottomConstraintConstant = CGFloat(0)
    fileprivate var bottomConstraint: NSLayoutConstraint!
    fileprivate var snapOffset = CGFloat(0)

    init() {
        super.init(frame: CGRect.zero)

        clipsToBounds = true

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)),
        name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)),
        name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @available(*, unavailable, message: "Use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "Use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setReferenceBottomConstraint(_ constraint: NSLayoutConstraint) {
        bottomConstraint = constraint
        initialBottomConstraintConstant = constraint.constant
    }
}

// MARK: Notifications

extension KeyboardResizableView {

    func keyboardWillAppear(_ notification: Notification) {
        if !isKeyboardPresent {
            relayoutViewWithParameters(parameters: notification.userInfo! as NSDictionary, keyboardPresence: true)
        }
        isKeyboardPresent = true
    }

    func keyboardWillDisappear(_ notification: Notification) {
        if isKeyboardPresent {
            relayoutViewWithParameters(parameters: notification.userInfo! as NSDictionary, keyboardPresence: false)
        }
        isKeyboardPresent = false
    }
}

// MARK: Private

private extension KeyboardResizableView {

    func calculateCorrectKeyboardRectWithParameters(_ parameters: NSDictionary) -> CGRect {

        let rawKeyboardRect = (parameters[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue ?? CGRect.zero
        return superview?.window?.convert(rawKeyboardRect, to: superview) ?? CGRect.zero
    }

    func relayoutViewWithParameters(parameters: NSDictionary, keyboardPresence: Bool) {
        
        guard let
            bottomConstraint = bottomConstraint,
            let animationDuration = parameters[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return
        }

        bottomConstraint.constant = calculateConstantIn(bottomConstraint: bottomConstraint, basedOnParameters: parameters, andKeyboardPresence: keyboardPresence)
        
        let state: KeyboardState = keyboardPresence ? .willAppear : .willDisappear
        delegate?.keyboardResizableView(self, willRelayoutSubviewsWithState: state)

        UIView.animate(withDuration: animationDuration.doubleValue, animations: {
            self.layoutIfNeeded()
        }, completion: {
            _ in
            let state: KeyboardState = keyboardPresence ? .didAppear : .didDisappear
            self.delegate?.keyboardResizableView(self, didRelayoutSubviewsWithState: state)
        }) 
    }
    
    func calculateConstantIn(bottomConstraint: NSLayoutConstraint, basedOnParameters parameters: NSDictionary, andKeyboardPresence keyboardPresence: Bool) -> CGFloat {
        
        if automaticallySnapToKeyboardTopEdge && !isKeyboardPresent {
            let rectInSuperviewCoordinateSpace = superview!.convert(bounds, to: self)
            let keyboardTopEdgeAndSelfBottomEdgeOffsetY = superview!.frame.height - rectInSuperviewCoordinateSpace.height + rectInSuperviewCoordinateSpace.minY
            
            snapOffset = keyboardTopEdgeAndSelfBottomEdgeOffsetY
        }
        
        let properlyRotatedCoords = calculateCorrectKeyboardRectWithParameters(parameters)
        
        let height = properlyRotatedCoords.size.height
        
        var addition = height - snapOffset
        
        if !automaticallySnapToKeyboardTopEdge {
            addition += bottomEdgeOffset
        }
        
        let constant = keyboardPresence ? initialBottomConstraintConstant - addition : bottomConstraint.constant + addition

        return min(0.0, constant)
    }
}
