import fs from 'fs';
import https from 'https';
import path from 'path';
import dotenv from 'dotenv';
import express from 'express';
import cors from 'cors';
import mongoose from 'mongoose';

import projectRoutes from './src/routes/projects.js';
import taskRoutes from './src/routes/tasks.js';
import documentRoutes from './src/routes/documents.js';
import reportRoutes from './src/routes/reports.js';
import notificationRoutes from './src/routes/notifications.js';
import messageRoutes from './src/routes/messages.js';
import objectiveRoutes from './src/routes/objectives.js';
import userRoutes from './src/routes/users.js';

dotenv.config();

const PORT = process.env.PORT || 3001;
const MONGODB_URI = process.env.MONGODB_URI;

if (!MONGODB_URI) {
  console.error('MONGODB_URI no definida en .env');
  process.exit(1);
}

const app = express();

app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use('/api/projects', projectRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/documents', documentRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/objectives', objectiveRoutes);
app.use('/api/users', userRoutes);

app.use((err, _req, res, _next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Error interno del servidor' });
});

const certDir = path.resolve(process.cwd(), 'certs');
const keyPath = path.join(certDir, 'key.pem');
const certPath = path.join(certDir, 'cert.pem');

async function start() {
  try {
    await mongoose.connect(MONGODB_URI, {
      dbName: process.env.MONGODB_DB || 'research_hub',
    });
    console.log('Conectado a MongoDB Atlas');

    if (!fs.existsSync(keyPath) || !fs.existsSync(certPath)) {
      console.error('Certificados HTTPS no encontrados en', certDir);
      console.error('Ejecuta: openssl req -x509 -newkey rsa:2048 -nodes -keyout certs/key.pem -out certs/cert.pem -days 365 -subj "/CN=localhost"');
      process.exit(1);
    }

    const credentials = {
      key: fs.readFileSync(keyPath),
      cert: fs.readFileSync(certPath),
    };

    https.createServer(credentials, app).listen(PORT, () => {
      console.log(`Servidor HTTPS corriendo en https://localhost:${PORT}`);
    });
  } catch (err) {
    console.error('Error iniciando servidor:', err);
    process.exit(1);
  }
}

start();
