//
//  ContentView.swift
//  nypattendance
//
//  Created by Tan Thor Jen on 21/10/24.
//

import SwiftUI
import SwiftData

struct InputStudentsView: View {
    @Bindable var editClass: Class
    @State var text = ""
    
    var body: some View {
        VStack {
            TextEditor(text: $text)
                .frame(minHeight: 300.0)
            Button(action: submit) {
                Text("Submit")
            }
        }
        .padding()
    }
    
    func submit() {
        let lines = text.components(separatedBy: "\n")
        editClass.students = lines.compactMap { line in
            let columns = line.components(separatedBy: "\t")
            guard columns.count == 3 else { return nil }
            guard let order = Int(columns[0]) else { return nil }
            return Student(order: order, name: columns[2], admissionNumber: columns[1])
        }
    }
}

struct ClassView: View {
    @Bindable var editClass: Class
    @Environment(\.modelContext) private var modelContext
    
    @State var isInputStudents = false
    
    var body: some View {
        VStack {
            TextField("Name", text: $editClass.name)
            Table(editClass.students) {
                TableColumn("Name", value: \.name)
                TableColumn("#", value: \.orderStr)
                TableColumn("AdmNo", value: \.admissionNumber)
            }
            HStack {
                Button(action: { isInputStudents = true }) {
                    Text("Edit Students")
                }
                Button(action: {
                    modelContext.insert(Attendance(parent: editClass))
                }) {
                    Text("Add attednance")
                }
            }
        }
        .padding()
        .sheet(isPresented: $isInputStudents) {
            InputStudentsView(editClass: editClass)
        }
    }
}

extension String {
    func widthOfString(usingFont font: Font) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

struct AttendanceView: View {
    @Bindable var att: Attendance
//    @Environment(\.modelContext) private var modelContext
    
//    @State var isInputStudents = false
    
    @State var sel: String?
    @State private var sortOrder = [KeyPathComparator(\Attendee.order)]
    
    @State var colWidth: CGFloat?
        
    var body: some View {
        VStack {
            DatePicker("Date", selection: $att.timestamp)
            Table(att.attendees, selection: $sel, sortOrder: $sortOrder) {
                TableColumn("A") { a in
                    Toggle("", isOn: Binding(get: { a.isAttend }, set: { v in
                        if let idx = att.attendees.firstIndex(where: { $0.id == a.id }) {
                            att.attendees[idx].isAttend = v
                        }
                    }))
                }
                .width(60.0)
                
                TableColumn("#", value: \.orderStr)
                    .width(30.0)
                
                TableColumn("Name", value: \.name) { a in
                    Text(a.name)
                        .foregroundStyle(a.isAttend ? Color.primary : Color.red)
                }
                TableColumn("Remarks", value: \.remarks) { a in
                    TextField("Remarks", text: Binding(get: { a.remarks }, set: { v in
                        if let idx = att.attendees.firstIndex(where: { $0.id == a.id }) {
                            att.attendees[idx].remarks = v
                        }
                    }))
                }
            }
        }
        .padding()
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var classes: [Class]
    
    @State var selectedClassId: UUID?
    @State var selectedAttId: UUID?

    var body: some View {
        NavigationSplitView {
            VStack {
                Section("Classes") {
                    List(selection: $selectedClassId) {
                        ForEach(classes) { cl in
                            Text("\(cl.name)")
                        }
                        //                    .onDelete(perform: deleteItems)
                    }
                }
                if let cl = selectedClass {
                    Section("Attendance") {
                        List(cl.attendance, selection: $selectedAttId) { att in
                            Text("\(att.timestamp)")
                        }
                    }
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addClass) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let att = selectedAttendance {
                AttendanceView(att: att)
            }
            else if let cl = selectedClass {
                ClassView(editClass: cl)
            } else {
                Text("Select an item")
            }
        }
    }
    
    var selectedClass: Class? {
        classes.first(where: { $0.id == selectedClassId })
    }
    
    var selectedAttendance: Attendance? {
        guard let cl = selectedClass else { return nil }
        return cl.attendance.first(where: { $0.id == selectedAttId })
    }


    private func addClass() {
        withAnimation {
            let newItem = Class(name: "New class")
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(classes[index])
            }
        }
    }
}
