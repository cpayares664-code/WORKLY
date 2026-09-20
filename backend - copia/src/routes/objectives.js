import { Router } from 'express';
import Objective from '../models/Objective.js';

const router = Router();

router.get('/:projectId', async (req, res) => {
  try {
    const objectives = await Objective.find({ projectId: req.params.projectId });
    res.json(objectives);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const obj = new Objective(req.body);
    await obj.save();
    res.status(201).json(obj);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const obj = await Objective.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    });
    if (!obj) return res.status(404).json({ error: 'Objetivo no encontrado' });
    res.json(obj);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await Objective.findByIdAndDelete(req.params.id);
    res.json({ message: 'Objetivo eliminado' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
