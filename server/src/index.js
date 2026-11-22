import express from 'express';
import cors from 'cors';
import 'dotenv/config';
import { poolReady } from './db.js';
import auth from './routes/auth.routes.js';
import tableta from './routes/tableta.routes.js';
import panel from './routes/panel.routes.js';

const app = express();
app.use(cors({ origin: process.env.CLIENT_ORIGIN || true }));
app.use(express.json());
app.use('/uploads', express.static('uploads'));

app.get('/api/health', (req, res) => res.json({ ok: true }));
app.use('/api/auth', auth);
app.use('/api/tableta', tableta);
app.use('/api/panel', panel);

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Error del servidor' });
});

await poolReady;
app.listen(process.env.PORT, '0.0.0.0', () =>
  console.log('API escuchando en el puerto', process.env.PORT));
