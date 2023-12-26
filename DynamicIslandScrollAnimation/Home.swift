//
//  Home.swift
//  DynamicIslandScrollAnimation
//
//  Created by Roman Shestopal on 12.06.2023.
//

import SwiftUI

struct Home: View {
    var size: CGSize
    var safeArea: EdgeInsets
    // View Properties
    @State private var scrollProgress: CGFloat = 0
    @State private var textHeaderOffset: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        let isHavingNotch = safeArea.bottom != 0
        ScrollView(showsIndicators: true) {
            VStack(spacing: 10) {
                Image("taunHouse")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 150,
//                            height: 150)
                    .frame(width: 250 - (200 * scrollProgress),
                           height: 250 - (200 * scrollProgress))
                    .opacity(1 - scrollProgress)
                    .blur(radius: scrollProgress * 7, opaque: true)
                    .clipShape(Circle())
                    .anchorPreference(key: AnchorKey.self, value: .bounds, transform: { return ["HEADER" : $0]
                    })
                    .padding(.top, safeArea.top + 15)
                    .offsetExtractor(coordinateSpace: "SCROLLVIEW") { scrollRect in
                        guard isHavingNotch else { return }
//                        scrollProgress = scrollRect.minY
                        let progress = -scrollRect.minY / 25
                        scrollProgress = min(max(progress, 0), 1)
                    }
                let fixedTop: CGFloat = safeArea.top
                Text("Town house")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.vertical, 15)
                    .background(content: {
                        Rectangle()
                            .fill(colorScheme == .dark ? .black : .white)
                            .frame(width: size.width)
                            .padding(.top, textHeaderOffset < fixedTop ? -safeArea.top : 0)
                            .shadow(color: .black.opacity(textHeaderOffset < fixedTop ? 0.1 : 0), radius: 5, x: 0, y: 5)
                            
                    })
                    .offset(y: textHeaderOffset < fixedTop ? -(textHeaderOffset - fixedTop) : 0)
                    .offsetExtractor(coordinateSpace: "SCROLLVIEW") {
                        textHeaderOffset = $0.minY
                    }
                    .zIndex(1000)
                    
                SampleRows()
            }
            .frame(maxWidth: .infinity)
        }
        .backgroundPreferenceValue(AnchorKey.self, { pref in
            GeometryReader { proxy in
                if let anchor = pref["HEADER"], isHavingNotch {
                    let frameRect = proxy[anchor]
                    let isHavingDynamicIsland: Bool = safeArea.top > 51
                    let capsuleHeight = isHavingDynamicIsland ? 33 : safeArea.top - 15
                    Canvas { out, size in
                        out.addFilter(.alphaThreshold(min: 0.5))
                        out.addFilter(.blur(radius: 12))
                        
                        out.drawLayer { ctx in
                            if let headerView = out.resolveSymbol(id: 0) {
                                ctx.draw(headerView, in: frameRect)
                            }
                            if let dynamicIsland = out.resolveSymbol(id: 1) {
                                let rect = CGRect(x: (size.width - 120) / 2, y: isHavingDynamicIsland ? 11 : 0, width: 120, height: capsuleHeight)
                                ctx.draw(dynamicIsland, in: rect)
                            }
                        }
                    } symbols: {
                        HeaderView(frameRect)
                            .tag(0)
                            .id(0)
                        
                        DynamicIslandCapsule()
                            .tag(1)
                            .id(1)
                    }
                }
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(colorScheme == .dark ? .black : .white)
                    .frame(height: 15)
                    .padding(0)
            }
        })
        .coordinateSpace(name: "SCROLLVIEW")
    }
    
    @ViewBuilder
    func HeaderView(_ frameRect: CGRect) -> some View {
        Circle()
            .fill(colorScheme == .dark ? .black : .white)
            .frame(width: frameRect.width, height: frameRect.height)
    }
    
    @ViewBuilder
    func DynamicIslandCapsule(_ height: CGFloat = 30) -> some View {
        Capsule()
            .fill(.black)
            .frame(width: 110, height: height)
    }
    
    @ViewBuilder
    func SampleRows() -> some View {
        VStack {
            ForEach(1...12, id: \.self) { _ in
                VStack{
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(.gray.opacity(0.25))
                        .frame(height: 25)
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(.gray.opacity(0.15))
                        .frame(height: 15)
                        .padding(.trailing, 50)
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(.gray.opacity(0.15))
                        .padding(.trailing, 150)
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.bottom, safeArea.bottom + 15)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
