import UIKit

class ViewController: UIViewController {

    @IBAction func didTapEmojiButton(sender: UIButton) {

        guard let rawIconName = sender.value(forKey: "iconName") as? String else {
            reportError(message: "Button not set up correctly.")
            return
        }

        let iconName = rawIconName == "AppIcon" ? nil : rawIconName

        UIApplication.shared.setAlternateIconName(iconName) { error in

            guard let error = error else {
                return
            }

            self.reportError(message: (error as NSError).localizedDescription)

        }

    }

    func reportError(message: String) {

        let alert = UIAlertController(title: "Cannot Change Icon",
                                      message: message,
                                      preferredStyle: .alert)

        let done = UIAlertAction(title: "Done", style: .default, handler: nil)

        alert.addAction(done)

        present(alert, animated: true)

    }

}

@objc class IconButton: UIButton {
    @objc dynamic var iconName: String? = nil
}
