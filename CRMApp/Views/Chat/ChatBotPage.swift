import SwiftUI

// MARK: - Simple Chat Interface
struct ChatBotPage: View {
    @State private var selectedChat: ChatConversation?
    @State private var conversations: [ChatConversation] = []
    @State private var showingSidebar = true
    @State private var inputText: String = ""
    @State private var currentMessages: [ChatMessage] = []
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Sidebar
                if showingSidebar {
                    ChatSidebar(
                        conversations: $conversations,
                        selectedChat: $selectedChat,
                        onSelectChat: selectChat,
                        onNewChat: createNewChat
                    )
                    .frame(width: min(300, geometry.size.width * 0.3))
                    .transition(.move(edge: .leading))
                }
                
                // Main chat area
                if selectedChat != nil {
                    ChatMainArea(
                        messages: $currentMessages,
                        inputText: $inputText,
                        onSendMessage: sendMessage,
                        onToggleSidebar: { withAnimation(.spring()) { showingSidebar.toggle() } }
                    )
                } else {
                    ChatWelcome(onNewChat: createNewChat)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            setupInitialData()
        }
    }
    
    private func setupInitialData() {
        let welcomeConversation = ChatConversation(
            id: UUID(),
            title: "Bienvenida",
            messages: [
                ChatMessage(role: .bot, text: "¡Hola! Soy tu asistente de CRM. ¿En qué puedo ayudarte hoy?", timestamp: Date())
            ],
            folder: .general,
            lastUpdated: Date()
        )
        
        let sampleConversations = [
            ChatConversation(
                id: UUID(),
                title: "Configurar calendario",
                messages: [
                    ChatMessage(role: .user, text: "¿Cómo configuro mi calendario?", timestamp: Date().addingTimeInterval(-3600)),
                    ChatMessage(role: .bot, text: "Te ayudo a configurar tu calendario. Puedes acceder a la configuración desde la pestaña de ajustes.", timestamp: Date().addingTimeInterval(-3500))
                ],
                folder: .work,
                lastUpdated: Date().addingTimeInterval(-3600)
            ),
            ChatConversation(
                id: UUID(),
                title: "Gestión de clientes",
                messages: [
                    ChatMessage(role: .user, text: "¿Cómo agrego un nuevo cliente?", timestamp: Date().addingTimeInterval(-7200)),
                    ChatMessage(role: .bot, text: "Para agregar un nuevo cliente, ve a la sección de Reservas y selecciona 'Añadir Cliente'.", timestamp: Date().addingTimeInterval(-7100))
                ],
                folder: .work,
                lastUpdated: Date().addingTimeInterval(-7200)
            )
        ]
        
        conversations = [welcomeConversation] + sampleConversations
        selectedChat = welcomeConversation
        currentMessages = welcomeConversation.messages
    }
    
    private func createNewChat() {
        let newChat = ChatConversation(
            id: UUID(),
            title: "Nueva conversación",
            messages: [
                ChatMessage(role: .bot, text: "¡Hola! ¿En qué puedo ayudarte?", timestamp: Date())
            ],
            folder: .general,
            lastUpdated: Date()
        )
        
        conversations.insert(newChat, at: 0)
        selectedChat = newChat
        currentMessages = newChat.messages
    }
    
    private func selectChat(_ conversation: ChatConversation) {
        selectedChat = conversation
        currentMessages = conversation.messages
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let chat = selectedChat else { return }
        
        let userMessage = ChatMessage(role: .user, text: text, timestamp: Date())
        currentMessages.append(userMessage)
        inputText = ""
        
        // Update conversation
        if let index = conversations.firstIndex(where: { $0.id == chat.id }) {
            conversations[index].messages = currentMessages
            conversations[index].lastUpdated = Date()
        }
        
        // Simulate bot response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let botReply = generateBotReply(to: text)
            let botMessage = ChatMessage(role: .bot, text: botReply, timestamp: Date())
            currentMessages.append(botMessage)
            
            // Update conversation
            if let index = conversations.firstIndex(where: { $0.id == chat.id }) {
                conversations[index].messages = currentMessages
                conversations[index].lastUpdated = Date()
            }
        }
    }
    
    private func generateBotReply(to text: String) -> String {
        let lower = text.lowercased()
        
        if lower.contains("hola") || lower.contains("hello") {
            return "¡Hola! 👋 ¿En qué puedo ayudarte con tu CRM hoy?"
        }
        
        if lower.contains("calend") {
            return "Para gestionar tu calendario, puedes:\n• Ver eventos por mes o semana\n• Crear nuevos eventos\n• Configurar tu disponibilidad\n\n¿Te gustaría que te ayude con algo específico?"
        }
        
        if lower.contains("client") {
            return "Para gestionar clientes puedes:\n• Añadir nuevos clientes\n• Ver historial de citas\n• Agregar notas personales\n• Configurar recordatorios\n\n¿Qué necesitas hacer con tus clientes?"
        }
        
        if lower.contains("reserva") || lower.contains("cita") {
            return "Con las reservas puedes:\n• Crear enlaces de reserva personalizados\n• Configurar tu disponibilidad\n• Gestionar días no laborables\n• Enviar recordatorios automáticos\n\n¿Necesitas ayuda con alguna configuración específica?"
        }
        
        if lower.contains("ayuda") || lower.contains("help") {
            return "Puedo ayudarte con:\n• 📅 Gestión de calendario\n• 👥 Administración de clientes\n• 🔗 Configuración de reservas\n• ⚙️ Ajustes generales\n\n¿Con qué te gustaría que empecemos?"
        }
        
        return "Entiendo que preguntas sobre: \"\(text)\"\n\nPuedo ayudarte con tu CRM en:\n• Calendario y eventos\n• Gestión de clientes\n• Configuración de reservas\n• Ajustes generales\n\n¿Podrías ser más específico sobre lo que necesitas?"
    }
}

// MARK: - Chat Sidebar
struct ChatSidebar: View {
    @Binding var conversations: [ChatConversation]
    @Binding var selectedChat: ChatConversation?
    let onSelectChat: (ChatConversation) -> Void
    let onNewChat: () -> Void
    
    @State private var searchText = ""
    
    var filteredConversations: [ChatConversation] {
        if searchText.isEmpty {
            return conversations
        } else {
            return conversations.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CRM Assistant")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text("Asistente inteligente para tu CRM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: onNewChat) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color(.systemGray6)))
                    }
                }
                
                // Search bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextField("Buscar conversaciones...", text: $searchText)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
            .padding(.all, 16)
            
            Divider()
                .background(Color(.separator))
            
            // Folders
            VStack(alignment: .leading, spacing: 8) {
                Text("Carpetas")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
                ForEach(ChatConversation.ChatFolder.allCases, id: \.self) { folder in
                    let count = conversations.filter { $0.folder == folder }.count
                    if count > 0 {
                        HStack(spacing: 12) {
                            Image(systemName: folder.icon)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(folderColor(folder))
                                .frame(width: 20)
                            
                            Text(folder.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            
            Divider()
                .background(Color(.separator))
                .padding(.vertical, 8)
            
            // Conversations list
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(filteredConversations) { conversation in
                        ChatRow(
                            conversation: conversation,
                            isSelected: selectedChat?.id == conversation.id,
                            onSelect: { onSelectChat(conversation) }
                        )
                    }
                }
                .padding(.horizontal, 8)
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(
            Rectangle()
                .fill(Color(.separator))
                .frame(width: 0.5),
            alignment: .trailing
        )
    }
    
    private func folderColor(_ folder: ChatConversation.ChatFolder) -> Color {
        switch folder.color {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "gray": return .gray
        default: return .secondary
        }
    }
}

// MARK: - Chat Row
struct ChatRow: View {
    let conversation: ChatConversation
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(conversation.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .blue : .primary)
                        .lineLimit(1)
                    
                    Text(conversation.preview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(timeAgo(conversation.lastUpdated))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    if conversation.messages.count > 1 {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.all, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func timeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "Ahora"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h"
        } else {
            return "\(Int(interval / 86400))d"
        }
    }
}

// MARK: - Chat Main Area
struct ChatMainArea: View {
    @Binding var messages: [ChatMessage]
    @Binding var inputText: String
    let onSendMessage: () -> Void
    let onToggleSidebar: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onToggleSidebar) {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("CRM Assistant")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text("En línea")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.all, 16)
            .background(Color(.secondarySystemGroupedBackground))
            .overlay(
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 0.5),
                alignment: .bottom
            )
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.all, 24)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input area
            VStack(spacing: 12) {
                // Quick suggestions
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quickSuggestions, id: \.self) { suggestion in
                            Button(action: { inputText = suggestion }) {
                                Text(suggestion)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color(.systemGray6))
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color(.separator), lineWidth: 0.5)
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                // Message input
                HStack(spacing: 12) {
                    TextField("Escribe tu mensaje...", text: $inputText, axis: .vertical)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.separator), lineWidth: 0.5)
                                )
                        )
                    
                    Button(action: onSendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(inputText.isEmpty ? Color.secondary : Color.blue)
                            )
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 16)
            .background(Color(.secondarySystemGroupedBackground))
            .overlay(
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 0.5),
                alignment: .top
            )
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var quickSuggestions: [String] {
        [
            "¿Cómo configuro mi calendario?",
            "Agregar nuevo cliente",
            "Ver mis próximas citas",
            "Configurar recordatorios"
        ]
    }
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 64)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 8) {
                HStack(spacing: 8) {
                    if message.role == .bot {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Text("🤖")
                                .font(.system(size: 16))
                        }
                    }
                    
                    Text(message.text)
                        .font(.body)
                        .foregroundColor(message.role == .user ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(message.role == .user ? Color.blue : Color(.secondarySystemGroupedBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(message.role == .user ? Color.clear : Color(.separator), lineWidth: 0.5)
                                )
                        )
                    
                    if message.role == .user {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 32, height: 32)
                            
                            Text("👤")
                                .font(.system(size: 16))
                        }
                    }
                }
                
                Text(timeString(message.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, message.role == .user ? 24 : 32)
            }
            
            if message.role == .bot {
                Spacer(minLength: 64)
            }
        }
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Chat Welcome
struct ChatWelcome: View {
    let onNewChat: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Text("🤖")
                        .font(.system(size: 64))
                }
                
                VStack(spacing: 12) {
                    Text("CRM Assistant")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Tu asistente personal para gestionar\ntu CRM de manera eficiente")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            VStack(spacing: 16) {
                Button(action: onNewChat) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                        Text("Iniciar conversación")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.25), radius: 8, x: 0, y: 4)
                }
                
                VStack(spacing: 8) {
                    Text("Puedo ayudarte con:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("📅")
                            Text("Gestión de calendario y eventos")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        HStack(spacing: 8) {
                            Text("👥")
                            Text("Administración de clientes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        HStack(spacing: 8) {
                            Text("🔗")
                            Text("Configuración de reservas")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        HStack(spacing: 8) {
                            Text("⚙️")
                            Text("Ajustes generales")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
                .padding(.all, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.separator), lineWidth: 0.5)
                        )
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}