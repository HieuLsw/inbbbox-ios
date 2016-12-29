//
//  CommentComposerView.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 18/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import RichEditorView

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

    func didTapSendButtonInComposerView(_ view: CommentComposerView, comment: String, whileEditing commentAtIndex: Int?)
}

class CommentComposerView: UIView {

    weak var delegate: CommentComposerViewDelegate?

    let editorView = RichEditorView.newAutoLayout()
    fileprivate let cornerWrapperView = UIView.newAutoLayout()
    fileprivate var didUpdateConstraints = false
    fileprivate let sendButton = UIButton(type: .custom)
    fileprivate let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: ColorModeProvider.current().activityIndicatorViewStyle)
    fileprivate let containerView = UIView.newAutoLayout()
    fileprivate lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 44))
        let options: [RichEditorOptions] = [.undo, .redo, .bold, .italic]
        toolbar.options = options
        return toolbar
    }()
    fileprivate var indexOfEditingComment: Int?

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

        editorView.webView.isOpaque = false
        let editorViewBackgroundColor = currentMode.commentComposerViewBackground
        editorView.setEditorBackgroundColor(editorViewBackgroundColor)
        editorView.webView.backgroundColor = editorViewBackgroundColor

        editorView.placeholder = CommentComposerFormatter.placeholderForMode(currentMode).string
        editorView.setTextColor(currentMode.shotDetailsCommentContentTextColor)
        editorView.webView.tintColor = .black
        editorView.delegate = self

        setupEditorAndToolbar()

        sendButton.configureForAutoLayout()
        sendButton.isEnabled = false
        sendButton.setImage(UIImage(named: "ic-sendmessage"), for: .normal)
        sendButton.addTarget(self, action: #selector(addCommentButtonDidTap(_:)), for: .touchUpInside)

        activityIndicatorView.color = .pinkColor()
        activityIndicatorView.hidesWhenStopped = true

        cornerWrapperView.addSubview(editorView)

        containerView.backgroundColor = .clear
        containerView.addSubview(sendButton)
        containerView.addSubview(activityIndicatorView)
        cornerWrapperView.addSubview(containerView)
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

            cornerWrapperView.autoPinEdgesToSuperviewEdges()

            editorView.autoPinEdge(toSuperviewEdge: .leading, withInset: 15)
            editorView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 60)
            editorView.autoCenterInSuperview()
            editorView.autoSetDimension(.height, toSize: 25)

            containerView.autoAlignAxis(.horizontal, toSameAxisOf: editorView)
            containerView.autoPinEdge(.leading, to: .trailing, of: editorView)
            containerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
            containerView.autoMatch(.height, to: .height, of: editorView)

            sendButton.autoPinEdge(toSuperviewEdge: .leading)
            sendButton.autoAlignAxis(toSuperviewAxis: .horizontal)
            sendButton.autoSetDimensions(to: CGSize(width: 45, height: 45))

            activityIndicatorView.autoCenterInSuperview()
        }

        super.updateConstraints()
    }
}

extension CommentComposerView {

    func addCommentButtonDidTap(_: UIButton) {

        guard editorView.html.characters.count > 0 else {
            return
        }

        delegate?.didTapSendButtonInComposerView(self, comment: editorView.html, whileEditing: indexOfEditingComment)

        editorView.html = ""
        sendButton.isEnabled = false
        indexOfEditingComment = nil
    }

    func startAnimation() {
        editorView.isEditingEnabled = false
        sendButton.isHidden = true
        activityIndicatorView.startAnimating()
    }

    func stopAnimation() {
        editorView.isEditingEnabled = true
        activityIndicatorView.stopAnimating()
        sendButton.isHidden = false
    }

    func makeActive(with text: String? = nil, index: Int? = nil) {
        setupEditorAndToolbar()
        editorView.focus()
        if let text = text, let index = index {
            editorView.html = text
            indexOfEditingComment = index
        }
    }

    func makeInactive() {
        editorView.blur()
        hideToolbar()
    }

    func setupEditorAndToolbar() {
        editorView.inputAccessoryView = toolbar
        toolbar.editor = editorView
    }

    func animateByRoundingCorners(_ round: Bool) {

        let fromValue: CGFloat = round ? 0 : 10
        let toValue: CGFloat = round ? 10 : 0
        addCornerRadiusAnimation(fromValue, toValue: toValue, duration: 0.3)
    }

    func hideToolbar() {
        toolbar.removeFromSuperview()
        editorView.inputAccessoryView = nil
    }
}

extension CommentComposerView: RichEditorDelegate {

    func richEditorTookFocus(_ editor: RichEditorView) {
        delegate?.commentComposerViewDidBecomeActive(self)
    }

    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {

        if content.characters.count == 0 || content == "<br>" {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
}

private extension CommentComposerView {

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
