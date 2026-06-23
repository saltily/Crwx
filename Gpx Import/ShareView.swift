//
//  ShareView.swift
//  Gpx Import
//
//  Created by Matthew Goacher on 2/18/25.
//

import SwiftUI

struct ShareView: View {
    @State var gpxData: Data
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 20){
                Text(Int64(gpxData.count), format: .byteCount(style: .file))
                //                TextField("Text", text: $text, axis: .vertical)
                //                    .lineLimit(3...6)
                //                    .textFieldStyle(.roundedBorder)
                
                Button {
                    
                    
                    
                    // TODO: save text
                    close()
                } label: {
                    Text("Import GPX")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Share Extension")
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) {
                        close()
                    }
                }
            }
        }
    }
    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
}
