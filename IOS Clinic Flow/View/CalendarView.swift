import SwiftUI

// MARK: - CalendarView

struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navTab: TabItem = .home

    // Default to February 2026 — where mock appointments live
    @State private var displayedMonth: Date = {
        var c = DateComponents(); c.year = 2026; c.month = 2; c.day = 1
        return Calendar.current.date(from: c)!
    }()

    @State private var selectedDate: Date? = {
        var c = DateComponents(); c.year = 2026; c.month = 2; c.day = 23
        return Calendar.current.date(from: c)
    }()

    private let cal = Calendar.current
    private let dayHeaders = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    private var allAppointments: [Appointment] { MockAppointments.calendarAppointments }

    // MARK: Computed stats
    private var thisMonthCount: Int {
        allAppointments.filter { apt in
            guard let d = parseAptDate(apt.date) else { return false }
            return cal.isDate(d, equalTo: displayedMonth, toGranularity: .month)
        }.count
    }

    private var upcomingCount: Int {
        allAppointments.filter { apt in
            guard let d = parseAptDate(apt.date) else { return false }
            let inMonth = cal.isDate(d, equalTo: displayedMonth, toGranularity: .month)
            return inMonth && (apt.status == .active || apt.status == .scheduled)
        }.count
    }

    private var selectedDayCount: Int {
        guard let sel = selectedDate else { return 0 }
        return appointmentsOn(sel).count
    }

    // MARK: Body
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBar(
                    title: "Calendar",
                    onBack: { dismiss() },
                    trailingIcon: "plus",
                    trailingStyle: .boxed,
                    onTrailing: {}
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Stats bar
                        statsBar
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        // Calendar card
                        calendarCard
                            .padding(.horizontal, 20)

                        // Selected day section
                        if let sel = selectedDate {
                            selectedDaySection(sel)
                                .padding(.horizontal, 20)
                        }

                        Spacer().frame(height: 100)
                    }
                }

                BottomTabBar(selectedTab: $navTab, isNeutral: true)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
    }

    // MARK: - Stats Bar
    private var statsBar: some View {
        HStack(spacing: 0) {
            statCell(value: "\(thisMonthCount)", label: "THIS MONTH", valueColor: Color(hex: "1B3A6B"))
            Divider().frame(height: 40)
            statCell(value: "\(upcomingCount)", label: "UPCOMING", valueColor: Color(hex: "22C55E"))
            Divider().frame(height: 40)
            statCell(value: "\(selectedDayCount)", label: "SELECTED DAY", valueColor: Color(hex: "F59E0B"))
        }
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private func statCell(value: String, label: String, valueColor: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("Inter_18pt-Bold", size: 22))
                .foregroundColor(valueColor)
            Text(label)
                .font(.custom("Inter_18pt-Regular", size: 10))
                .foregroundColor(.textTertiary)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Calendar Card
    private var calendarCard: some View {
        VStack(spacing: 12) {
            // Month / Year navigation
            HStack(spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayedMonth = cal.date(byAdding: .month, value: -1, to: displayedMonth)!
                        selectedDate = nil
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(hex: "F3F4F6")))
                }

                Spacer()

                HStack(spacing: 4) {
                    Text(monthString)
                        .font(.custom("Inter_18pt-SemiBold", size: 15))
                        .foregroundColor(.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, 10)

                HStack(spacing: 4) {
                    Text(yearString)
                        .font(.custom("Inter_18pt-SemiBold", size: 15))
                        .foregroundColor(.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, 10)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayedMonth = cal.date(byAdding: .month, value: 1, to: displayedMonth)!
                        selectedDate = nil
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(hex: "F3F4F6")))
                }
            }
            .padding(.horizontal, 4)

            // Day header row
            HStack(spacing: 0) {
                ForEach(dayHeaders, id: \.self) { h in
                    Text(h)
                        .font(.custom("Inter_18pt-SemiBold", size: 12))
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Date grid
            let dates = gridDates()
            let rows = dates.chunked(into: 7)
            VStack(spacing: 4) {
                ForEach(rows.indices, id: \.self) { rowIdx in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { col in
                            let date = rows[rowIdx][col]
                            dayCell(date: date, col: col)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Day Cell
    private func dayCell(date: Date?, col: Int) -> some View {
        let isSunday = col == 6
        guard let date = date else {
            return AnyView(Color.clear.frame(maxWidth: .infinity).frame(height: 48))
        }

        let inThisMonth = cal.isDate(date, equalTo: displayedMonth, toGranularity: .month)
        let isToday = cal.isDateInToday(date)
        let isSelected = selectedDate.map { cal.isDate(date, inSameDayAs: $0) } ?? false
        let dayNum = cal.component(.day, from: date)
        let dots = inThisMonth ? appointmentDots(for: date) : []

        return AnyView(
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "1B3A6B"))
                            .frame(width: 34, height: 34)
                    } else if isToday {
                        Circle()
                            .stroke(Color(hex: "1B3A6B"), lineWidth: 1.5)
                            .frame(width: 34, height: 34)
                    }

                    Text("\(dayNum)")
                        .font(.custom(isSelected || isToday ? "Inter_18pt-Bold" : "Inter_18pt-Regular", size: 13))
                        .foregroundColor(
                            isSelected ? .white :
                            !inThisMonth ? Color(hex: "C4CBD8") :
                            isToday ? Color(hex: "1B3A6B") :
                            isSunday ? Color(hex: "3B82F6") :
                            .textPrimary
                        )
                }
                .frame(width: 34, height: 34)

                // Appointment dots
                HStack(spacing: 3) {
                    ForEach(Array(dots.prefix(3).enumerated()), id: \.offset) { _, color in
                        Circle()
                            .fill(color)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                if inThisMonth {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedDate = date
                    }
                }
            }
        )
    }

    // MARK: - Selected Day Section
    private func selectedDaySection(_ date: Date) -> some View {
        let apts = appointmentsOn(date)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(selectedDayLabel(date))
                    .font(.custom("Inter_18pt-Bold", size: 17))
                    .foregroundColor(.textPrimary)
                Spacer()
                let count = apts.count
                Text("\(count) appointment\(count == 1 ? "" : "s")")
                    .font(.custom("Inter_18pt-SemiBold", size: 13))
                    .foregroundColor(.primaryBlue)
            }

            if apts.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 32))
                            .foregroundColor(Color(hex: "C4CBD8"))
                        Text("No appointments")
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
            } else {
                ForEach(apts) { apt in
                    appointmentCard(apt)
                }
            }
        }
    }

    // MARK: - Appointment Card
    private func appointmentCard(_ apt: Appointment) -> some View {
        let leftColor = statusAccentColor(apt.status)

        return ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)

            VStack(spacing: 0) {
                // Main content
                HStack(alignment: .top, spacing: 12) {
                    // Left accent strip
                    RoundedRectangle(cornerRadius: 3)
                        .fill(leftColor)
                        .frame(width: 4)
                        .padding(.vertical, 2)

                    VStack(alignment: .leading, spacing: 6) {
                        // ID + status badge row
                        HStack(alignment: .center) {
                            HStack(spacing: 5) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 11))
                                    .foregroundColor(.textTertiary)
                                Text("#\(shortId(apt.id))")
                                    .font(.custom("Inter_18pt-Medium", size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                            Spacer()
                            statusLabel(apt.status)
                        }

                        // Doctor name
                        Text(apt.doctor.name)
                            .font(.custom("Inter_18pt-Bold", size: 15))
                            .foregroundColor(.textPrimary)

                        // Specialty
                        Text(apt.doctor.specialty)
                            .font(.custom("Inter_18pt-Regular", size: 12))
                            .foregroundColor(.textSecondary)

                        // Time + location row
                        HStack(spacing: 14) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 11))
                                    .foregroundColor(.textTertiary)
                                Text(apt.time)
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.textSecondary)
                            }

                            if apt.status == .active || apt.status == .scheduled {
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin")
                                        .font(.system(size: 11))
                                        .foregroundColor(.textTertiary)
                                    Text(apt.location)
                                        .font(.custom("Inter_18pt-Regular", size: 12))
                                        .foregroundColor(.textSecondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.trailing, 14)
                }

                // Queue row for active appointments
                if apt.status == .active, let pos = apt.queuePosition {
                    Divider()
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.textTertiary)
                        Text("\(ordinal(pos)) in queue  ·  Tap to View")
                            .font(.custom("Inter_18pt-Medium", size: 12))
                            .foregroundColor(.textSecondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11))
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(hex: "F8F9FB"))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Status label badge
    @ViewBuilder
    private func statusLabel(_ status: AppointmentStatus) -> some View {
        switch status {
        case .active:
            Text("Active Now")
                .font(.custom("Inter_18pt-SemiBold", size: 11))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color(hex: "1B3A6B")))
        case .scheduled:
            Text("Scheduled")
                .font(.custom("Inter_18pt-SemiBold", size: 11))
                .foregroundColor(Color(hex: "64748B"))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color(hex: "EFF2F7")))
        case .completed:
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .bold))
                Text("Completed")
                    .font(.custom("Inter_18pt-SemiBold", size: 11))
            }
            .foregroundColor(Color(hex: "16A34A"))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color(hex: "DCFCE7")))
        case .cancelled:
            HStack(spacing: 4) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                Text("Cancelled")
                    .font(.custom("Inter_18pt-SemiBold", size: 11))
            }
            .foregroundColor(Color(hex: "DC2626"))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color(hex: "FEE2E2")))
        }
    }

    // MARK: - Helpers

    private func appointmentsOn(_ date: Date) -> [Appointment] {
        allAppointments.filter { apt in
            guard let d = parseAptDate(apt.date) else { return false }
            return cal.isDate(d, inSameDayAs: date)
        }
    }

    private func appointmentDots(for date: Date) -> [Color] {
        appointmentsOn(date).map { statusAccentColor($0.status) }
    }

    private func statusAccentColor(_ status: AppointmentStatus) -> Color {
        switch status {
        case .active:    return Color(hex: "1B3A6B")
        case .scheduled: return Color(hex: "3B82F6")
        case .completed: return Color(hex: "22C55E")
        case .cancelled: return Color(hex: "EF4444")
        }
    }

    private func parseAptDate(_ raw: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.date(from: raw)
    }

    private func gridDates() -> [Date?] {
        guard let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: displayedMonth)) else { return [] }
        let weekday = cal.component(.weekday, from: monthStart) // Sun=1, Mon=2...Sat=7
        let offset = (weekday - 2 + 7) % 7 // Monday-first: Mon=0...Sun=6

        let daysInMonth = cal.range(of: .day, in: .month, for: displayedMonth)!.count
        var dates: [Date?] = []

        // Previous month fill
        for i in stride(from: offset, through: 1, by: -1) {
            dates.append(cal.date(byAdding: .day, value: -i, to: monthStart))
        }
        // Current month
        for i in 0..<daysInMonth {
            dates.append(cal.date(byAdding: .day, value: i, to: monthStart))
        }
        // Next month fill
        let lastDay = cal.date(byAdding: .day, value: daysInMonth - 1, to: monthStart)!
        let remainder = (7 - dates.count % 7) % 7
        for i in 1...max(1, remainder) {
            if i <= remainder {
                dates.append(cal.date(byAdding: .day, value: i, to: lastDay))
            }
        }
        return dates
    }

    private var monthString: String {
        let df = DateFormatter()
        df.dateFormat = "MMMM"
        return df.string(from: displayedMonth)
    }

    private var yearString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy"
        return df.string(from: displayedMonth)
    }

    private func selectedDayLabel(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM d"
        return df.string(from: date)
    }

    private func shortId(_ id: String) -> String {
        // Take last 6 chars or the full id if shorter
        let parts = id.components(separatedBy: "-")
        if parts.count >= 2 {
            return parts.dropFirst().joined(separator: "-")
        }
        return id
    }

    private func ordinal(_ n: Int) -> String {
        let suffix: String
        switch n % 100 {
        case 11, 12, 13: suffix = "th"
        default:
            switch n % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        return "\(n)\(suffix)"
    }
}

// MARK: - Array chunking helper
private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
