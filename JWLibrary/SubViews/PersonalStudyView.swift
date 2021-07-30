//
//  PersonalStudyView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import SwiftUI
import AppKit

struct PersonalStudyView: View {
    @State var notes: [Note] = NoteManager.getNotes()
    @State var showNote: Bool = false
    @State var noteTitle: String = ""
    @State var noteContent: String = ""

    var body: some View {
        GeometryReader { geometryReader in
            ZStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(notes, id: \.ID) { note in
                            Group {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(note.title)
                                        .lineLimit(nil)
                                        .font(.title2)
                                    Text(note.content)
                                        .lineLimit(nil)
                                        .font(.body)
                                    Spacer()
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                            .onTapGesture {
                                showNote = true
                                noteTitle = note.title
                                noteContent = note.content
                            }
                            .padding(10)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(10)
                        }
                    }
                    .padding(20)
                }
                ZStack {
                    Rectangle()
                        .fill(Color.black)
                        .opacity(0.5)
                    Group {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(noteTitle)
                                .lineLimit(nil)
                                .font(.title2)
                            ScrollView {
                                Text(noteContent)
                                    .lineLimit(nil)
                                    .font(.body)
                                    .padding(15)
                            }
                        }
                        .padding(30)
                        .frame(width: geometryReader.size.width - 60)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(15)
                    }
                    .padding(30)
                }
                .opacity(showNote ? 1 : 0)
                .onTapGesture(perform: {
                    showNote = false
                    noteTitle = ""
                    noteContent = ""
                })
            }
        }
    }
}

struct PersonalStudyView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalStudyView()
    }
}
