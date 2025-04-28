//
//  TransparentBlurView.swift
//
//  Created by Dmitry Sidyakin on 08.12.2024.
//
//  MIT License
//
//  Copyright (c) 2024 Dmitry Sidyakin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI
import Combine

struct TransparentBlurView: UIViewRepresentable {
    var removeAllFilters: Bool = false

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        context.coordinator.updateFilters(for: view)
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        context.coordinator.updateFilters(for: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(removeAllFilters: removeAllFilters)
    }

    class Coordinator {
        var removeAllFilters: Bool
        var cancellable: AnyCancellable?
        weak var attachedView: UIVisualEffectView?

        init(removeAllFilters: Bool) {
            self.removeAllFilters = removeAllFilters

            cancellable = NotificationCenter.default
                .publisher(for: UIApplication.didBecomeActiveNotification)
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    if let uiView = self.attachedView {
                        self.updateFilters(for: uiView)
                    }
                }
        }

        func updateFilters(for uiView: UIVisualEffectView) {
            DispatchQueue.main.async {
                self.attachedView = uiView
                if let backdropLayer = uiView.layer.sublayers?.first {
                    if self.removeAllFilters {
                        backdropLayer.filters = []
                    } else {
                        backdropLayer.filters?.removeAll(where: { filter in
                            String(describing: filter) != "gaussianBlur"
                        })
                    }
                }
            }
        }
    }
}
