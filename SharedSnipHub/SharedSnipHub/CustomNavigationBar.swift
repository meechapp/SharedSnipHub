//
//  CustomNavigationBar.swift
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

struct CustomNavigationBar<Content: View>: View {
    private let isTransparent: Bool
    private let extraHeight: CGFloat?
    @Binding private var isFilled: Bool
    private let content: Content

    init(
        isTransparent: Bool = false,
        extraHeight: CGFloat? = nil,
        isFilled: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.isTransparent = isTransparent
        self.extraHeight = extraHeight
        self._isFilled = isFilled
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            let safeAreaTop = geometry.safeAreaInsets.top
            
            ZStack {
                TransparentBlurView(removeAllFilters: true)
                    .blur(radius: 2)
                    .visualEffect { view, proxy in
                        view
                            .offset(y: proxy.bounds(of: .scrollView)?.minY ?? 0)
                    }
                    .opacity(!isTransparent && isFilled ? 1 : 0)
                content
                    .padding(.top, (extraHeight ?? 0))
            }
            .frame(height: (extraHeight ?? 0) + safeAreaTop)
            .background(backgroundView)
            .ignoresSafeArea(.container, edges: .top)
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if !isTransparent {
            LinearGradient(
                gradient: Gradient(colors: [Color(UIColor.systemBackground).opacity(0.8), Color.clear]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

#Preview {
    ZStack {
        ScrollView {
            ForEach(1..<10) { i in
                ItemRow(text: "Item number \(i) from Go Over App")
            }
        }
        .contentMargins(.top, 55)

        CustomNavigationBar(extraHeight: 50, isFilled: .constant(true)) {
            ToolbarButton()
                .padding(.leading, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - #Preview Components

private struct ItemRow: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .bold))
            .frame(height: 40)
    }
}

private struct ToolbarButton: View {
    var body: some View {
        Button(action: {
            // action
        }) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Add")
                    .font(.headline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }
}
