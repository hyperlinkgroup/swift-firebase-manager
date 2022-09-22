//
//  PresentationContext.swift
//  Quartermile
//
//  Abstract delegate to create view context in which an authorization window can be displayed in case user interaction is needed
//
//  Created by Anna Münster on 17.11.21.
//

import AuthenticationServices

class PresentationContext: NSObject, ASAuthorizationControllerPresentationContextProviding {
    let window: UIWindow
    
    init(window: UIWindow?) {
        // swiftlint:disable force_unwrapping
        self.window = window!
        super.init()
    }
    
    // Returns a view anchor that is most appropriate for athorization UI to be presented over.  This view will be used as a hint if a credential provider requires user interaction.
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.window
    }
}
