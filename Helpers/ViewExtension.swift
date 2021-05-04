//
//  ViewExtension.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/31/20.
//

import Foundation
import UIKit

extension UIView
{
  func fixInView(_ container: UIView!) -> Void{
    self.translatesAutoresizingMaskIntoConstraints = false;
    self.frame = container.frame;
    container.addSubview(self);
    NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
    NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
    NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
    NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
  }
  
  func roundCorners(corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
  
}
