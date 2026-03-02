//
//  AppDelegate.swift RayAssistant
//
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.rootViewController?.view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        window?.rootViewController?.view.addSubview(stack)
        
        let titleLabel = UILabel()
        titleLabel.text = "RAY"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        stack.addArrangedSubview(titleLabel)
        
        let statusLabel = UILabel()
        statusLabel.text = "Starting..."
        statusLabel.textColor = .lightGray
        statusLabel.font = .systemFont(ofSize: 16)
        stack.addArrangedSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: window!.rootViewController!.view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: window!.rootViewController!.view.centerYAnchor)
        ])
        
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            statusLabel.text = "Connecting..."
        }
        
        return true
    }
}
