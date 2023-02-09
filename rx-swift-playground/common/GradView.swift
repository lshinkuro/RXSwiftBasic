//
//  GradView.swift
//  rx-swift-playground
//
//  Created by nur kholis on 09/02/23.
//

import UIKit

@IBDesignable

class GradView: UIView {

    @IBInspectable var colorTop: UIColor? {
        didSet {
          layerGradient(colorTop: colorTop, colorBottom:colorBottom)
        }
    }

    @IBInspectable var colorBottom: UIColor? {
        didSet {
          layerGradient(colorTop: colorTop, colorBottom:colorBottom)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
      layerGradient(colorTop: colorTop, colorBottom:colorBottom)
    }

    func layerGradient(colorTop:UIColor?,colorBottom:UIColor?) {
        if colorTop != nil && colorBottom != nil{
            let layer : CAGradientLayer = CAGradientLayer()
            layer.frame = self.frame
            layer.colors = [colorTop!.cgColor,colorBottom!.cgColor]
            self.layer.insertSublayer(layer, at: 0)
        }
    }

}
