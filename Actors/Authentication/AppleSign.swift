//
//  AppleSign.swift
//  GourmetLink
//
//  Created by YuCheng on 2024/9/14.
//

import Foundation
import Theatre
import AuthenticationServices
import SwiftUI

class AppleSign: Actor {
    private let doorman = AppleDoorman()

    private func actSignIn(complete:@escaping (Result<AppleAuth?, Error>) -> Void) {
        doorman.completion = complete
    }
    
    private func exchangeAuthCodeForTokens(_ code: String) -> String {
        return ""
    }
    // Define the token request function
    private func requestAccessToken(clientSecret: String, authCode: String) {
        // URL for the token request
        guard let url = URL(string: "https://appleid.apple.com/auth/token") else { return }
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Prepare the request body parameters
        let clientId: String = Bundle.main.bundleIdentifier ?? "Cart00nHero8.GourmetLink"
        let parameters = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "grant_type": "authorization_code",
            "code": authCode,
        ]
        
        // Convert parameters to 'application/x-www-form-urlencoded' format
        let bodyString = parameters.compactMap { key, value in
            return "\(key)=\(value)"
        }.joined(separator: "&")
        
        // Set the request body and headers
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Send the request using URLSession
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error occurred: \(error)")
                return
            }
            
            // Ensure there is data in the response
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Try to parse the response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Response JSON: \(json)")
                }
            } catch {
                print("Failed to parse JSON: \(error)")
            }
        }
        
        task.resume() // Start the network request
    }

}
extension AppleSign {
    func signIn(complete:@escaping (Result<AppleAuth?, Error>) -> Void) {
        act { [unowned self] in
            actSignIn(complete: complete)
        }
    }
}
protocol AppleSignBehaviors {
    func signIn(complete:@escaping (Result<AppleAuth?, Error>) -> Void)
}

// Class to handle Sign in with Apple logic
fileprivate class AppleDoorman: NSObject {
    // Completion handler for success or failure
    var completion: ((Result<AppleAuth?, Error>) -> Void)?
    
    // Function to start the Sign in with Apple process
    func requestToSign() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    func startSignInWithAppleFlow(completion: @escaping (Result<AppleAuth?, Error>) -> Void) {
        self.completion = completion
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}
// MARK: - ASAuthorizationControllerDelegate
extension AppleDoorman: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Retrieve user data
            var authData = AppleAuth()
            authData.userID = appleIDCredential.user
            authData.fullName = appleIDCredential.fullName
            authData.email = appleIDCredential.email
            if let idTokenData = appleIDCredential.identityToken,
               let idToken = String(data: idTokenData, encoding: .utf8) {
                authData.idToken = idToken
            }
            if let authorizationCodeData = appleIDCredential.authorizationCode,
               let authorizationCode = String(data: authorizationCodeData, encoding: .utf8) {
                // Send this authorization code to your server for token exchange
                authData.authCode = authorizationCode
            }
            // Call the completion with success
            completion?(.success(authData))
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Call the completion handler with failure
        completion?(.failure(error))
    }
}
struct AppleAuth {
    var userID: String = ""
    var email: String?
    var fullName: PersonNameComponents? = nil
    var idToken: String = ""
    var authCode: String = ""
}
