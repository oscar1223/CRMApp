import SwiftUI

// MARK: - Chat Main View (structure inspired by screenshot)
struct ChatMainView: View {
    @State private var messages: [ChatMessage] = []
    @State private var draft: String = ""
    @FocusState private var isInputFocused: Bool
    
    private var isIPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0)
            content
            suggestionRow
            inputBar
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
    }
    
    // MARK: Header (top bar with title and actions)
    private var header: some View {
        HStack {
            Button(action: {}) { Image(systemName: "line.3.horizontal") }
                .foregroundColor(.textSecondary)
                .font(.system(size: 18, weight: .semibold))
            
            Spacer()
            
            Button(action: {}) {
                Text("Obtener Plus ✦")
                    .font(.system(size: isIPad ? 14 : 12, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.backgroundTertiary))
            }
            .foregroundColor(.brandPrimary)
            
            Button(action: {}) { Image(systemName: "square.and.pencil") }
                .foregroundColor(.textSecondary)
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.backgroundSecondary.opacity(0.0))
    }
    
    // MARK: Content area
    private var content: some View {
        ZStack {
            if messages.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(.brandPrimary)
                    Text("Empieza una conversación")
                        .modernText(size: .subhead, color: .textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12, pinnedViews: []) {
                            ForEach(messages) { msg in
                                messageBubble(msg)
                                    .id(msg.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: messages.count) { _ in
                        if let last = messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
        }
    }
    
    // MARK: Suggestion chips row (above input)
    private var suggestionRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(suggestions, id: \.self) { text in
                    Button(action: { insertSuggestion(text) }) {
                        Text(text)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.backgroundCard))
                            .overlay(Capsule().stroke(Color.borderSecondary, lineWidth: 0.5))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color.backgroundPrimary)
    }
    
    // MARK: Input Bar
    private var inputBar: some View {
        HStack(spacing: 10) {
            Button(action: {}) { Image(systemName: "plus") }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textSecondary)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.backgroundCard)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borderSecondary, lineWidth: 0.5))
                TextField("Mensaje", text: $draft)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .focused($isInputFocused)
                    .foregroundColor(.textPrimary)
                    .submitLabel(.send)
                    .onSubmit { sendDraft() }
                    .lineLimit(1)
            }
            .frame(height: isIPad ? 46 : 40)
            
            Button(action: { sendDraft() }) { Image(systemName: "arrow.up.circle.fill") }
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .textTertiary : .brandPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(BlurBackground())
    }
    
    // MARK: Helpers
    private func messageBubble(_ msg: ChatMessage) -> some View {
        HStack(alignment: .bottom) {
            if msg.isUser { Spacer(minLength: 40) }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(msg.text)
                    .modernText(size: .body, color: msg.isUser ? .textInverse : .textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(msg.isUser ? Color.brandPrimary : Color.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(msg.isUser ? Color.clear : Color.borderSecondary, lineWidth: 0.5)
                    )
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
            
            if !msg.isUser { Spacer(minLength: 40) }
        }
    }
    
    private var suggestions: [String] {
        [
            "Crear imagen para mi portfolio",
            "Empezar con el CRM",
            "Cómo mejorar mis reservas"
        ]
    }
    
    private func insertSuggestion(_ text: String) {
        draft = text
        isInputFocused = true
    }
    
    private func sendDraft() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(ChatMessage(text: trimmed, isUser: true, timestamp: Date()))
        draft = ""
        // Placeholder assistant response for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            messages.append(ChatMessage(text: "Entendido. Estoy aquí para ayudarte.", isUser: false, timestamp: Date()))
        }
    }
}

// MARK: - Blur background helper to mimic system bar
private struct BlurBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        return view
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}


