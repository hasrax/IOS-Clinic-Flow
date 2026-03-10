import Foundation

struct MockDoctors {
    static let all: [Doctor] = [
        Doctor(id: "D001", name: "Dr. Prasad Pathirana", specialty: "Neurologist",
               fee: 1500, rating: 4.7, experience: 8, location: "Room 89B, Floor 3",
               avatar: "doctor_kamal", nextAvailable: "Today ( 23 Feb, 2025 )  2.30 pm", roomNumber: "89B"),
        Doctor(id: "D002", name: "Dr. Hasra Kavindi", specialty: "Cardiologist",
               fee: 5500, rating: 3.7, experience: 3, location: "Room 2C, Floor 2",
               avatar: "doctor_nipun", nextAvailable: "Today ( 23 Feb, 2025 )  7.00 pm", roomNumber: "2C"),
        Doctor(id: "D003", name: "Dr. Asini Vihanga", specialty: "Pulmonologist",
               fee: 1000, rating: 1.7, experience: 1, location: "Room 64F, Floor 2",
               avatar: "doctor_kamal", nextAvailable: "Today ( 23 Feb, 2025 )  9.30 pm", roomNumber: "64F"),
        Doctor(id: "D004", name: "Dr. Lakshan Perera", specialty: "Immunologist",
               fee: 2500, rating: 2.0, experience: 1, location: "Room 9N, Floor 1",
               avatar: "doctor_nipun", nextAvailable: "Today ( 23 Feb, 2025 )  6.30 pm", roomNumber: "9N"),
        Doctor(id: "D005", name: "Dr. Samantha Perera", specialty: "General Medicine",
               fee: 1500, rating: 4.9, experience: 12, location: "Room 204, Floor 2",
               avatar: "doctor_kamal", nextAvailable: "Today, 2:30 PM", roomNumber: "204"),
    ]

    static let specialties = [
        "Cardiology", "Neurology", "Pulmonology",
        "Immunology", "General Medicine", "Ophthalmology", "ENT"
    ]
}
//mock doc detils because hard coded bro
