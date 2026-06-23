//
//  VoyageLogHome.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/23/26.
//

import SwiftUI
import FoundationSalt
import WxSalt

struct VoyageLogHome: View {
    @State private var path = NavigationPath([TripYearValue(rawValue: Date.now.year)])
//    @AppStorage(.tripsYearKey) private var year: Int = Date.now.year
    var body: some View {
        NavigationStack(path: $path) {
            AllTripYears()
                .seaBackground()
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: TripYearValue.self) { i in
                    let year = i.rawValue
                    AllTripsView(year: year)
                        .seaBackground()
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden()
                        .toolbar {
                            ToolbarItem {
                                LogCommandsMenu(year: year)
                            }
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    path = .init()
                                } label: {
                                    Text(year, format: .number.grouping(.never))
                                }
                            }
                        }
//                        .onAppear {
//                            self.year = year
//                        }
                }
        }
//        .onAppear {
//            path = .init([TripYearValue(rawValue: year)])
//        }
    }
}

#Preview {
    VoyageLogHome()
}

//extension String {
//    static let tripsYearKey = "com.saltily.Mewx.tripsYearKey" // Int
//}
