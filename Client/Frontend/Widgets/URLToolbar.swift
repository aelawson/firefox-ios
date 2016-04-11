/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SnapKit

private let buttonSize: CGFloat = 40

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

    private func didSetToolbarButtons(newButtons: [ToolbarButton], forContainer container: ToolbarButtonContainer) {
        container.buttons = newButtons
        setNeedsUpdateConstraints()
        setNeedsLayout()
    }

//    let locationInputView = ToolbarTextField()
    private lazy var locationContainer: UIView = {
        let locationContainer = UIView()

        // Enable clipping to apply the rounded edges to subviews.
        locationContainer.clipsToBounds = true

        locationContainer.layer.borderColor = URLBarViewUX.TextFieldBorderColor.CGColor
        locationContainer.layer.cornerRadius = URLBarViewUX.TextFieldCornerRadius
        locationContainer.layer.borderWidth = URLBarViewUX.TextFieldBorderWidth

        return locationContainer
    }()

    private let curveRightButtonContainer = ToolbarButtonContainer()
    private let insideRightButtonContainer = ToolbarButtonContainer()
    private let insideLeftButtonContainer = ToolbarButtonContainer()

    private let curveBackgroundView = CurveBackgroundView()

    private let locationViewHeight: CGFloat = 32
    private let locationViewMargin: CGFloat = 20

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(curveBackgroundView)
        addSubview(curveRightButtonContainer)
        addSubview(insideRightButtonContainer)
        addSubview(insideLeftButtonContainer)
        addSubview(locationContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        curveRightButtonContainer.snp_remakeConstraints { make in
            make.top.bottom.right.equalTo(self)
        }
        curveRightButtonContainer.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)

        curveBackgroundView.snp_remakeConstraints { make in
            make.left.top.bottom.equalTo(self)
            make.right.equalTo(curveRightButtonContainer.snp_left)
        }

        insideRightButtonContainer.snp_remakeConstraints { make in
            make.top.bottom.equalTo(curveBackgroundView)
            make.right.equalTo(curveBackgroundView).offset(-40)
        }
        insideRightButtonContainer.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)

        insideLeftButtonContainer.snp_remakeConstraints { make in
            make.top.bottom.equalTo(curveBackgroundView)
            make.left.equalTo(curveBackgroundView).offset(10)
        }
        insideLeftButtonContainer.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)

        locationContainer.snp_remakeConstraints { make in
            make.centerY.equalTo(curveBackgroundView)
            make.left.equalTo(insideLeftButtonContainer.snp_right).offset(locationViewMargin)
            make.right.equalTo(insideRightButtonContainer.snp_left).offset(-locationViewMargin)
            make.height.equalTo(locationViewHeight)
        }
    }
}

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
            height: CGFloat.max
        )
    }
}

private class CurveBackgroundView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .Redraw
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

class URLBarView_V2: URLToolbar {
    private var _shareButton: ToolbarButton = .shareButton()
    private var _bookmarkButton: ToolbarButton = .bookmarkedButton()
    private var _forwardButton: ToolbarButton = .forwardButton()
    private var _backButton: ToolbarButton = .backButton()
    private var _stopReloadButton: ToolbarButton = .reloadButton()

    var locationView = BrowserLocationView()
    var currentURL: NSURL? = nil

    var locationBorderColor: UIColor = .redColor()
    var locationActiveBorderColor: UIColor = .blueColor()
    var helper: BrowserToolbarHelper?
    var isTransitioning: Bool = false

    weak var delegate: URLBarDelegate?
    weak var browserToolbarDelegate: BrowserToolbarDelegate?

    private(set) var toolbarIsShowing: Bool = false
    private(set) var inOverlayMode: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.horizontalSizeClass == .Regular {
            insideLeftButtons = [_backButton, _forwardButton, _stopReloadButton]
            insideRightButtons = [_shareButton, _bookmarkButton]
        } else {
            insideLeftButtons = []
            insideRightButtons = []
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension URLBarView_V2: BrowserToolbarProtocol {
    var shareButton: UIButton { return _shareButton }
    var bookmarkButton: UIButton { return _bookmarkButton }
    var forwardButton: UIButton { return _forwardButton }
    var backButton: UIButton { return _backButton }
    var stopReloadButton: UIButton { return _stopReloadButton }

    var actionButtons: [UIButton] {
        return [
            self.shareButton,
            self.bookmarkButton,
            self.forwardButton,
            self.backButton,
            self.stopReloadButton
        ]
    }

    func updateBackStatus(canGoBack: Bool) {
        backButton.enabled = canGoBack
    }

    func updateForwardStatus(canGoForward: Bool) {
        forwardButton.enabled = canGoForward
    }

    func updateBookmarkStatus(isBookmarked: Bool) {
        bookmarkButton.selected = isBookmarked
    }

    func updateReloadStatus(isLoading: Bool) {
        if isLoading {
            stopReloadButton.setImage(UIImage.stopIcon(), forState: .Normal)
            stopReloadButton.setImage(UIImage.stopPressedIcon(), forState: .Highlighted)
        } else {
            stopReloadButton.setImage(UIImage.reloadIcon(), forState: .Normal)
            stopReloadButton.setImage(UIImage.reloadPressedIcon(), forState: .Highlighted)
        }
    }

    func updatePageStatus(isWebPage isWebPage: Bool) {
        bookmarkButton.enabled = isWebPage
        stopReloadButton.enabled = isWebPage
        shareButton.enabled = isWebPage
    }
}

extension URLBarView_V2: BrowserLocationViewDelegate {
    func browserLocationViewDidLongPressReaderMode(browserLocationView: BrowserLocationView) -> Bool {
        return delegate?.urlBarDidLongPressReaderMode(self) ?? false
    }

    func browserLocationViewDidTapLocation(browserLocationView: BrowserLocationView) {
        let locationText = delegate?.urlBarDisplayTextForURL(locationView.url)
        enterOverlayMode(locationText, pasted: false)
    }

    func browserLocationViewDidLongPressLocation(browserLocationView: BrowserLocationView) {
        delegate?.urlBarDidLongPressLocation(self)
    }

    func browserLocationViewDidTapReload(browserLocationView: BrowserLocationView) {
        delegate?.urlBarDidPressReload(self)
    }
    
    func browserLocationViewDidTapStop(browserLocationView: BrowserLocationView) {
        delegate?.urlBarDidPressStop(self)
    }

    func browserLocationViewDidTapReaderMode(browserLocationView: BrowserLocationView) {
        delegate?.urlBarDidPressReaderMode(self)
    }

    func browserLocationViewLocationAccessibilityActions(browserLocationView: BrowserLocationView) -> [UIAccessibilityCustomAction]? {
        return delegate?.urlBarLocationAccessibilityActions(self)
    }
}

extension URLBarView_V2: URLBarViewProtocol {
    var view: UIView {
        return self
    }

    func updateAlphaForSubviews(alpha: CGFloat) {

    }

    func updateTabCount(count: Int, animated: Bool) {

    }

    func updateProgressBar(progress: Float) {

    }

    func updateReaderModeState(state: ReaderModeState) {

    }

    func setAutocompleteSuggestion(suggestion: String?) {

    }

    func setShowToolbar(shouldShow: Bool) {

    }

    func enterOverlayMode(locationText: String?, pasted: Bool) {

    }

    func leaveOverlayMode(didCancel cancel: Bool = false) {

    }

    func applyTheme(themeName: String) {
        
    }

    func SELdidClickCancel() {

    }
}