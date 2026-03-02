import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.rootViewController?.view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1)
        
        let label = UILabel()
        label.text = "RAY"
        label.textColor = .white
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        window?.rootViewController?.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: window!.rootViewController!.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: window!.rootViewController!.view.centerYAnchor)
        ])
        
        window?.makeKeyAndVisible()
        
        return true
    }
}

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(AppDelegate.self))
