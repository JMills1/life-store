//
//  BannerAdView.swift
//  LifePlanner
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AppConfig.Ads.bannerAdUnitID
        
        #if canImport(UIKit)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
            let request = Request()
            banner.load(request)
        }
        #endif
        
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
}

#Preview {
    BannerAdView()
        .frame(height: 50)
}

