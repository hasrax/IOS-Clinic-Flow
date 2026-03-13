//
//  BookingSearchView.swift
//  IOS Clinic Flow
//
//  Created by Lakindu Siriwardena on 2026-03-09.
//
import SwiftUI

struct BookingSearchView: View {
    @Environment(\.dismiss) private var dismiss
    //used to go back to the original page from this page
    @State private var searchText = ""
    @State private var specializationText = ""
    //setting for the doctors name and spacialization
    @State private var selectedDoctor: Doctor?
    //stores the doctor the user taps on
    @State private var showDoctorDetails = false
    @State private var navTab: TabItem = .home
    //returns doctors depending on what the user searchs
    var filteredDoctors: [Doctor] {
        let doctors = MockDoctors.all
        if searchText.isEmpty && specializationText.isEmpty {
            return doctors
        }
        //if all the fields are epmty it sends all the doctors names
        return doctors.filter { doctor in
            let matchesName = searchText.isEmpty || doctor.name.lowercased().contains(searchText.lowercased())
            //if the user enters all lowercased then it makes the search case insensitive
            let matchesSpecialty = specializationText.isEmpty || doctor.specialty.lowercased().contains(specializationText.lowercased())
            //same logic but for the spaciality
            return matchesName && matchesSpecialty
        }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            //sets color to bgc
            VStack(spacing: 0) {
                // Custom nav bar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryBlue)
                    }
                    Spacer()
                    Text("Book Appointment")
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
                        // Search Fields
                        VStack(spacing: 12) {
                            //doctor search design
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 16))
                                    .foregroundColor(.textTertiary)
                                TextField("Doctor's Name", text: $searchText)
                                    .font(.custom("Inter_18pt-Regular", size: 14))
                                    .foregroundColor(.textPrimary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.surfaceMuted, lineWidth: 1)
                            )
                            
                            //spacialization design structure
                            HStack(spacing: 12) {
                                Image(systemName: "stethoscope")
                                    .font(.system(size: 16))
                                    .foregroundColor(.textTertiary)
                                TextField("Specialization (e.g Cardiology)", text: $specializationText)
                                    .font(.custom("Inter_18pt-Regular", size: 14))
                                    .foregroundColor(.textPrimary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.surfaceMuted, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // find doctor section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Find Doctors")
                                .font(.custom("Inter_18pt-SemiBold", size: 14))
                                .foregroundColor(.textSecondary)
                                .padding(.horizontal, 20)
                            
                            //this is basically going through all the filtered doctors and giving them their very own card YEY
                            VStack(spacing: 12) {
                                ForEach(filteredDoctors) { doctor in
                                    DoctorCard(doctor: doctor)
                                        .onTapGesture {
                                            selectedDoctor = doctor
                                            showDoctorDetails = true
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer().frame(height: 100)
                    }
                }
                
              //here on is the bottom nav
                BottomTabBar(selectedTab: $navTab, isNeutral: true)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { if AppRouter.shared.pendingTab != nil { dismiss() } }
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
        .navigationDestination(isPresented: $showDoctorDetails) {
            if let doctor = selectedDoctor {
                BookingDetailsView(doctor: doctor)
            }
        }
    }
}

//design for the doctors cards so FUN
struct DoctorCard: View {
    let doctor: Doctor
    
    var body: some View {
        HStack(spacing: 14) {
            // doctors photo
            Image(doctor.avatar)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.surfaceMuted, lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                // doctors name and how much a meeting will cost you
                HStack {
                    Text(doctor.name)
                        .font(.custom("Inter_18pt-Bold", size: 15))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text("Rs. \(String(format: "%.2f", Double(doctor.fee)))")
                        .font(.custom("Inter_18pt-Bold", size: 14))
                        .foregroundColor(.primaryBlue)
                }
                
                // Specialty
                Text(doctor.specialty.lowercased())
                    .font(.custom("Inter_18pt-Regular", size: 12))
                    .foregroundColor(.textSecondary)
                
                // rating the doc currently has
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "F59E0B"))
                        Text(String(format: "%.1f", doctor.rating))
                            .font(.custom("Inter_18pt-Medium", size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    
                    //exp of the docc
                    HStack(spacing: 4) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.textTertiary)
                        Text("\(doctor.experience) Years")
                            .font(.custom("Inter_18pt-Medium", size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    
                    //room num of doc on dat day
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
                
                // is the doc available for the set date?
                Text("Available : \(doctor.nextAvailable)")
                    .font(.custom("Inter_18pt-SemiBold", size: 12))
                    .foregroundColor(.primaryBlue)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        BookingSearchView()
    }
}
