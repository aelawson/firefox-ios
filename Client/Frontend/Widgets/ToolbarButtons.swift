/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

enum ToolbarButtonTag: Int {
    case Back
    case Forward
    case Reload
    case Share
    case Bookmarked
}

// MARK: - Browser Toolbar Buttons
extension UIButton {
    class func backButton() -> UIButton {
        return createToolbarButton(
            iconForState: [
                .Normal: UIImage.backIcon(),
                .Highlighted: UIImage.backPressedIcon()
            ],
            accessibilityLabel: NSLocalizedString("Back", comment: "Accessibility Label for the browser toolbar Back button"),
            tag: ToolbarButtonTag.Back
        )
    }

    class func forwardButton() -> UIButton {
        return createToolbarButton(
            iconForState: [
                .Normal: UIImage.forwardIcon(),
                .Highlighted: UIImage.forwardPressedIcon()
            ],
            accessibilityLabel: NSLocalizedString("Forward", comment: "Accessibility Label for the browser toolbar Forward button"),
            tag: ToolbarButtonTag.Forward
        )
    }

    class func reloadButton() -> UIButton {
        return createToolbarButton(
            iconForState: [
                .Normal: UIImage.reloadIcon(),
                .Highlighted: UIImage.reloadPressedIcon()
            ],
            accessibilityLabel: NSLocalizedString("Reload", comment: "Accessibility Label for the browser toolbar Reload button"),
            tag: ToolbarButtonTag.Reload
        )
    }

    class func shareButton() -> UIButton {
        return createToolbarButton(
            iconForState: [
                .Normal: UIImage.shareIcon(),
                .Highlighted: UIImage.sharePressedIcon()
            ],
            accessibilityLabel: NSLocalizedString("Share", comment: "Accessibility Label for the browser toolbar Share button"),
            tag: ToolbarButtonTag.Share
        )
    }

    class func bookmarkedButton() -> UIButton {
        return createToolbarButton(
            iconForState: [
                .Normal: UIImage.bookmarkIcon(),
                .Highlighted: UIImage.bookmarkPressedIcon(),
                .Selected: UIImage.bookmarkSelectedIcon()
            ],
            accessibilityLabel: NSLocalizedString("Bookmark", comment: "Accessibility Label for the browser toolbar Bookmark button"),
            tag: ToolbarButtonTag.Bookmarked
        )
    }
}

// MARK: - Panel Toolbar Buttons
extension UIButton {
    class func topSitesPanelButton() -> UIButton {
        return createToolbarButton(
            iconForState: [
                .Normal: UIImage.topSitesPanelIcon(),
                .Selected: UIImage.topSitesPanelSelectedIcon()
            ],
            accessibilityLabel: NSLocalizedString("Top sites", comment: "Panel accessibility label")
        )
    }

    class func bookmarksPanelButton() -> UIButton {
        return createToolbarButton(
            iconForState: [
                .Normal: UIImage.bookmarksPanelIcon(),
                .Selected: UIImage.bookmarksPanelSelectedIcon()
            ],
            accessibilityLabel: NSLocalizedString("Bookmarks", comment: "Panel accessibility label")
        )
    }

    class func historyPanelButton() -> UIButton {
        return createToolbarButton(
            iconForState: [
                .Normal: UIImage.historyPanelIcon(),
                .Selected: UIImage.historyPanelSelectedIcon()
            ],
            accessibilityLabel: NSLocalizedString("History", comment: "Panel accessibility label")
        )
    }

    class func syncedTabsPanelButton() -> UIButton {
        return createToolbarButton(
            iconForState: [
                .Normal: UIImage.syncedTabsPanelIcon(),
                .Selected: UIImage.syncedTabsPanelSelectedIcon()
            ],
            accessibilityLabel: NSLocalizedString("Synced tabs", comment: "Panel accessibility label")
        )
    }

    class func readingListPanelButton() -> UIButton {
        return createToolbarButton(
            iconForState: [
                .Normal: UIImage.readingListPanelIcon(),
                .Selected: UIImage.readingListPanelSelectedIcon()
            ],
            accessibilityLabel: NSLocalizedString("Reading list", comment: "Panel accessibility label")
        )
    }
}

private extension UIButton {
    class func createToolbarButton(iconForState iconForState: [UIControlState: UIImage], accessibilityLabel: String, tag: ToolbarButtonTag? = nil) -> UIButton {
        let button = UIButton()
        for (state, icon) in iconForState { button.setImage(icon, forState: state) }
        button.accessibilityLabel = accessibilityLabel
//        button.layer.borderColor = UIColor.blackColor().CGColor
//        button.layer.borderWidth = 1
        if let tag = tag {
            button.tag = tag.rawValue
        }
        return button
    }
}

extension UIControlState: Hashable {
    public var hashValue: Int {
        return Int(rawValue)
    }
}

// MARK: - Browser Icons
extension UIImage {
    class func backIcon() -> UIImage { return UIImage(named: "back")! }
    class func backPressedIcon() -> UIImage { return UIImage(named: "backPressed")! }

    class func forwardIcon() -> UIImage { return UIImage(named: "forward")! }
    class func forwardPressedIcon() -> UIImage { return UIImage(named: "forwardPressed")! }

    class func reloadIcon() -> UIImage { return UIImage(named: "reload")! }
    class func reloadPressedIcon() -> UIImage { return UIImage(named: "reloadPressed")! }

    class func stopIcon() -> UIImage { return UIImage(named: "stop")! }
    class func stopPressedIcon() -> UIImage { return UIImage(named: "stopPressed")! }

    class func shareIcon() -> UIImage { return UIImage(named: "send")! }
    class func sharePressedIcon() -> UIImage { return UIImage(named: "sendPressed")! }

    class func bookmarkIcon() -> UIImage { return UIImage(named: "bookmark")! }
    class func bookmarkPressedIcon() -> UIImage { return UIImage(named: "bookmarkHighlighted")! }
    class func bookmarkSelectedIcon() -> UIImage { return UIImage(named: "bookmarked")! }
}

// MARK: - Panel Icons
extension UIImage {
    class func topSitesPanelIcon() -> UIImage { return UIImage(named: "panelIconTopSites")! }
    class func topSitesPanelSelectedIcon() -> UIImage { return UIImage(named: "panelIconTopSitesSelected")! }

    class func bookmarksPanelIcon() -> UIImage { return UIImage(named: "panelIconBookmarks")! }
    class func bookmarksPanelSelectedIcon() -> UIImage { return UIImage(named: "panelIconBookmarksSelected")! }

    class func historyPanelIcon() -> UIImage { return UIImage(named: "panelIconHistory")! }
    class func historyPanelSelectedIcon() -> UIImage { return UIImage(named: "panelIconHistorySelected")! }

    class func syncedTabsPanelIcon() -> UIImage { return UIImage(named: "panelIconSyncedTabs")! }
    class func syncedTabsPanelSelectedIcon() -> UIImage { return UIImage(named: "panelIconSyncedTabsSelected")! }

    class func readingListPanelIcon() -> UIImage { return UIImage(named: "panelIconReadingList")! }
    class func readingListPanelSelectedIcon() -> UIImage { return UIImage(named: "panelIconReadingListSelected")! }
}