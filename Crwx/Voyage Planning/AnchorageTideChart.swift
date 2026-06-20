//
//  AnchorageTideChart.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/13/25.
//

import SwiftUI
import Charts
import FoundationSalt
import WxSalt

struct AnchorageTideChart: View {
    let plots: [TidePrediction]
    let days: ClosedRange<Date>
    let tideAtArrival: TideSnapshot?
    var body: some View {
        let heights = plots.map {
            $0.height.converted(to: .feet).value
        }
        let min = heights.min()?.rounded(3, .down) ?? 0
        let max = (heights.max()?.rounded(3, .up) ?? 15) + 3
        Chart {
            
            // tide curve
            ForEach(plots.series, id: \.label) { series in
                ForEach(series.values) { plot in
                    LineMark(
                        x: .value("Hour", plot.x),
                        y: .value("Height", plot.y)
                    )
                    AreaMark(
                        x: .value("Hour", plot.x),
                        yStart: .value("Height", 0),
                        yEnd: .value("Height", plot.y)
                    )
                    .opacity(0.3)
                }
                .foregroundStyle(by: .value("Type", series.label))
                .lineStyle(StrokeStyle(lineWidth: 3))
            }
            .interpolationMethod(.cardinal)

            // hi, lo annotations
            ForEach(plots, id: \.date) { provider in
                PointAnnotation(
                    label: provider.date.formatted(.dateTime.hour().minute()),
//                    label: provider.height.converted(to: .feet).value.rounded(0.1).formatted(.number),
                    hour: provider.date,
                    value: provider.height.converted(to: .feet).value, style: .blue
                )
            }

            // tide at arrival
            if let tideAtArrival {
                PointAnnotation(label: nil, hour: tideAtArrival.date, value: tideAtArrival.height.converted(to: .feet).value, style: .white)
            }

        }
        .chartLegend(.hidden)
        .chartXScale(domain: days, type: .linear)
        .chartYScale(domain: min...max, type: .linear)
        .chartPlotStyle { content in
            content
                .clipped()
        }
        .chartYAxis {
            AxisMarks(values: .stride(by: 3)) { value in
                AxisGridLine()
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 12)) { value in
                AxisGridLine(stroke: StrokeStyle())
                if let date = value.as(Date.self) {
                    if date == date.withoutTime {
                        AxisValueLabel(format: .dateTime.weekday())
                    }
                }
            }
        }
    }

}
