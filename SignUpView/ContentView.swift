//
//  ContentView.swift
//  SignUpView
//
//  Created by Mark Jeschke on 7/27/23.
//

import SwiftUI

struct ContentView: View {

    private enum FocusedField: String {
        case email = "Email Address"
        case password = "Password"
        case name = "Name"
    }

    @State private var emailInput: String = ""
    @State private var isEmailEmpty = false
    @State private var passwordInput: String = ""
    @State private var isPasswordEmpty = false
    @State private var nameInput: String = ""
    @State private var isNameEmpty = false
    @State private var isCreateAccountButtonEnabled = false
    @State private var isPasswordHidden = true
    @FocusState private var focusedField: FocusedField?
    @State private var isPresentConfirmationSheet = false
    @State private var selectedDetent: PresentationDetent = .medium

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                GeometryReader { proxy in
                    Form {
                        Section {
                            emailInputField
                            passwordInputField
                            nameInputField
                        } header: {
                            headerProfileIcon(proxy: proxy)
                        } footer: {
                            createAccountButton
                        }
                    }
                    .padding(.bottom)
                }
            }
            .onSubmit {
                switch focusedField {
                case .email:
                    focusedField = .password
                case .password:
                    focusedField = .name
                case .name:
                    createAccount()
                default:
                    focusedField = nil
                }
            }
            .onAppear {
//                focusedField = .email //<- Uncomment, if you want the Email TextField to become the first responder.
            }
            .navigationTitle("Sign Up")
        }
        .safeAreaInset(edge: .bottom) {
            // Hide the Sign In text copy and button when a focusedField has been selected and showing the UIKeyboard.
            if focusedField == nil {
                signInButton
            }
        }
    }

    // MARK: - Header Profile Icon
    // MARK: -

    private func headerProfileIcon(proxy: GeometryProxy) -> some View {
        return Image(systemName: "person.crop.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: proxy.size.width * 0.35)
            .foregroundStyle(.blue.gradient)
            .shadow(color: .black.opacity(0.2), radius: 3, y: 3)
            .padding(.bottom)
            .frame(maxWidth: .infinity, alignment: .center)
            // The following allows you to tap anywhere in the header to dismiss the UIKeyboard.
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
    }

    // MARK: - Email Input Field
    // MARK: -

    private var emailInputField: some View {
        TextField(emailInput,
                  text: $emailInput,
                  prompt: Text(FocusedField.email.rawValue).foregroundColor(isEmailEmpty ? .red : .secondary))
        // Uncomment this onChange if you're using Xcode 15+
//            .onChange(of: emailInput) { _, _ in
//                checkRequiredFields()
//            }
        // Remove this onChange modifier, if you're using Xcode 15+
            .onChange(of: emailInput, perform: { _ in
                checkRequiredFields()
            })
            .focused($focusedField,
                     equals: .email)
            .onAppear {
                UITextField.appearance().clearButtonMode = .whileEditing
            }
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            .submitLabel(.next)
    }

    // MARK: - Password Input Field
    // MARK: -

    private var passwordInputField: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isPasswordHidden {
                    SecureField(passwordInput,
                                text: $passwordInput,
                                prompt: Text(FocusedField.password.rawValue).foregroundColor(isPasswordEmpty ? .red : .secondary))
                } else {
                    TextField(passwordInput,
                              text: $passwordInput,
                              prompt: Text(FocusedField.password.rawValue).foregroundColor(isPasswordEmpty ? .red : .secondary))
                }
            }
            .padding(.trailing, 32)
            Button(action: {
                isPasswordHidden.toggle()
            }) {
                Image(systemName: isPasswordHidden ? "eye.slash" : "eye")
                    .accentColor(.accentColor)
            }
        }
        // Uncomment this onChange if you're using Xcode 15+
//            .onChange(of: passwordInput) { _, _ in
//                checkRequiredFields()
//            }
        // Remove this onChange modifier, if you're using Xcode 15+
            .onChange(of: passwordInput, perform: { _ in
                checkRequiredFields()
            })
        .focused($focusedField,
                 equals: .password)
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
        }
        .disableAutocorrection(true)
        .submitLabel(.next)
    }

    // MARK: - Name Input Field
    // MARK: -

    private var nameInputField: some View {
        TextField(nameInput,
                  text: $nameInput,
                  prompt: Text(FocusedField.name.rawValue).foregroundColor(isNameEmpty ? .red : .secondary))
        // Uncomment this onChange if you're using Xcode 15+
//            .onChange(of: nameInput) { _, _ in
//                checkRequiredFields()
//            }
        // Remove this onChange modifier, if you're using Xcode 15+
            .onChange(of: nameInput, perform: { _ in
                checkRequiredFields()
            })
            .focused($focusedField,
                     equals: .name)
            .onAppear {
                UITextField.appearance().clearButtonMode = .whileEditing
            }
            .keyboardType(.alphabet)
            .disableAutocorrection(true)
            .autocapitalization(.words)
            .submitLabel(.done)
    }

    // MARK: - Create Account Button
    // MARK: -

    private var createAccountButton: some View {
        Button(action: {
            if isCreateAccountButtonEnabled {
                createAccount()
            } else {
                focusedField = nil
                checkRequiredFields()
                showEmptyFieldErrors()
            }
        }, label: {
            Text("Create Account")
                .frame(maxWidth: .infinity)
                .fontWeight(.bold)
                .padding()
                .foregroundStyle(.white)
        })
        .background(isCreateAccountButtonEnabled ? Color.blue.gradient : Color.gray.gradient)
        .opacity(isCreateAccountButtonEnabled ? 1.0 : 0.5)
        .cornerRadius(12)
        .padding(.vertical)
        .shadow(color: .black.opacity(isCreateAccountButtonEnabled ? 0.3 : 0.0), radius: isCreateAccountButtonEnabled ? 6 : 0, y: 2)
        .sheet(isPresented: $isPresentConfirmationSheet,
               onDismiss: {
            clearToResetVariables()
                },
               content: {
            NewAccountView(email: emailInput,
                           password: passwordInput,
                           name: nameInput)
                .presentationDetents([.medium, .large],
                                     selection: $selectedDetent)
        })
    }

    // MARK: - Sign In Button and Bottom Text Copy
    // MARK: -

    private var signInButton: some View {
        HStack(spacing: 10) {
            Text("Already have an account?")
            Button(action: {
                print("Create Account")
            }, label: {
                Text("Sign In")
                    .fontWeight(.bold)
            })
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 5)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Actions
    // MARK: -

    private func clearToResetVariables() {
        withAnimation {
            isCreateAccountButtonEnabled = false
            emailInput = ""
            passwordInput = ""
            nameInput = ""
            isEmailEmpty = false
            isPasswordEmpty = false
            isNameEmpty = false
        }
    }

    private func checkRequiredFields() {
        if !emailInput.isEmpty && !passwordInput.isEmpty && !nameInput.isEmpty {
            withAnimation {
                isCreateAccountButtonEnabled = true
            }
        } else {
            withAnimation {
                isCreateAccountButtonEnabled = false
            }
        }
    }

    private func showEmptyFieldErrors() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        isEmailEmpty = emailInput.isEmpty
        isPasswordEmpty = passwordInput.isEmpty
        isNameEmpty = nameInput.isEmpty
    }

    private func createAccount() {
        if !emailInput.isEmpty && !passwordInput.isEmpty && !nameInput.isEmpty {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            focusedField = nil // <- Dismiss the UIKeyboard
            print("Account was successfully created!")
            isPresentConfirmationSheet.toggle()
        } else {
            showEmptyFieldErrors()
        }
    }
}

// MARK: - New Account View
// MARK: -

struct NewAccountView: View {

    @Environment(\.dismiss) private var dismiss
    var email: String = ""
    var password: String = ""
    var name: String = ""

    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email Address:")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(email)
                        .font(.title2)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text("Password:")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(password)
                        .font(.title2)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text("Name:")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(name)
                        .font(.title2)
                }
            }
            .listStyle(.plain)
            .frame(maxWidth: .infinity)
            .padding()
            .navigationTitle("Account Created")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Done")
                            .fontWeight(.bold)
                    })
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDisplayName("Sign Up")
        NewAccountView(email: "me@github.com",
                       password: "12345",
                       name: "Me Namey")
            .previewDisplayName("New Account")
    }
}

// Xcode 15+
//#Preview("Sign Up") {
//    ContentView()
//}

// Xcode 15+
//#Preview("New Account") {
//    NewAccountView(email: "me@github.com",
//                   password: "12345",
//                   name: "Me Namey")
//
//}
