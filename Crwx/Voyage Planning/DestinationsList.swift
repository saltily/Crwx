//
//  DestinationsList.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/13/25.
//

import SwiftUI
import SwiftData
import FoundationUI
import WxSalt

struct DestinationsList: View {
    let isExpanded: Bool
    @Bindable var start: Harbour
    @Binding var selectedDestination: HarbourViewModel?
    @State private var destinations: HarbourDestinations = .init()
    @Environment(\.modelContext) private var context
    @State private var selection: UUID?
    @DestinationRegion private var region
    @State private var addRoute = false
    var body: some View {
        SwapCondition(isExpanded) {
            List(selection: $selection) {
                ZeroHeaderSection {
                    if destinations.isLoading { ProgressView() }
                    ForEach(destinations.viewModels.coastalRegion(region)) { harbour in
                        DestinationRow(harbour: harbour)
                            .banded(selection == harbour.id ? .red : .clear)
                            .swipeDestinationRoutes(start: start, destination: harbour) {
                                loadViewModels()
                            }
                    }
                }
                .seaSection()
            }
            .zeroListHeader()
            .padding(.top, 44)
            .onChange(of: start, initial: true) { oldValue, newValue in
                loadViewModels()
            }
            .onChange(of: selection) { oldValue, newValue in
                selectedDestination = selectedHarbour
            }
            .actions {
                CoastalRegionPicker(region: $region)
                Divider()
                Button("Add Route", systemImage: "chart.xyaxis.line") {
                    addRoute = true
                }
            }
            .fullScreenCover(isPresented: $addRoute) {
                NavigationStack {
                    RouteEditor(initialCentre: start.coordinate)
                        .cancelButton()
                }
            }
        } off: {
            SelectedHarbourView(start: start, harbour: selectedHarbour, loadViewModels: loadViewModels)
                .background(Color.groupBoxTint)
                .frame(height: 50)
        }
//        .safeAreaInset(edge: .bottom) {
//            HStack {
//                let prev = previousIndex
//                let nxt = nextIndex
//                Button(systemImage: "chevron.left") {
//                    if let i = prev {
//                        selection = viewModels.coastalRegion(region)[i].id
//                    }
//                }
//                .disabled(prev == nil)
//                .opacity(isExpanded ? 0 : 1)
//                Spacer()
//                Text(start.coordinate, format: .location)
//                Spacer()
//                Button(systemImage: "chevron.right") {
//                    if let i = nxt {
//                        selection = viewModels.coastalRegion(region)[i].id
//                    }
//                }
//                .disabled(nxt == nil)
//                .opacity(isExpanded ? 0 : 1)
//            }
//            .buttonStyle(.bordered)
//            .frame(maxWidth: .infinity)
//            .padding(5)
//            .background(.thinMaterial)
//        }
    }
    private var selectedHarbour: HarbourViewModel? {
        guard let selection else { return nil }
        return destinations.viewModels.first(where: {
            $0.id == selection
        })
    }
    private func loadViewModels() {
        destinations.loadViewModels(start: start.id, context: context)
    }
    private var previousIndex: Int? {
        guard let i = destinations.viewModels.coastalRegion(region).firstIndex(where: {
            $0.id == selection
        }),
              i > 0
        else { return nil }
        return i - 1
    }
    private var nextIndex: Int? {
        if selection == nil { return 0 }
        let vm = destinations.viewModels.coastalRegion(region)
        guard let i = vm.firstIndex(where: {
            $0.id == selection
        }),
              i < vm.count - 1
        else { return nil }
        return i + 1
    }
}


fileprivate struct SelectedHarbourView: View {
    @Bindable var start: Harbour
    let harbour: HarbourViewModel?
    let loadViewModels: () -> ()
    var body: some View {
        List {
            ZeroHeaderSection {
                if let harbour {
                    DestinationRow(harbour: harbour)
                        .padding(.trailing)
                        .banded(.red)
                        .swipeDestinationRoutes(start: start, destination: harbour) {
                            loadViewModels()
                        }
                } else {
                    Text("No selected destination.")
                }
            }
            .seaSection()
        }
        .environment(\.defaultMinListHeaderHeight, 0)
    }
}
