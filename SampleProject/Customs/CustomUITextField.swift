//
//  CustomUITextField.swift
//  SampleProject
//
//  Created by hideto.higashi on 2022/12/21.
//

import Foundation
import UIKit

final class PaddingTextField: UITextField {
    var padding: UIEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
