//
//  OffsetHelper.swift
//  DynamicIslandScrollAnimation
//
//  Created by Roman Shestopal on 13.06.2023.
//

import SwiftUI

struct OffsetKey: PreferenceKey { // Scrollview Offset Reader
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
    
}

extension View {
    @ViewBuilder
    func offsetExtractor(coordinateSpace: String, completion: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader {
                    let rect = $0.frame(in: .named(coordinateSpace))
                    Color.clear
                        .preference(key: OffsetKey.self, value: rect)
                        .onPreferenceChange(OffsetKey.self, perform: completion)
                }
            }
    }
}

struct OffsetHelper_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
