import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatRecruiter extends StatefulWidget {
  final String jobId;
  final String applicationId;

  ChatRecruiter({required this.jobId, required this.applicationId});

  @override
  _ChatRecruiterState createState() => _ChatRecruiterState();
}

class _ChatRecruiterState extends State<ChatRecruiter> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late CollectionReference _messagesCollection;

  @override
  void initState() {
    super.initState();
    _messagesCollection = FirebaseFirestore.instance
        .collection('jobsposted')
        .doc(widget.jobId)
        .collection('applications')
        .doc(widget.applicationId)
        .collection('messages');
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    _messagesCollection.add({
      'message': text.trim(),
      'sender': 'Recruiter',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text('Chat Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F1F1F),
        leading: Icon(Icons.chat, color: Colors.cyanAccent),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesCollection.orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.cyanAccent),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                final messages = snapshot.data?.docs ?? [];

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final text = data['message'] ?? '';
                    final sender = data['sender'] ?? 'Unknown';
                    final timestamp = data['timestamp'] as Timestamp?;
                    final isRecruiter = sender == 'Recruiter';

                    final formattedTime =
                        timestamp != null
                            ? DateFormat(
                              'HH:mm:ss dd-MM-yy',
                            ).format(timestamp.toDate())
                            : 'Sending...';

                    return ListTile(
                      contentPadding:
                          isRecruiter
                              ? EdgeInsets.only(left: 80, right: 12)
                              : EdgeInsets.only(left: 12, right: 80),
                      title: Align(
                        alignment:
                            isRecruiter
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isRecruiter
                                    ? Colors.cyanAccent.shade700
                                    : Colors.deepPurpleAccent.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            text,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      subtitle: Align(
                        alignment:
                            isRecruiter
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${isRecruiter ? "You" : sender} • $formattedTime',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1, color: Colors.grey[800]),
          Container(
            color: Color(0xFF1E1E1E),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.cyanAccent,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Color(0xFF2C2C2C),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.cyanAccent.shade700,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.black87),
                    onPressed: () => _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
