//
//  BookingDetailsView.swift
//  IOS Clinic Flow
//
//  Created by Lakindu Siriwardena on 2026-03-09.
//


import SwiftUI

struct BookingDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    //backbutton as always *eye roll*
    let doctor: Doctor
    //constatly hooked on to which doctor was selected in the past screen
    @State private var selectedTab = 0 // used to track the page that has been selected pages are as followx 0: Information, 1: Experience, 2: Reviews
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var selectedTimeSlot: TimeSlot?
    @State private var selectedTimePeriod = 0 // like before tracks the selected time selected0: Morning, 1: Afternoon, 2: Evening
    @State private var reasonForVisit = ""
    @State private var bookingForDependent = false
    //companion case
    @State private var showBookingSuccess = false
    //true == going to the success page DO NOT TOUCH
    @State private var navTab: TabItem = .home
    
    let tabs = ["Information", "Experience", "Reviews"]
    let timePeriods = ["Morning", "Afternoon", "Evening"]
    //definitations of tabs and timeperiod
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom nav bar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryBlue)
                    }
                    Spacer()
                    Text("Schedule Visit")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // doctors info
                        DoctorInfoHeader(doctor: doctor)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        
                        // doctors tabs
                        DoctorTabs(selectedTab: $selectedTab, tabs: tabs)
                            .padding(.horizontal, 20)
                        
                        // content of the tab
                        DoctorTabContent(selectedTab: selectedTab, doctor: doctor)
                            .padding(.horizontal, 20)
                        
                        // date selection
                        DateSelectionSection(
                            selectedDate: $selectedDate,
                            currentMonth: $currentMonth
                        )
                        .padding(.horizontal, 20)
                        
                        // time selection design
                        TimeSelectionSection(
                            selectedTimePeriod: $selectedTimePeriod,
                            selectedTimeSlot: $selectedTimeSlot,
                            timePeriods: timePeriods
                        )
                        .padding(.horizontal, 20)
                        
                        // paitents details
                        PatientDetailsSection(
                            reasonForVisit: $reasonForVisit,
                            bookingForDependent: $bookingForDependent
                        )
                        .padding(.horizontal, 20)
                        
                        // payment summery design
                        PaymentSummarySection(
                            doctor: doctor,
                            selectedDate: selectedDate,
                            selectedTimeSlot: selectedTimeSlot,
                            onConfirm: {
                                showBookingSuccess = true
                            }
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer().frame(height: 100)
                    }
                }

                // bottom nav as always
                BottomTabBar(selectedTab: $navTab, isNeutral: true)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { if AppRouter.shared.pendingTab != nil { dismiss() } }
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
        .navigationDestination(isPresented: $showBookingSuccess) {
            BookingSuccessView(
                doctor: doctor,
                selectedDate: selectedDate,
                selectedTimeSlot: selectedTimeSlot,
                isPaid: false
            )
        }
    }
}

// doctors information
struct DoctorInfoHeader: View {
    let doctor: Doctor
    
    var body: some View {
        HStack(spacing: 14) {
            Image(doctor.avatar)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.surfaceMuted, lineWidth: 1)
                )
            //docs pic
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(doctor.name)
                        .font(.custom("Inter_18pt-Bold", size: 16))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text("Rs.\(String(format: "%.2f", Double(doctor.fee)))")
                        .font(.custom("Inter_18pt-Bold", size: 14))
                        .foregroundColor(.primaryBlue)
                }
                
                Text(doctor.specialty)
                    .font(.custom("Inter_18pt-Regular", size: 12))
                    .foregroundColor(.textSecondary)
                //same set up and layout as the DOCTORCARD in the booking search thing
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "F59E0B"))
                        Text(String(format: "%.1f", doctor.rating))
                            .font(.custom("Inter_18pt-Medium", size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.textTertiary)
                        Text("\(doctor.experience) Years")
                            .font(.custom("Inter_18pt-Medium", size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.textTertiary)
                        Text(doctor.location)
                            .font(.custom("Inter_18pt-Medium", size: 12))
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// doctor tabs designs
struct DoctorTabs: View {
    @Binding var selectedTab: Int
    let tabs: [String]
    //two way binging to move to the before and after tabs as well
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(tabs[index])
                            .font(.custom(selectedTab == index ? "Inter_18pt-SemiBold" : "Inter_18pt-Regular", size: 14))
                            .foregroundColor(selectedTab == index ? .primaryBlue : .textTertiary)
                        
                        Rectangle()
                            .fill(selectedTab == index ? Color.primaryBlue : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.surfaceMuted)
                    .frame(height: 1)
            }
        )
    }
}

// switches depending on whichtab is selected basucallt the doc tabs
struct DoctorTabContent: View {
    let selectedTab: Int
    let doctor: Doctor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch selectedTab {
                //description tab
            case 0:
                Text("\(doctor.name) working in the field of neurology in Sri Lanka for over a decade, focusing on stroke management, epilepsy care and neuro-rehabilitation. He is known for a compassionate approach, clear explanations and using up-to-date diagnostic tools. He regularly publishes case studies in peer-reviewed journals and participates in community outreach programs on stroke awareness.")
                    .font(.custom("Inter_18pt-Regular", size: 13))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)
                //shot informations tab
            case 1:
                VStack(alignment: .leading, spacing: 8) {
                    Text("Experience: \(doctor.experience) Years")
                        .font(.custom("Inter_18pt-SemiBold", size: 14))
                        .foregroundColor(.textPrimary)
                    Text("Specialization in \(doctor.specialty)")
                        .font(.custom("Inter_18pt-Regular", size: 13))
                        .foregroundColor(.textSecondary)
                    Text("Location: \(doctor.location)")
                        .font(.custom("Inter_18pt-Regular", size: 13))
                        .foregroundColor(.textSecondary)
                }
                //stars setion
            case 2:
                VStack(alignment: .leading, spacing: 8) {
                    Text("Patient Reviews")
                        .font(.custom("Inter_18pt-SemiBold", size: 14))
                        .foregroundColor(.textPrimary)
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(doctor.rating) ? "star.fill" : "star")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "F59E0B"))
                        }
                        Text("(\(String(format: "%.1f", doctor.rating)))")
                            .font(.custom("Inter_18pt-Regular", size: 13))
                            .foregroundColor(.textSecondary)
                    }
                    Text("Based on 124 reviews")
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textTertiary)
                }
                //outlier defense lol
            default:
                EmptyView()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// used to select the DATE
struct DateSelectionSection: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
  //device cal info
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Date")
                .font(.custom("Inter_18pt-SemiBold", size: 16))
                .foregroundColor(.textPrimary)
            //move tot he left
            VStack(spacing: 12) {
                // Month/Year Header
                HStack {
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primaryBlue)
                    }
                    
                    Spacer()
                  //month view
                    HStack(spacing: 8) {
                        Menu {
                            ForEach(1...12, id: \.self) { month in
                                Button(DateFormatter().monthSymbols[month - 1]) {
                                    if let newDate = calendar.date(bySetting: .month, value: month, of: currentMonth) {
                                        currentMonth = newDate
                                    }
                                }
                            }
                            //tap to see all months
                        } label: {
                            HStack(spacing: 4) {
                                Text(dateFormatter.string(from: currentMonth))
                                    .font(.custom("Inter_18pt-SemiBold", size: 15))
                                    .foregroundColor(.textPrimary)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        //year view just like months
                        Menu {
                            ForEach(2024...2030, id: \.self) { year in
                                Button(String(year)) {
                                    if let newDate = calendar.date(bySetting: .year, value: year, of: currentMonth) {
                                        currentMonth = newDate
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(yearFormatter.string(from: currentMonth))
                                    .font(.custom("Inter_18pt-SemiBold", size: 15))
                                    .foregroundColor(Color(hex: "F59E0B"))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                }
                
                // used to check the DAYS OF THE WEEK
                HStack(spacing: 0) {
                    ForEach(["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"], id: \.self) { day in
                        Text(day)
                            .font(.custom("Inter_18pt-Medium", size: 12))
                            .foregroundColor(.textTertiary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar design call
                CalendarGridView(
                    currentMonth: currentMonth,
                    selectedDate: $selectedDate
                )
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}

// cal design
struct CalendarGridView: View {
    let currentMonth: Date
    @Binding var selectedDate: Date
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) { //renders available items
            ForEach(daysInMonth(), id: \.self) { date in
                if let date = date {
                    let day = calendar.component(.day, from: date)
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate) //checks if user selected this
                    let isToday = calendar.isDateInToday(date) //is the date today
                    let isPast = date < calendar.startOfDay(for: Date())
                    //used to disable password
                    Button {
                        if !isPast {
                            selectedDate = date
                        }
                    } label: {
                        Text("\(day)")
                            .font(.custom(isSelected ? "Inter_18pt-Bold" : "Inter_18pt-Regular", size: 14))
                            .foregroundColor(
                                isPast ? .textTertiary :
                                isSelected ? .white :
                                isToday ? .primaryBlue : .textPrimary
                            )
                            .frame(width: 36, height: 36)
                            .background(
                                Group {
                                    if isSelected {
                                        Circle().fill(Color.primaryBlue)
                                    } else if isToday {
                                        Circle().stroke(Color.primaryBlue, lineWidth: 1)
                                    } else {
                                        Circle().fill(Color.clear)
                                    }
                                }
                            )
                    }
                    .disabled(isPast)
                } else {
                    Text("")
                        .frame(width: 36, height: 36)
                }
            }
        }//used to disable past dates
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        
        let offset = (firstWeekday + 5) % 7
        
        // empty cells for days
        for _ in 0..<offset {
            days.append(nil)
        }
        
        // Add days of the month
        var currentDate = firstDayOfMonth
        while calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month) {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
}

// time slots
struct TimeSlot: Identifiable, Equatable {
    var id: String { time }
    let time: String
    let bookedCount: Int
    let maxCount: Int
    //timeslot as a string and the people who have booked it and others
    var isFull: Bool { bookedCount >= maxCount }
    var displayText: String {
        if isFull {
            return "Full"
        }
        return "\(bookedCount)/\(maxCount) Booked"
    }
}

// availabletime slots
struct TimeSelectionSection: View {
    @Binding var selectedTimePeriod: Int
    @Binding var selectedTimeSlot: TimeSlot?
    let timePeriods: [String]
    
    let morningSlots = [
        TimeSlot(time: "8:30 AM",  bookedCount: 3, maxCount: 8),
        TimeSlot(time: "9:00 AM",  bookedCount: 3, maxCount: 7),
        TimeSlot(time: "9:30 AM",  bookedCount: 8, maxCount: 8),
        TimeSlot(time: "10:00 AM", bookedCount: 6, maxCount: 8),
        TimeSlot(time: "10:30 AM", bookedCount: 8, maxCount: 8),
        TimeSlot(time: "11:00 AM", bookedCount: 7, maxCount: 8),
    ]
    let afternoonSlots = [
        TimeSlot(time: "12:00 PM", bookedCount: 2, maxCount: 8),
        TimeSlot(time: "12:30 PM", bookedCount: 5, maxCount: 8),
        TimeSlot(time: "1:00 PM",  bookedCount: 4, maxCount: 8),
        TimeSlot(time: "1:30 PM",  bookedCount: 8, maxCount: 8),
        TimeSlot(time: "2:00 PM",  bookedCount: 6, maxCount: 8),
        TimeSlot(time: "2:30 PM",  bookedCount: 3, maxCount: 8),
    ]
    let eveningSlots = [
        TimeSlot(time: "3:00 PM",  bookedCount: 1, maxCount: 8),
        TimeSlot(time: "3:30 PM",  bookedCount: 4, maxCount: 8),
        TimeSlot(time: "4:00 PM",  bookedCount: 8, maxCount: 8),
        TimeSlot(time: "4:30 PM",  bookedCount: 2, maxCount: 8),
        TimeSlot(time: "5:00 PM",  bookedCount: 7, maxCount: 8),
        TimeSlot(time: "5:30 PM",  bookedCount: 6, maxCount: 8),
    ]
    var currentSlots: [TimeSlot] {
        switch selectedTimePeriod {
        case 0:  return morningSlots
        case 1:  return afternoonSlots
        case 2:  return eveningSlots
        default: return morningSlots
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Time")
                .font(.custom("Inter_18pt-SemiBold", size: 16))
                .foregroundColor(.textPrimary)
            
            // to check wether the meetings o the morning arternoon or night
            HStack(spacing: 8) {
                ForEach(0..<timePeriods.count, id: \.self) { index in
                    Button {
                        withAnimation {
                            selectedTimePeriod = index
                            selectedTimeSlot = nil
                        }
                    } label: {
                        Text(timePeriods[index])
                            .font(.custom(selectedTimePeriod == index ? "Inter_18pt-SemiBold" : "Inter_18pt-Regular", size: 13))
                            .foregroundColor(selectedTimePeriod == index ? .white : .textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                selectedTimePeriod == index ?
                                AnyView(LinearGradient.primaryGradient) :
                                AnyView(Color.surfaceMuted)
                            )
                            .cornerRadius(20)
                    }
                }
            }
            
            // Time Slots Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(currentSlots) { slot in
                    TimeSlotButton(
                        slot: slot,
                        isSelected: selectedTimeSlot?.id == slot.id,
                        onSelect: {
                            if !slot.isFull {
                                selectedTimeSlot = slot
                            }
                        }
                    )
                }
            }
        }
    }
}

// time sloth button designs
struct TimeSlotButton: View {
    let slot: TimeSlot
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                Text(slot.time)
                    .font(.custom("Inter_18pt-SemiBold", size: 13))
                    .foregroundColor(
                        slot.isFull ? .textTertiary :
                        isSelected ? .white : .textPrimary
                    )
                Text(slot.displayText)
                    .font(.custom("Inter_18pt-Regular", size: 10))
                    .foregroundColor(
                        slot.isFull ? .errorRed :
                        isSelected ? .white.opacity(0.85) : .primaryBlue
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                slot.isFull ? Color(hex: "F9FAFB") :
                isSelected ? Color.primaryBlue : Color.white
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? Color.primaryBlue :
                        Color.surfaceMuted,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .disabled(slot.isFull)
    }
}

// paitent deatils
struct PatientDetailsSection: View {
    @Binding var reasonForVisit: String
    @Binding var bookingForDependent: Bool
    @State private var dependentName: String = ""
    @State private var selectedRelationship: String = ""
    @State private var showRelationshipPicker: Bool = false

    let relationships = ["Spouse", "Child", "Parent", "Sibling", "Grandparent", "Other"]
//if its companion and ur booking for someone else selecrtion for status of relationship wirth paitent
    
    //paitent details setting
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Patient Details")
                .font(.custom("Inter_18pt-SemiBold", size: 16))
                .foregroundColor(.textPrimary)

            VStack(alignment: .leading, spacing: 16) {
                // visit reason
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reason for Visit")
                        .font(.custom("Inter_18pt-Medium", size: 13))
                        .foregroundColor(.textSecondary)

                    TextField("Describe symptoms or reason.....", text: $reasonForVisit, axis: .vertical)
                        .font(.custom("Inter_18pt-Regular", size: 14))
                        .foregroundColor(.textPrimary)
                        .lineLimit(3...5)
                        .padding(12)
                        .background(Color(hex: "F9FAFB"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.surfaceMuted, lineWidth: 1)
                        )
                }

                // dependent booking toggle
                HStack(spacing: 12) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.primaryBlue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Booking for a dependent ?")
                            .font(.custom("Inter_18pt-Medium", size: 14))
                            .foregroundColor(.textPrimary)
                        Text("Child , elderly parent, etc.")
                            .font(.custom("Inter_18pt-Regular", size: 12))
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: $bookingForDependent.animation(.easeInOut))
                        .labelsHidden()
                        .tint(.primaryBlue)
                }

                // toggle active (design)
                if bookingForDependent {
                    VStack(alignment: .leading, spacing: 16) {
                        // Patient Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Patient Name")
                                .font(.custom("Inter_18pt-Medium", size: 13))
                                .foregroundColor(.textSecondary)

                            TextField("Enter Patient Name", text: $dependentName)
                                .font(.custom("Inter_18pt-Regular", size: 14))
                                .foregroundColor(.textPrimary)
                                .padding(14)
                                .background(Color(hex: "F9FAFB"))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.surfaceMuted, lineWidth: 1)
                                )
                        }

                        // relationship drop down (design)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Relationship")
                                .font(.custom("Inter_18pt-Medium", size: 13))
                                .foregroundColor(.textSecondary)

                            Menu {
                                ForEach(relationships, id: \.self) { rel in
                                    Button(rel) {
                                        selectedRelationship = rel
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedRelationship.isEmpty ? "Select Relationship" : selectedRelationship)
                                        .font(.custom("Inter_18pt-Regular", size: 14))
                                        .foregroundColor(selectedRelationship.isEmpty ? Color.textTertiary : .textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 13))
                                        .foregroundColor(.textSecondary)
                                }
                                .padding(14)
                                .background(Color(hex: "F9FAFB"))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.surfaceMuted, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}

// payment summery
struct PaymentSummarySection: View {
    let doctor: Doctor
    let selectedDate: Date
    let selectedTimeSlot: TimeSlot?
    let onConfirm: () -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()
    
    var totalAmount: Int {
        doctor.fee + 100 // consultation + service charge
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Summary")
                .font(.custom("Inter_18pt-SemiBold", size: 16))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                // Consultation Fee
                HStack {
                    Text("Consultation Fee")
                        .font(.custom("Inter_18pt-Regular", size: 14))
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text("LKR \(String(format: "%.2f", Double(doctor.fee)))")
                        .font(.custom("Inter_18pt-Medium", size: 14))
                        .foregroundColor(.textPrimary)
                }
                
                // Service Charge
                HStack {
                    Text("Service Charge")
                        .font(.custom("Inter_18pt-Regular", size: 14))
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text("LKR 100.00")
                        .font(.custom("Inter_18pt-Medium", size: 14))
                        .foregroundColor(.textPrimary)
                }
                
                Divider()
                
                // Total
                HStack {
                    Text("Total")
                        .font(.custom("Inter_18pt-SemiBold", size: 14))
                        .foregroundColor(.primaryBlue)
                    Spacer()
                    Text("LKR \(String(format: "%.2f", Double(totalAmount)))")
                        .font(.custom("Inter_18pt-Bold", size: 16))
                        .foregroundColor(.primaryBlue)
                }
                
                // options so the user can select to pay when they want to or select what and when to pay depending on their client level*
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "F59E0B"))
                    Text("pay online now or at the clinic counter")
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(Color(hex: "F59E0B"))
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            //confirmbutton
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(dateFormatter.string(from: selectedDate)) - \(selectedTimeSlot?.time ?? "8.30 AM")")
                        .font(.custom("Inter_18pt-Medium", size: 13))
                        .foregroundColor(.textSecondary)
                    Text("LKR \(String(format: "%.2f", Double(totalAmount)))")
                        .font(.custom("Inter_18pt-Bold", size: 15))
                        .foregroundColor(.primaryBlue)
                }
                
                Spacer()
                
                Button(action: onConfirm) {
                    Text("Confirm Booking")
                        .font(.custom("Inter_18pt-SemiBold", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            selectedTimeSlot == nil
                            ? AnyView(Color(hex: "B0B8C8"))
                            : AnyView(LinearGradient.primaryGradient)
                        )
                        .cornerRadius(12)
                }
                .disabled(selectedTimeSlot == nil)
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    NavigationStack {
        BookingDetailsView(doctor: MockDoctors.all[0])
    }
}
