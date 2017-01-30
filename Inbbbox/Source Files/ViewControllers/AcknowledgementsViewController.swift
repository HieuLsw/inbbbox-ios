import UIKit
import WebKit

class AcknowledgementsViewController: UIViewController {
    var webView: WKWebView! {
        return view as? WKWebView
    }
}

// MARK: UIViewController
extension AcknowledgementsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localized("AcknowledgementsView.Title", comment: "Acknowledgements view title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Localized("AcknowledgementsView.Back",
                comment: "Back button"), style: .plain, target: self, action: #selector(didTapBackButton(_:)))
        webView.loadHTMLString(acknowledgementsHTMLString(), baseURL: nil)
    }

    override func loadView() {
        view = WKWebView(frame: CGRect.zero)
    }
}

// MARK: Actions
extension AcknowledgementsViewController {
    func didTapBackButton(_: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Private methods
private extension AcknowledgementsViewController {
    func acknowledgementsHTMLString() -> String {
        guard let
            file = Bundle.main.path(forResource: "Acknowledgements", ofType:"html"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: file)),
            let htmlString = String(data: data, encoding: String.Encoding.utf8)
        else {
            return ""
        }
        return htmlString
    }
}
