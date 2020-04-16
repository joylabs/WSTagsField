//
//  WSTagView.swift
//  Whitesmith
//
//  Created by Ricardo Pereira on 12/05/16.
//  Copyright © 2016 Whitesmith. All rights reserved.
//

import UIKit

open class WSTagView: UIView, UITextInputTraits {

    fileprivate let textLabel = UILabel()
    fileprivate let imageView = UIImageView()
    
    open fileprivate(set) var tags = [WSTag]()

    open var displayText: String = "" {
        didSet {
            updateLabelText()
            setNeedsDisplay()
        }
    }

    open var displayDelimiter: String = "" {
        didSet {
            updateLabelText()
            setNeedsDisplay()
        }
    }
    
    open var image = UIImage() {
        didSet {
            imageView.image = image
            setNeedsDisplay()
        }
    }
    
    open var isImageHidden: Bool = true {
        didSet {
            imageView.isHidden = isImageHidden
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    open var imageSize: CGSize = .zero {
        didSet {
            updateFrame()
            setNeedsDisplay()
        }
    }
    
    open var imageMargin: CGFloat = 10.0 {
        didSet {
            updateFrame()
            setNeedsDisplay()
        }
    }
    
    open var imageCornerRadius: CGFloat? {
        didSet {
            self.imageView.layer.cornerRadius = imageCornerRadius ?? 0
            setNeedsDisplay()
        }
    }

    open var font: UIFont? {
        didSet {
            textLabel.font = font
            setNeedsDisplay()
        }
    }

    open var cornerRadius: CGFloat = 3.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            setNeedsDisplay()
        }
    }

    open var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
            setNeedsDisplay()
        }
    }

    open var borderColor: UIColor? {
        didSet {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
                setNeedsDisplay()
            }
        }
    }

    open override var tintColor: UIColor! {
        didSet { updateContent(animated: false) }
    }

    /// Background color to be used for selected state.
    open var selectedColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    open var textColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    open var selectedTextColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    internal var onDidRequestDelete: ((_ tagView: WSTagView, _ replacementText: String?) -> Void)?
    internal var onDidRequestSelection: ((_ tagView: WSTagView) -> Void)?
    internal var onDidInputText: ((_ tagView: WSTagView, _ text: String) -> Void)?

    open var selected: Bool = false {
        didSet {
            if selected && !isFirstResponder {
                _ = becomeFirstResponder()
            }
            else if !selected && isFirstResponder {
                _ = resignFirstResponder()
            }
            updateContent(animated: true)
        }
    }

    // MARK: - UITextInputTraits

    public var autocapitalizationType: UITextAutocapitalizationType = .none
    public var autocorrectionType: UITextAutocorrectionType  = .no
    public var spellCheckingType: UITextSpellCheckingType  = .no
    public var keyboardType: UIKeyboardType = .default
    public var keyboardAppearance: UIKeyboardAppearance = .default
    public var returnKeyType: UIReturnKeyType = .next
    public var enablesReturnKeyAutomatically: Bool = false
    public var isSecureTextEntry: Bool = false

    // MARK: - Initializers

    public init(tag: WSTag) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = tintColor
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true

        textColor = .white
        selectedColor = .gray
        selectedTextColor = .black
        
        if let personImage = UIImage(systemName: "person.circle.fill") {
            image = personImage
            imageSize = personImage.size
        }
        
        imageView.frame = CGRect(x: layoutMargins.left, y: layoutMargins.top, width: 0, height: 0)
        imageView.isHidden = isImageHidden
        imageView.image = image
        imageView.tintColor = .white
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        addSubview(imageView)

        textLabel.frame = CGRect(x: layoutMargins.left, y: layoutMargins.top, width: 0, height: 0)
        textLabel.font = font
        textLabel.textColor = .white
        textLabel.backgroundColor = .clear
        addSubview(textLabel)

        self.displayText = tag.text
        updateLabelText()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
        addGestureRecognizer(tapRecognizer)
        setNeedsLayout()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assert(false, "Not implemented")
    }

    // MARK: - Styling

    fileprivate func updateColors() {
        self.backgroundColor = selected ? selectedColor : tintColor
        textLabel.textColor = selected ? selectedTextColor : textColor
        imageView.tintColor = selected ? selectedTextColor : textColor
    }

    internal func updateContent(animated: Bool) {
        guard animated else {
            updateColors()
            return
        }

        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.updateColors()
                if self?.selected ?? false {
                    self?.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                }
            },
            completion: { [weak self] _ in
                if self?.selected ?? false {
                    UIView.animate(withDuration: 0.1) { [weak self] in
                        self?.transform = CGAffineTransform.identity
                    }
                }
            }
        )
    }

    // MARK: - Size Measurements

    open override var intrinsicContentSize: CGSize {
        let labelIntrinsicSize = textLabel.intrinsicContentSize
        let imageSize = isImageHidden ? .zero : self.imageSize
        let imageMargin = isImageHidden ? 0.0 : self.imageMargin
        return CGSize(width: labelIntrinsicSize.width + imageSize.width + imageMargin + layoutMargins.left + layoutMargins.right,
                      height: max(labelIntrinsicSize.height, imageSize.height) + layoutMargins.top + layoutMargins.bottom)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layoutMarginsHorizontal = layoutMargins.left + layoutMargins.right
        let layoutMarginsVertical = layoutMargins.top + layoutMargins.bottom
        let fittingSize = CGSize(width: size.width - layoutMarginsHorizontal,
                                 height: size.height - layoutMarginsVertical)
        let labelSize = textLabel.sizeThatFits(fittingSize)
        let imageSize = isImageHidden ? CGSize(width: 0, height: 0) : imageView.sizeThatFits(fittingSize)
        let imageMargin = isImageHidden ? 0.0 : self.imageMargin
        return CGSize(width: labelSize.width + imageSize.width + imageMargin + layoutMarginsHorizontal,
                      height: max(labelSize.height, imageSize.height) + layoutMarginsVertical)
    }

    open func sizeToFit(_ size: CGSize) -> CGSize {
        if intrinsicContentSize.width > size.width {
            return CGSize(width: size.width,
                          height: intrinsicContentSize.height)
        }
        return intrinsicContentSize
    }

    // MARK: - Attributed Text
    fileprivate func updateLabelText() {
        // Unselected shows "[displayText]," and selected is "[displayText]"
        textLabel.text = displayText + displayDelimiter
        // Expand Label
        updateFrame()
    }
    
    fileprivate func updateFrame() {
        let intrinsicSize = self.intrinsicContentSize
        frame = CGRect(x: 0, y: 0, width: intrinsicSize.width, height: intrinsicSize.height)
    }

    // MARK: - Laying out
    open override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = isImageHidden ? .zero : self.imageSize
        let imageMargin = isImageHidden ? 0 : self.imageMargin
        let insets = bounds.inset(by: layoutMargins)
        imageView.frame = CGRect(x: insets.minX, y: insets.minY, width: imageSize.width, height: imageSize.height)
        textLabel.frame = insets.offsetBy(dx: imageSize.width + imageMargin, dy: 0)
        if frame.width == 0 || frame.height == 0 {
            frame.size = self.intrinsicContentSize
        }
    }

    // MARK: - First Responder (needed to capture keyboard)
    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = super.becomeFirstResponder()
        selected = true
        return didBecomeFirstResponder
    }

    open override func resignFirstResponder() -> Bool {
        let didResignFirstResponder = super.resignFirstResponder()
        selected = false
        return didResignFirstResponder
    }

    // MARK: - Gesture Recognizers
    @objc func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        if selected {
            return
        }
        onDidRequestSelection?(self)
    }

}

extension WSTagView: UIKeyInput {

    public var hasText: Bool {
        return true
    }

    public func insertText(_ text: String) {
        onDidInputText?(self, text)
    }

    public func deleteBackward() {
        onDidRequestDelete?(self, nil)
    }

}
