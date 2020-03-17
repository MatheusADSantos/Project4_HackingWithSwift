//
//  ViewController.swift
//  Project4_HackingWithSwift
//
//  Created by macbook-estagio on 09/03/20.
//  Copyright © 2020 macbook-estagio. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webview : WKWebView!
    var progressView: UIProgressView!
    var websites = [String]()
    var indexWebsite = Int()
    
    override func loadView() {
        webview = WKWebView()
        webview.navigationDelegate = self
        view = webview
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        let url = URL(string: "https://www." + websites[indexWebsite])!
        webview.load(URLRequest(url: url))
        webview.allowsBackForwardNavigationGestures = true
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webview, action: #selector(webview.reload))
        let left = UIBarButtonItem(title: "<=", style: .done, target: webview, action: #selector(webview.goBack))
        let right = UIBarButtonItem(title: "=>", style: .plain, target: webview, action: #selector(webview.goForward))
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        webview.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        toolbarItems = [progressButton, spacer, left, right, refresh]
        navigationController?.isToolbarHidden = false
    }

    @objc func openTapped() {
        let ac = UIAlertController(title: "Open Page...", message: nil, preferredStyle: .actionSheet)
        
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }

    func openPage(action: UIAlertAction) {
        guard let actionTitle = action.title else { return }
        guard let url = URL(string: "https:" + actionTitle) else { return }
        webview.load(URLRequest(url: url))
    }
    //Calling whe the navigation is completed ...
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webview.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        
        decisionHandler(.cancel)
        print("NAOOOOOOO")
        showAlert(title: url!)
        
    }
    
    func showAlert(title: URL) {
        if !title.absoluteString.contains("about") {
            let ac = UIAlertController(title: "Attention!", message: "You can't go to website: \(title)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(ac, animated: true)
        } else {
            print("OKK")
        }
    }
    
}

//https://www.hackingwithswift.com/articles/112/the-ultimate-guide-to-wkwebview

/*There are some easy bits, but they are outweighed by the hard bits so let's go through every line in detail to make sure:

First, we set the constant url to be equal to the URL of the navigation. This is just to make the code clearer.
Second, we use if let syntax to unwrap the value of the optional url.host. Remember I said that URL does a lot of work for you in parsing URLs properly? Well, here's a good example: this line says, "if there is a host for this URL, pull it out" – and by "host" it means "website domain" like apple.com. Note: we need to unwrap this carefully because not all URLs have hosts.
Third, we loop through all sites in our safe list, placing the name of the site in the website variable.
Fourth, we use the contains() String method to see whether each safe website exists somewhere in the host name.
Fifth, if the website was found then we call the decision handler with a positive response - we want to allow loading.
Sixth, if the website was found, after calling the decisionHandler we use the return statement. This means "exit the method now."
Last, if there is no host set, or if we've gone through all the loop and found nothing, we call the decision handler with a negative response: cancel loading.
You give the contains() method a string to check, and it will return true if it is found inside whichever string you used with contains(). You've already met the hasPrefix() method in project 1, but hasPrefix() isn't suitable here because our safe site name could appear anywhere in the URL. For example, slashdot.org redirects to m.slashdot.org for mobile devices, and hasPrefix() would fail that test.

The return statement is new, but it's one you'll be using a lot from now on. It exits the method immediately, executing no further code. If you said your method returns a value, you'll use the return statement to return that value.

Your project is complete: press Cmd+R to run the finished app, and enjoy!*/

