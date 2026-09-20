import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    institution: { type: String, default: null },
    avatarUrl: { type: String, default: null },
    role: {
      type: String,
      enum: ['principalInvestigator', 'coInvestigator', 'researcher', 'assistant', 'external'],
      default: 'researcher',
    },
    projectIds: { type: [String], default: [] },
    createdAt: { type: Date, default: Date.now },
  },
  { timestamps: false },
);

export default mongoose.model('User', userSchema);
