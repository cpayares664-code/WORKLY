import { Router } from 'express';
import Notification from '../models/Notification.js';

const router = Router();

router.get('/', async (req, res) => {
  try {
    const { unread } = req.query;
    let query = Notification.find();
    if (unread === 'true') query = query.find({ isRead: false });
    const notifications = await query.sort({ createdAt: -1 });
    res.json(notifications);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.patch('/:id/read', async (req, res) => {
  try {
    const n = await Notification.findByIdAndUpdate(
      req.params.id,
      { isRead: true },
      { new: true },
    );
    if (!n) return res.status(404).json({ error: 'Notificación no encontrada' });
    res.json(n);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.patch('/read-all', async (req, res) => {
  try {
    await Notification.updateMany({ isRead: false }, { isRead: true });
    res.json({ message: 'Todas marcadas como leídas' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
