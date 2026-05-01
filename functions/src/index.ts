import {onRequest} from 'firebase-functions/v2/https';

export const health = onRequest((req, res) => {
  res.json({
    service: 'genesiscore-functions',
    status: 'ok',
    timestamp: new Date().toISOString(),
    note: 'PR1 architecture scaffold only.',
  });
});
