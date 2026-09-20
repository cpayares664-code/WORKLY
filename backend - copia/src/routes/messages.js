import { Router } from 'express';
import Message from '../models/Message.js';

const router = Router();

router.get('/:projectId', async (req, res) => {
  try {
    const messages = await Message.find({ projectId: req.params.projectId }).sort({
      sentAt: 1,
    });
    res.json(messages);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const message = new Message(req.body);
    await message.save();
    res.status(201).json(message);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router;
