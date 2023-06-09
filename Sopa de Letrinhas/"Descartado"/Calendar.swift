//
//  File.swift
//  Sopa de Letrinhas
//
//  Created by rsbj on 24/05/23.
//

import SwiftUI

fileprivate extension DateFormatter {
    static var month: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }
    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }
}
fileprivate extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        return dates
    }
}
struct WeekView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar
    let week: Date
    let content: (Date) -> DateView
    init(week: Date, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.week = week
        self.content = content
    }
    private var days: [Date] {
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: week)
        else { return [] }
        return calendar.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    var body: some View {
        HStack {
            ForEach(days, id: \.self) { date in
                HStack {
                    if self.calendar.isDate(self.week, equalTo: date, toGranularity: .month) {
                        self.content(date)
                    } else {
                        self.content(date).hidden()
                    }
                }
            }
        }
    }
}
struct MonthView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar
    let month: Date
    let content: (Date) -> DateView
    init(month: Date, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.month = month
        self.content = content
    }
    private var weeks: [Date] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month)
        else { return [] }
        return calendar.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: 1)
        )
    }
    private var header: some View {
        let formatter = DateFormatter.month
        return Text(formatter.string(from: month))
            .font(.title)
            .minimumScaleFactor(0.1)
    }
    var body: some View {
            VStack {
                ZStack {
                    Rectangle().foregroundColor(Color(white: 0.3))
                    header
                    
                }
                ForEach(weeks, id: \.self) { week in
                    WeekView(week: week, content: self.content)
                }
            
        }
    }
}
struct CalendarView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar
    let interval: DateInterval
    let content: (Date) -> DateView
    init(interval: DateInterval, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.interval = interval
        self.content = content
    }
    private var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }

    var body: some View {
        ScrollViewReader { value in
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ForEach(months, id: \.self) { month in
                        MonthView(month: month, content: self.content)
                            .id(Int(("\(month)").dropFirst(5).dropLast(18)))
                    }
                }
            }.onAppear() {
//                value.scrollTo(Int(String(Date.now.formatted(date: .numeric, time: .shortened).dropFirst(3).dropLast(10)))!)
                value.scrollTo(5)
            }
            
        }
    }
}
struct RootView: View {
    @Environment(\.calendar) var calendar
    @State var yearTitle = ""
    @State var CurrentYear: Date = .now
//    @State var size : CGSize
    let formater = DateFormatter.monthAndYear
    private var year: DateInterval {
        calendar.dateInterval(of: .year, for: Date())!
    }
    var body: some View {
        ZStack {
            CalendarView(interval: year) { date in
/*                if String(self.calendar.component(.day, from: date)) ==
                    String(Date.now.formatted(date: .numeric, time: .shortened).prefix(2))
                    &&
                    String(self.calendar.component(.month, from: date)) ==
                    String(Int(String(Date.now.formatted(date: .numeric, time: .shortened).dropFirst(3).dropLast(11)))!) { */
                // Mds que gambiarra  que eu tinha feito, era só isso:
                if calendar.isDateInToday(date){
                    
                    
                    Text("30")
                        .hidden()
                        .padding()
                        .background(.blue)
                        .clipShape(Circle())
                        .overlay(
                            Text(String(self.calendar.component(.day, from: date)))
                                .minimumScaleFactor(0.1)
                        )
                } else {
                    Text("30")
                        .hidden()
                        .padding()
                        .background(Color(white: 0.1))
                        .clipShape(Circle())
                        .overlay(
                            Text(String(self.calendar.component(.day, from: date)))
                                .minimumScaleFactor(0.1)
                        )
                        .onAppear(){
                            yearTitle = String(self.calendar.component(.year, from: date))
                        }
                }
//                Button("Next Year", action: {
//                    calendar.component(.year, from: CurrentYear) += 1 // <- Queria fazer isso
//                })
            }.navigationTitle(yearTitle)
//                .frame(width: size.width, height: size.height)
            // Se quiser mudar o ano que está sendo mostrado no titulo tem que bulir aqui!
        }
    }
}
