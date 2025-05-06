import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String jobId;
  final String applicationId;

  ChatPage({required this.jobId, required this.applicationId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  late CollectionReference messagesCollection;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    messagesCollection = FirebaseFirestore.instance
        .collection('jobsposted')
        .doc(widget.jobId)
        .collection('applications')
        .doc(widget.applicationId)
        .collection('messages');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF1F1F1F),
        title: Text('Чат', style: TextStyle(color: Colors.white)),
        leading: Icon(Icons.chat, color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesCollection.orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }

                List<QueryDocumentSnapshot> messages = snapshot.data!.docs;

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
                    Map<String, dynamic> messageData =
                        messages[index].data() as Map<String, dynamic>;
                    String messageText = messageData['message'];
                    String sender = messageData['sender'];
                    Timestamp? timestamp = messageData['timestamp'];

                    String formattedTime = 'Нет времени';

                    if (timestamp != null) {
                      DateTime dateTime = timestamp.toDate();
                      formattedTime = DateFormat(
                        'HH:mm dd-MM',
                      ).format(dateTime);
                    }

                    bool isUserSender = sender == 'Applicant';

                    return Align(
                      alignment:
                          isUserSender
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        constraints: BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color:
                              isUserSender
                                  ? Color(0xFF2962FF)
                                  : Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isUserSender
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            Text(
                              messageText,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Введите сообщение...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Color(0xFF2C2C2C),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      sendMessage(messageController.text.trim());
                      messageController.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(String messageText) {
    if (messageText.isEmpty) return;

    messagesCollection.add({
      'message': messageText,
      'sender': 'Applicant',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
