import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema(
  {
    type: {
      type: String,
      enum: [
        'taskAssigned',
        'deadlineReminder',
        'documentShared',
        'messageReceived',
        'projectUpdate',
        'mention',
      ],
      default: 'projectUpdate',
    },
    title: { type: String, required: true },
    body: { type: String, required: true },
    projectId: { type: String, default: null },
    isRead: { type: Boolean, default: false },
    createdAt: { type: Date, default: Date.now },
  },
  { timestamps: false },
);

export default mongoose.model('Notification', notificationSchema);
