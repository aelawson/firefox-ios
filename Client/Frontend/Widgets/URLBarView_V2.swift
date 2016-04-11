/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

/// Implementation of existing URLBarView using new URLToolbar
class URLBarView_V2: URLToolbar {
    private var _shareButton: ToolbarButton = .shareButton()
    private var _bookmarkButton: ToolbarButton = .bookmarkedButton()
    private var _forwardButton: ToolbarButton = .forwardButton()
    private var _backButton: ToolbarButton = .backButton()
    private var _stopReloadButton: ToolbarButton = .reloadButton()
    private var _tabsButton: ToolbarButton = .tabsButton()

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
        backgroundColor = .blackColor()

        locationView.delegate = self
        locationTextField.autocompleteDelegate = self

        bindSelectors()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bindSelectors() {
        _shareButton.addTarget(self, action: #selector(URLBarView_V2.share), forControlEvents: .TouchUpInside)
        _bookmarkButton.addTarget(self, action: #selector(URLBarView_V2.bookmark), forControlEvents: .TouchUpInside)
        _forwardButton.addTarget(self, action: #selector(URLBarView_V2.goForward), forControlEvents: .TouchUpInside)
        _backButton.addTarget(self, action: #selector(URLBarView_V2.goBack), forControlEvents: .TouchUpInside)
        _stopReloadButton.addTarget(self, action: #selector(URLBarView_V2.stopOrReload), forControlEvents: .TouchUpInside)
        _tabsButton.addTarget(self, action: #selector(URLBarView_V2.goToTabs), forControlEvents: .TouchUpInside)
    }

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let previousTraitCollection = previousTraitCollection else {
            narrowToolbarLayout()
            return
        }

        if previousTraitCollection.verticalSizeClass != .Compact && previousTraitCollection.horizontalSizeClass != .Regular {
            narrowToolbarLayout()
        } else {
            wideToolbarLayout()
        }
    }

    private func wideToolbarLayout() {
        curveRightButtons = [_tabsButton]
        insideLeftButtons = [_backButton, _forwardButton, _stopReloadButton]
        insideRightButtons = [_shareButton, _bookmarkButton]
    }

    private func narrowToolbarLayout() {
        curveRightButtons = [_tabsButton]
        insideLeftButtons = []
        insideRightButtons = []
    }
}

// MARK: - Selectors
extension URLBarView_V2 {
    func goBack() {
        browserToolbarDelegate?.browserToolbarDidPressBack(self, button: _backButton)
    }

    func goForward() {
        browserToolbarDelegate?.browserToolbarDidPressForward(self, button: _forwardButton)
    }

    func stopOrReload() {
        browserToolbarDelegate?.browserToolbarDidPressReload(self, button: _stopReloadButton)
    }

    func share() {
        browserToolbarDelegate?.browserToolbarDidPressShare(self, button: _shareButton)
    }

    func bookmark() {
        browserToolbarDelegate?.browserToolbarDidPressBookmark(self, button: _bookmarkButton)
    }

    func goToTabs() {
        delegate?.urlBarDidPressTabs(self)
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

extension URLBarView_V2: AutocompleteTextFieldDelegate {
    func autocompleteTextFieldShouldReturn(autocompleteTextField: AutocompleteTextField) -> Bool {
        guard let text = locationTextField.text else { return false }
        delegate?.urlBar(self, didSubmitText: text)
        return true
    }

    func autocompleteTextField(autocompleteTextField: AutocompleteTextField, didEnterText text: String) {
        delegate?.urlBar(self, didEnterText: text)
    }

    func autocompleteTextFieldDidBeginEditing(autocompleteTextField: AutocompleteTextField) {
        autocompleteTextField.highlightAll()
    }

    func autocompleteTextFieldShouldClear(autocompleteTextField: AutocompleteTextField) -> Bool {
        delegate?.urlBar(self, didEnterText: "")
        return true
    }
}

// MARK: - URLBarViewProtocol for URLBarView conformance
extension URLBarView_V2: URLBarViewProtocol {
    var view: UIView {
        return self
    }

    var currentURL: NSURL? {
        get {
            return locationView.url
        }
        set(newURL) {
            locationView.url = newURL
        }
    }

    func updateAlphaForSubviews(alpha: CGFloat) {
        subviews.forEach { $0.alpha = alpha }
    }

    func updateTabCount(count: Int, animated: Bool) {
        (_tabsButton as? TabCountToolbarButton)?.setCount(count, animated: animated)
    }

    func updateProgressBar(progress: Float) {

    }

    func updateReaderModeState(state: ReaderModeState) {
        locationView.readerModeState = state
    }

    func setAutocompleteSuggestion(suggestion: String?) {
        locationTextField.setAutocompleteSuggestion(suggestion)
    }

    func setShowToolbar(shouldShow: Bool) {
        // Not needed since we use traitCollectionDidChange callback.
    }

    func enterOverlayMode(locationText: String?, pasted: Bool) {
        locationView.hidden = true
        locationTextField.hidden = false
        locationTextField.becomeFirstResponder()
        locationTextField.attributedPlaceholder = locationView.placeholder
        delegate?.urlBarDidEnterOverlayMode(self)
    }

    func leaveOverlayMode(didCancel cancel: Bool = false) {
        locationView.hidden = false
        locationTextField.hidden = true
        locationTextField.resignFirstResponder()
        delegate?.urlBarDidLeaveOverlayMode(self)
    }

    func applyTheme(themeName: String) {
        
    }

    func SELdidClickCancel() {

    }
}