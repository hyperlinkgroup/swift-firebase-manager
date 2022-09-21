//
//  UIApplication.swift
//  Quartermile
//
//  Created by Anna Münster on 21.09.22.
//

import UIKit

extension UIApplication {
    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first { $0 is UIWindowScene }
            .flatMap { $0 as? UIWindowScene }?.windows
            .first(where: \.isKeyWindow)
    }
    
    static var visibleViewController: UIViewController? {
        keyWindow?.rootViewController?.presentedViewController ?? keyWindow?.rootViewController
    }
}
