/// Mock data for donors and blood requests
/// TODO: Replace with Firebase Firestore queries in backend integration
library;

class MockData {
  // Mock donors list
  static List<Map<String, dynamic>> donors = [
    {
      "name": "Ali Khan",
      "bloodGroup": "A+",
      "distanceKm": 0.4,
      "city": "Islamabad",
      "isAvailable": true,
      "phone": "+92 300 1234567",
      "lastDonation": "2 months ago",
    },
    {
      "name": "Fatima Ahmed",
      "bloodGroup": "B+",
      "distanceKm": 1.2,
      "city": "Rawalpindi",
      "isAvailable": true,
      "phone": "+92 301 2345678",
      "lastDonation": "1 month ago",
    },
    {
      "name": "Hassan Malik",
      "bloodGroup": "O+",
      "distanceKm": 0.8,
      "city": "Islamabad",
      "isAvailable": true,
      "phone": "+92 302 3456789",
      "lastDonation": "3 months ago",
    },
    {
      "name": "Ayesha Sheikh",
      "bloodGroup": "AB+",
      "distanceKm": 2.1,
      "city": "Islamabad",
      "isAvailable": false,
      "phone": "+92 303 4567890",
      "lastDonation": "2 weeks ago",
    },
    {
      "name": "Usman Ali",
      "bloodGroup": "A-",
      "distanceKm": 1.5,
      "city": "Rawalpindi",
      "isAvailable": true,
      "phone": "+92 304 5678901",
      "lastDonation": "4 months ago",
    },
    {
      "name": "Zainab Khan",
      "bloodGroup": "O-",
      "distanceKm": 0.6,
      "city": "Islamabad",
      "isAvailable": true,
      "phone": "+92 305 6789012",
      "lastDonation": "1 month ago",
    },
  ];

  // Mock blood requests list
  static List<Map<String, dynamic>> requests = [
    {
      "name": "Ahmed Hospital",
      "bloodGroup": "A+",
      "units": 2,
      "distanceKm": 0.5,
      "city": "Islamabad",
      "urgency": "High",
      "hospital": "Shifa International",
      "note": "Urgent surgery required",
      "timeAgo": "2 hours ago",
    },
    {
      "name": "PIMS",
      "bloodGroup": "B+",
      "units": 1,
      "distanceKm": 1.8,
      "city": "Islamabad",
      "urgency": "Medium",
      "hospital": "Pakistan Institute of Medical Sciences",
      "note": "Regular transfusion needed",
      "timeAgo": "5 hours ago",
    },
    {
      "name": "City Hospital",
      "bloodGroup": "O+",
      "units": 3,
      "distanceKm": 2.3,
      "city": "Rawalpindi",
      "urgency": "High",
      "hospital": "City Hospital Rawalpindi",
      "note": "Emergency case",
      "timeAgo": "1 hour ago",
    },
    {
      "name": "AFIC",
      "bloodGroup": "AB+",
      "units": 1,
      "distanceKm": 1.1,
      "city": "Rawalpindi",
      "urgency": "Low",
      "hospital": "Armed Forces Institute of Cardiology",
      "note": "Scheduled procedure",
      "timeAgo": "8 hours ago",
    },
    {
      "name": "Al-Shifa",
      "bloodGroup": "A-",
      "units": 2,
      "distanceKm": 0.9,
      "city": "Islamabad",
      "urgency": "High",
      "hospital": "Al-Shifa Trust Eye Hospital",
      "note": "Critical patient",
      "timeAgo": "30 minutes ago",
    },
  ];
}

