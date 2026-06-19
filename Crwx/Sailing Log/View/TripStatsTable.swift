//
//  TripStatsTable.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/8/25.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import WxSalt

fileprivate let fade = 0.7
fileprivate let dividerPadding: CGFloat = 10

struct TripStatsTable: View {
    @Bindable var trip: Trip
    @Binding var goToStartHarbour: Bool
    @Binding var goToEndHarbour: Bool
    var body: some View {
        Section {
            Grid(verticalSpacing: 10) {
                // MARK: Header
                GridRow {
                    Text(" ")
                        .gridColumnAlignment(.leading)
                    Spacer()
                    Group {
                        Text("Departure")
                        Spacer()
                        Text("Arrival")
                    }
                    .fixedSize()
                }
//                .frame(maxWidth: .infinity)
                .font(.headline)
                Divider()
                    .padding(.vertical, dividerPadding)

                // MARK: Time
                GridRow {
                    Text("Time")
                    Spacer()
                    TimeValue(value: trip.departureTime)
                    Spacer()
                    TimeValue(value: trip.arrivalTime)
                }
                
                // MARK: Location
                GridRow(alignment: .firstTextBaseline) {
                    Text("Location")
                    Spacer()
                    Group {
                        HarbourValue(value: trip.departureLocation?.name, harbour: trip.startHarbour, goToHarbour: $goToStartHarbour)
                        Spacer()
                        HarbourValue(value: trip.arrivalLocation?.name, harbour: trip.endHarbour, goToHarbour: $goToEndHarbour)
                    }
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .minimumScaleFactor(0.5)
                }
                Divider()
                    .padding(.vertical, dividerPadding)

                // MARK: Wind
                GridRow {
                    Text("Wind")
                    Spacer()
                    WindValue(speed: trip.departureWindSpeed, angle: trip.departureWindDirection, gust: nil)
                    Spacer()
                    WindValue(speed: trip.arrivalWindSpeed, angle: trip.arrivalWindDirection, gust: nil)
                }
                let departureBuoy = trip.departureObservation
                let arrivalBuoy = trip.arrivalObservation
                if departureBuoy != nil || arrivalBuoy != nil {
                    GridRow {
                        Text("Buoy")
                        Spacer()
                        WindValue(speed: departureBuoy?.windSpeed, angle: departureBuoy?.windDirection, gust: departureBuoy?.gust)
                        Spacer()
                        WindValue(speed: arrivalBuoy?.windSpeed, angle: arrivalBuoy?.windDirection, gust: arrivalBuoy?.gust)
                    }
                    GridRow {
                        Text("Waves")
                        Spacer()
                        WaveValue(height: departureBuoy?.waveHeight, period: departureBuoy?.period)
                        Spacer()
                        WaveValue(height: arrivalBuoy?.waveHeight, period: arrivalBuoy?.period)
                    }
                }
                Divider()
                    .padding(.vertical, dividerPadding)

                // MARK: Depth
                GridRow {
                    Text("Depth")
                    Spacer()
                    DepthValue(value: trip.departureDepth)
                    Spacer()
                    DepthValue(value: trip.arrivalDepth)
                }
                
                // MARK: Tide
                GridRow {
                    Text("Tide")
                    Spacer()
                    TideValue(value: trip.departureTide)
                    Spacer()
                    TideValue(value: trip.arrivalTide)
                }
                GridRow {
                    Text("UKC")
                    Spacer()
                    DepthValue(value: trip.departureUKC)
                    Spacer()
                    DepthValue(value: trip.arrivalUKC)
                }
                
                // MARK: Current
                GridRow {
                    Text("Current")
                    Spacer()
                    Group {
                        StringValue(value: trip.departureTidalCurrent)
                        Spacer()
                        StringValue(value: trip.arrivalTidalCurrent)
                    }
                    .truncationMode(.middle)
                }
                Divider()
                    .padding(.vertical, dividerPadding)

                // MARK: Odometer
                GridRow {
                    Text("Odometer")
                        .fixedSize()
                    Spacer()
                    OdometerValue(value: trip.odometerStart)
                    Spacer()
                    OdometerValue(value: trip.odometerEnd)
                }
                
                // MARK: Fuel
                GridRow {
                    Text("Fuel")
                    Spacer()
                    GallonsValue(value: trip.fuelStart?.gallons)
                    Spacer()
                    GallonsValue(value: trip.fuelEnd?.gallons)
                }
                
            }
            .frame(maxWidth: .infinity)
            .listRowInsets(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
        }
        .seaSection()
    }
}

fileprivate struct TimeValue: View {
    let value: Date?
    var body: some View {
        PlaceholderText(value?.formatted(.dateTime.hour().minute()) ?? "", placeholder: "--")
            .opacity(fade)
    }
}
fileprivate struct StringValue: View {
    let value: String?
    var body: some View {
        PlaceholderText(value ?? "", placeholder: "--")
            .minimumScaleFactor(0.5)
            .opacity(fade)
    }
}
fileprivate struct HarbourValue: View {
    let value: String?
    let harbour: Harbour?
    @Binding var goToHarbour: Bool
    var body: some View {
        if harbour != nil {
            Button {
                goToHarbour = true
            } label: {
                PlaceholderText(value ?? "", placeholder: "--")
                    .minimumScaleFactor(0.5)
            }
            .buttonStyle(.borderless)
        } else {
            StringValue(value: value)
        }
    }
}
fileprivate struct WindValue: View {
    let speed: Double?
    let angle: Double?
    let gust: Double?
    var body: some View {
        HStack {
            WindDirectionSymbol(directions: .init(direction))
            Group {
                Text(compassDirection.abbreviation)
                if let speed,
                   speed.rounded != 0
                {
                    Text(speed.rounded, format: .number)
                    if let gust,
                       gust.rounded != speed.rounded
                    {
                        Text("G") + Text(gust.rounded, format: .number)
                    }
                }
            }
            .opacity(fade)
            .fixedSize()
        }
    }
    private var direction: Measurement<UnitAngle>? {
        .init(value: angle, unit: .degrees)
    }
    private var compassDirection: CompassDirection {
        .init(cardinal: direction)
    }
}
fileprivate struct WaveValue: View {
    let height: Double?
    let period: Double?
    var body: some View {
        if let height {
            HStack {
                (Text(height, format: .number.precision(.fractionLength(0...1))) + Text(" ft"))
                    .fixedSize()
                if let period {
                    (Text(period.rounded, format: .number) + Text(" sec"))
                        .fixedSize()
                }
            }
            .opacity(fade)
        }
    }
}
fileprivate struct DepthValue: View {
    let value: Double?
    var body: some View {
        Group {
            if let value {
                Text(value, format: .number.precision(.fractionLength(0...1))) + Text(" ft")
            } else {
                Text("--")
                    .foregroundStyle(.secondary)
            }
        }
        .opacity(fade)
    }
}
fileprivate struct TideValue: View {
    let value: TideSnapshotSnippet?
    var body: some View {
        Group {
            if let value {
                HStack {
                    Text(value.height, format: .number.precision(.fractionLength(0...1))) + Text(" ft")
                    Image(systemName: value.movement.symbolName)
                }
            } else {
                Text("--")
                    .foregroundStyle(.secondary)
            }
        }
        .opacity(fade)
    }
}
fileprivate struct OdometerValue: View {
    let value: Int?
    var body: some View {
        PlaceholderText(value?.formatted(.number.grouping(.never)) ?? "", placeholder: "--")
            .opacity(fade)
    }
}
fileprivate struct GallonsValue: View {
    let value: Double?
    var body: some View {
        Group {
            if let value {
                Text(value, format: .number.precision(.fractionLength(0...1))) + Text(" gals")
            } else {
                Text("--")
                    .foregroundStyle(.secondary)
            }
        }
        .opacity(fade)
    }
}
