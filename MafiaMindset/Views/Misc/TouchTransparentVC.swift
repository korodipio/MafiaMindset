//
//  TouchTransparentVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 14.08.23.
//

import UIKit

class TouchTransparentVC: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let r = super.hitTest(point, with: event)
        return r == self ? nil : r
    }
}
