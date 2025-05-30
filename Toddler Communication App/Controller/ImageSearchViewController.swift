//
//  ImageSearchViewController.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 03/07/24.
//
//
import UIKit
import WebKit
//protocol ImageSearchDelegate: AnyObject {
//    func didSelectImage(_ image: UIImage)
//}
//
//class ImageSearchViewController: UIViewController, WKNavigationDelegate {
//    
//    @IBOutlet weak var webView: WKWebView!
//    weak var delegate: ImageSearchDelegate?
//    
//    private let blurEffectView: UIVisualEffectView = {
//        let blurEffect = UIBlurEffect(style: .light) // Adjust style if needed
//        let view = UIVisualEffectView(effect: blurEffect)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let webConfiguration = WKWebViewConfiguration()
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView.navigationDelegate = self
//        webView.translatesAutoresizingMaskIntoConstraints = false
//        
//        self.view.addSubview(webView)
//        
//        // Setting up Auto Layout constraints for full screen
//        NSLayoutConstraint.activate([
//            webView.topAnchor.constraint(equalTo: view.topAnchor),
//            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//        
//        // Add blur effect view
//        webView.addSubview(blurEffectView)
//        
//        // Constraint for blur view to match webView size
//        NSLayoutConstraint.activate([
//            blurEffectView.topAnchor.constraint(equalTo: webView.topAnchor),
//            blurEffectView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
//            blurEffectView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
//            blurEffectView.bottomAnchor.constraint(equalTo: webView.bottomAnchor)
//        ])
//        
//        loadKidsSafeSearch()
//    }
//    
//    func loadKidsSafeSearch() {
//        let searchQuery = ""
//        let kidsSafeSearchURL = "https://www.google.com/search?tbm=isch&tbs=ift:jpg,isz:m,iar:s,safe:active&safe=active&q=\(searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
//
//        "https://www.google.com/search?tbm=isch&safesearch=active&tbs=ift:jpg&q=\(searchQuery)"
//        //"https://www.google.com/search?tbm=isch&safesearch=active&q=" // Child-friendly search engine
//        if let url = URL(string: kidsSafeSearchURL) {
//            webView.load(URLRequest(url: url))
//        }
//    }
//    
//    // Remove blur effect when page is fully loaded
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
//        UIView.animate(withDuration: 0.5) {
//            self.blurEffectView.effect = nil
//        } completion: { _ in
//            self.blurEffectView.removeFromSuperview()
//        }
//    }
//
//    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
//        if let url = navigationResponse.response.url, url.absoluteString.contains("your-app-scheme://image-selected") {
//            // Fetch the image data from the URL and create UIImage
//            if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
//                delegate?.didSelectImage(image)
//            }
//            decisionHandler(.cancel)
//            self.dismiss(animated: true, completion: nil)
//            return
//        }
//        decisionHandler(.allow)
//    }
//}
import UIKit
import WebKit

protocol ImageSearchDelegate: AnyObject {
    func didSelectImage(_ image: UIImage)
}

class ImageSearchViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    weak var delegate: ImageSearchDelegate?
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        injectContentFilter()
        loadKidsSafeSearch()
    }
    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        
        // Auto Layout for full-screen WebView
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add blur effect
        webView.addSubview(blurEffectView)
        
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: webView.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: webView.bottomAnchor)
        ])
    }
    
    private func loadKidsSafeSearch() {
        let searchQuery = ""
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let safeSearchURL = "https://www.google.com/search?tbm=isch&q=\(encodedQuery)&safe=active&hl=en"
        
        if let url = URL(string: safeSearchURL) {
            webView.load(URLRequest(url: url))
        }
    }
    
    // Remove blur effect when the page is fully loaded
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
        UIView.animate(withDuration: 0.5) {
            self.blurEffectView.effect = nil
        } completion: { _ in
            self.blurEffectView.removeFromSuperview()
        }
    }

    // Block unwanted domains
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString.lowercased() {
            let blockedDomains = ["pornhub", "xvideos", "youporn", "redtube", "xxx"]
//            ["pornhub", "xvideos", "youporn", "redtube", "xxx", "brazzers", "xhamster", "xnxx",
//             "chaturbate", "spankbang", "erome", "rule34", "hentai", "adultfriendfinder",
//             "camsoda", "mofos", "playboy", "onlyfans", "fap", "nsfw", "sex", "escort",
//             "naked", "stripchat", "bdsmlr", "bangbros", "fleshlight", "boobs", "milf",
//             "lesbian", "gayporn", "cumshot", "exxxtra", "tnaflix", "nudegirls", "hardcore","porn","penis"]
            for domain in blockedDomains {
                if url.contains(domain) {
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }

    // Inject JavaScript for extra filtering
    private func injectContentFilter() {
        let script = """
        document.querySelectorAll('img').forEach(img => {
            let altText = img.alt.toLowerCase();
            if (altText.includes('porn') || altText.includes('xxx') || altText.includes('adult')) {
                img.style.display = 'none';
            }
        });
        """
        
        let scriptInjection = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let contentController = WKUserContentController()
        contentController.addUserScript(scriptInjection)
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        webView.configuration.userContentController = contentController
    }
    
    // Handle image selection and pass it back to delegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let url = navigationResponse.response.url, url.absoluteString.contains("your-app-scheme://image-selected") {
            if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                delegate?.didSelectImage(image)
            }
            decisionHandler(.cancel)
            dismiss(animated: true, completion: nil)
            return
        }
        decisionHandler(.allow)
    }
}
