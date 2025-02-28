////
////  FloatingTabBar.swift
////  Greenly
////
////  Created by Kim Reuter on 28.02.25.
////
//
//import SwiftUI
//
//struct FloatingTabBar: View {
//    @Binding var selectedTab: Int
//    let tabs: [String]
//    
//    var body: some View {
//        HStack {
//            ForEach(0..<tabs.count, id: \ .self) { index in
//                Spacer()
//                Button(action: {
//                    withAnimation {
//                        selectedTab = index
//                    }
//                }) {
//                    VStack {
//                        Image(systemName: tabs[index])
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 24, height: 24)
//                            .foregroundColor(selectedTab == index ? .white : .gray)
//                        
//                        Circle()
//                            .fill(selectedTab == index ? Color.blue : Color.clear)
//                            .frame(width: 6, height: 6)
//                    }
//                }
//                Spacer()
//            }
//        }
//        .padding(.vertical, 12)
//        .padding(.horizontal, 16)
//        .background(
//            RoundedRectangle(cornerRadius: 25)
//                .fill(Color.black.opacity(0.8))
//                .shadow(radius: 5)
//        )
//        .padding(.horizontal, 30)
//    }
//}
//#Preview {
//    FloatingTabBar(selectedTab: 0, tabs: <#[String]#>)
//}
