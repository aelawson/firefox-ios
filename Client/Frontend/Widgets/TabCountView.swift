/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SnapKit

/// Custom view that renders a rounded rect and the number of tabs inside the TabCountToolbarButton
class TabCountView: UIView {
    var count: Int {
        get {
            return Int(countLabel.text ?? "") ?? 0
        }
        set(value) {
            countLabel.text = String(value)
        }
    }

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = TabsButtonUX.TitleFont
        label.layer.cornerRadius = TabsButtonUX.CornerRadius
        label.textAlignment = NSTextAlignment.Center
        label.userInteractionEnabled = false
        return label
    }()

    private lazy var borderView: InnerStrokedView = {
        let border = InnerStrokedView()
        border.strokeWidth = TabsButtonUX.BorderStrokeWidth
        border.cornerRadius = TabsButtonUX.CornerRadius
        border.userInteractionEnabled = false
        return border
    }()

    convenience init(count: Int) {
        self.init(frame: CGRect.zero)
        self.count = count
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        userInteractionEnabled = false
        
        addSubview(borderView)
        addSubview(countLabel)

        backgroundColor = .whiteColor()
        layer.cornerRadius = TabsButtonUX.CornerRadius

        borderView.snp_makeConstraints { $0.edges.equalTo(self) }
        countLabel.snp_makeConstraints { $0.center.equalTo(self) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}