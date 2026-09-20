import mongoose from 'mongoose';

const messageSchema = new mongoose.Schema(
  {
    projectId: { type: String, required: true },
    senderId: { type: String, required: true },
    senderName: { type: String, required: true },
    content: { type: String, required: true },
    isEdited: { type: Boolean, default: false },
    sentAt: { type: Date, default: Date.now },
  },
  { timestamps: false },
);

export default mongoose.model('Message', messageSchema);
