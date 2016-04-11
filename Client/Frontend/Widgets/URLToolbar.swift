/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SnapKit
import Shared

private let buttonSize: CGFloat = 40

/// Flexible URL Toolbar view for laying out address field along with toolbar buttons
class URLToolbar: UIView {
    var curveRightButtons = [ToolbarButton]() {
        didSet {
            didSetToolbarButtons(curveRightButtons, forContainer: curveRightButtonContainer)
        }
    }

    var insideRightButtons = [ToolbarButton]() {
        didSet {
            didSetToolbarButtons(insideRightButtons, forContainer: insideRightButtonContainer)
        }
    }

    var insideLeftButtons = [ToolbarButton]() {
        didSet {
            didSetToolbarButtons(insideLeftButtons, forContainer: insideLeftButtonContainer)
        }
    }

    var rightToolbarSpacing: CGFloat {
        get {
            return insideRightButtonContainer.spacing
        }
        set(spacing) {
            insideRightButtonContainer.spacing = spacing
        }
    }

    var leftToolbarSpacing: CGFloat {
        get {
            return insideLeftButtonContainer.spacing
        }
        set(spacing) {
            insideLeftButtonContainer.spacing = spacing
        }
    }

    var curveToolbarSpacing: CGFloat {
        get {
            return curveRightButtonContainer.spacing
        }
        set(spacing) {
            curveRightButtonContainer.spacing = spacing
        }
    }

    var locationTextField: ToolbarTextField {
        return addressContainer.locationTextField
    }

    var locationView: BrowserLocationView {
        return addressContainer.locationView
    }

    private func didSetToolbarButtons(newButtons: [ToolbarButton], forContainer container: ToolbarButtonContainer) {
        container.buttons = newButtons
        setNeedsUpdateConstraints()
        setNeedsLayout()
    }

    private let curveRightButtonContainer = ToolbarButtonContainer()
    private let insideRightButtonContainer = ToolbarButtonContainer()
    private let insideLeftButtonContainer = ToolbarButtonContainer()

    private let curveBackgroundView = CurveBackgroundView()
    private let addressContainer = AddressSearchContainer()

    private let locationViewMargin: CGFloat = 8

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(curveBackgroundView)
        addSubview(curveRightButtonContainer)
        addSubview(insideRightButtonContainer)
        addSubview(insideLeftButtonContainer)
        addSubview(addressContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()

        curveBackgroundView.snp_remakeConstraints { make in
            make.left.top.bottom.equalTo(self)
            make.right.equalTo(curveRightButtonContainer.snp_left)
        }

        curveRightButtonContainer.snp_remakeConstraints { make in
            make.top.bottom.right.equalTo(self)
        }
        curveRightButtonContainer.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)

        insideRightButtonContainer.snp_remakeConstraints { make in
            make.top.bottom.equalTo(self)
            make.right.equalTo(curveBackgroundView.snp_right).offset(-20)
        }
        insideRightButtonContainer.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)

        insideLeftButtonContainer.snp_remakeConstraints { make in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self).offset(0)
        }
        insideLeftButtonContainer.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)

        addressContainer.snp_remakeConstraints { make in
            make.centerY.equalTo(curveBackgroundView)
            make.left.equalTo(insideLeftButtonContainer.snp_right).offset(locationViewMargin)
            make.right.equalTo(insideRightButtonContainer.snp_left).offset(-locationViewMargin)
        }
        addressContainer.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
    }
}

/// Address/search input field and associated subviews
private class AddressSearchContainer: UIView {
    private let locationViewHeight: CGFloat = 32

    private lazy var locationTextField: ToolbarTextField = {
        let locationTextField = ToolbarTextField()
        locationTextField.keyboardType = UIKeyboardType.WebSearch
        locationTextField.autocorrectionType = UITextAutocorrectionType.No
        locationTextField.autocapitalizationType = UITextAutocapitalizationType.None
        locationTextField.returnKeyType = UIReturnKeyType.Go
        locationTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
        locationTextField.font = UIConstants.DefaultChromeFont
        locationTextField.accessibilityIdentifier = "address"
        locationTextField.accessibilityLabel = Strings.ChromeAddressAccessibilityLabel
        return locationTextField
    }()

    lazy var locationView: BrowserLocationView = {
        let locationView = BrowserLocationView()
        locationView.readerModeState = ReaderModeState.Unavailable
        return locationView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        userInteractionEnabled = true
        backgroundColor = .whiteColor()

        layer.borderColor = URLBarViewUX.TextFieldBorderColor.CGColor
        layer.cornerRadius = URLBarViewUX.TextFieldCornerRadius
        layer.borderWidth = URLBarViewUX.TextFieldBorderWidth

        addSubview(locationView)
        addSubview(locationTextField)

        locationView.snp_makeConstraints { $0.edges.equalTo(self) }
        locationTextField.snp_makeConstraints { $0.edges.equalTo(self.locationView.urlTextField) }

        locationTextField.hidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 0, height: locationViewHeight)
    }
}

/// Container which layouts many toolbar buttons
private class ToolbarButtonContainer: UIView {
    var buttons: [ToolbarButton] = [] {
        didSet(oldButtons) {
            oldButtons.forEach { $0.removeFromSuperview() }
            buttons.forEach { addSubview($0) }
            invalidate()
        }
    }

    var spacing: CGFloat = 0 {
        didSet { invalidate() }
    }

    private func invalidate() {
        invalidateIntrinsicContentSize()
        setNeedsUpdateConstraints()
        setNeedsLayout()
    }

    private override func updateConstraints() {
        super.updateConstraints()
        buttons.enumerate().forEach { (index, button) in
            button.snp_remakeConstraints { make in
                make.size.equalTo(buttonSize)
                make.centerY.equalTo(self)
                if index == 0 {
                    make.left.equalTo(self)
                } else if index == buttons.endIndex - 1 {
                    let previousButton = buttons[index - 1]
                    make.left.equalTo(previousButton.snp_right).offset(spacing)
                    make.right.equalTo(self)
                } else {
                    let previousButton = buttons[index - 1]
                    make.left.equalTo(previousButton.snp_right).offset(spacing)
                }
            }
        }
    }

    private override func intrinsicContentSize() -> CGSize {
        let buttonCount = CGFloat(buttons.count)
        return CGSize(
            width: buttonCount * buttonSize + max(buttonCount - 1 * spacing, 0),
            height: 0
        )
    }
}

/// Firefox curved tab background view
private class CurveBackgroundView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .Redraw
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        CGContextClearRect(context, rect)
        drawBackgroundCurveInsideRect(rect, context: context)
    }

    private func drawBackgroundCurveInsideRect(rect: CGRect, context: CGContext) {
        CGContextSaveGState(context)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)

        // Curve's aspect ratio
        let ASPECT_RATIO: CGFloat = 0.729

        // Width multipliers
        let W_M1: CGFloat = 0.343
        let W_M2: CGFloat = 0.514
        let W_M3: CGFloat = 0.49
        let W_M4: CGFloat = 0.545
        let W_M5: CGFloat = 0.723

        // Height multipliers
        let H_M1: CGFloat = 0.25
        let H_M2: CGFloat = 0.5
        let H_M3: CGFloat = 0.72
        let H_M4: CGFloat = 0.961

        let height = rect.height
        let width = rect.width
        let curveStart = CGPoint(x: width - 32, y: 0)
        let curveWidth = height * ASPECT_RATIO

        let path = UIBezierPath()
        // Start from the bottom-left
        path.moveToPoint(CGPoint(x: 0, y: height))
        path.addLineToPoint(CGPoint(x: 0, y: 5))

        // Left curved corner
        path.addArcWithCenter(CGPoint(x: 5, y: 5), radius: 5, startAngle: CGFloat(M_PI), endAngle: CGFloat(M_PI + M_PI_2), clockwise: true)
        path.addLineToPoint(CGPoint(x: width - 32, y: 0))

        // Add tab curve on the right side
        path.addCurveToPoint(CGPoint(x: curveStart.x + curveWidth * W_M2, y: curveStart.y + height * H_M2),
                             controlPoint1: CGPoint(x: curveStart.x + curveWidth * W_M1, y: curveStart.y),
                             controlPoint2: CGPoint(x: curveStart.x + curveWidth * W_M3, y: curveStart.y + height * H_M1))
        path.addCurveToPoint(CGPoint(x: curveStart.x + curveWidth, y: curveStart.y + height),
              controlPoint1: CGPoint(x: curveStart.x + curveWidth * W_M4, y: curveStart.y + height * H_M3),
              controlPoint2: CGPoint(x: curveStart.x + curveWidth * W_M5, y: curveStart.y + height * H_M4))
        path.addLineToPoint(CGPoint(x: width, y: height))
        path.closePath()

        CGContextAddPath(context, path.CGPath)
        CGContextFillPath(context)
        CGContextRestoreGState(context)
    }
}
