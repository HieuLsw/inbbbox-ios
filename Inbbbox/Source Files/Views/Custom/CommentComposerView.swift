//
//  CommentComposerView.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 18/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol CommentComposerViewDelegate: class {
    func commentComposerViewDidBecomeActive(_ view: CommentComposerView)

    func didTapSendButtonInComposerView(_ view: CommentComposerView, comment: String)
}

class CommentComposerView: UIView {

    weak var delegate: CommentComposerViewDelegate?

    let textField = UITextField.newAutoLayout()
    fileprivate let cornerWrapperView = UIView.newAutoLayout()
    fileprivate var didUpdateConstraints = false
    fileprivate var sendButton: UIButton? {
        return textField.rightView as? UIButton
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let currentMode = ColorModeProvider.current()
        backgroundColor = .clear
        layer.shadowColor = currentMode.shadowColor.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 1

        cornerWrapperView.clipsToBounds = true
        cornerWrapperView.backgroundColor = currentMode.commentComposerViewBackground
        addSubview(cornerWrapperView)

        textField.backgroundColor = currentMode.commentComposerViewBackground
        textField.attributedPlaceholder = CommentComposerFormatter.placeholderForMode(currentMode)
        textField.textColor = currentMode.shotDetailsCommentContentTextColor
        textField.tintColor = .RGBA(90, 90, 95, 1)
        textField.setLeftPadding(10)
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.rightViewMode = .always
        textField.addTarget(self, action: #selector(textFieldValueDidChange(_:)),
                        for: .editingChanged)
        textField.rightView = button
        cornerWrapperView.addSubview(textField)
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    @available(*, unavailable, message: "Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            let inset = CGFloat(20)

            cornerWrapperView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero,
                    excludingEdge: .bottom)
            cornerWrapperView.autoPinEdge(toSuperviewEdge: .bottom, withInset: -inset)

            let insets = UIEdgeInsets(top: 5, left: 5, bottom: 5 + inset, right: 5)
            textField.autoPinEdgesToSuperviewEdges(with: insets)
        }

        super.updateConstraints()
    }
}

extension CommentComposerView {

    func addCommentButtonDidTap(_: UIButton) {

        guard let text = textField.text, text.characters.count > 0 else {
            return
        }

        delegate?.didTapSendButtonInComposerView(self, comment: text)

        textField.text = nil
        sendButton?.isEnabled = false
    }

    func textFieldValueDidChange(_ textField: UITextField) {
        sendButton?.isEnabled = textField.text?.characters.count > 0
    }

    func startAnimation() {
        textField.isEnabled = false
        textField.rightView = activityIndicatorView
    }

    func stopAnimation() {
        textField.isEnabled = true
        textField.rightView = button
    }

    func makeActive() {
        textField.becomeFirstResponder()
    }

    func makeInactive() {
        textField.resignFirstResponder()
    }

    func animateByRoundingCorners(_ round: Bool) {

        let fromValue: CGFloat = round ? 0 : 10
        let toValue: CGFloat = round ? 10 : 0
        addCornerRadiusAnimation(fromValue, toValue: toValue, duration: 0.3)
    }
}

extension CommentComposerView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {

        sendButton?.isEnabled = false
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.commentComposerViewDidBecomeActive(self)
    }
}

private extension CommentComposerView {

    var button: UIButton {
        let button = UIButton(type: .custom)
        button.isEnabled = false
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 40)
        button.setImage(UIImage(named: "ic-sendmessage"), for: .normal)
        button.addTarget(self, action: #selector(addCommentButtonDidTap(_:)),
                for: .touchUpInside)

        return button
    }

    var activityIndicatorView: UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: ColorModeProvider.current().activityIndicatorViewStyle)
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 65, height: 40)
        activityIndicatorView.color = .pinkColor()
        activityIndicatorView.startAnimating()

        return activityIndicatorView
    }

    func addCornerRadiusAnimation(_ fromValue: CGFloat, toValue: CGFloat, duration: CFTimeInterval) {

        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        cornerWrapperView.layer.add(animation, forKey: "cornerRadius")
        cornerWrapperView.layer.cornerRadius = toValue
    }
}
