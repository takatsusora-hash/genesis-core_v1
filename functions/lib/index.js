"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.health = void 0;
const https_1 = require("firebase-functions/v2/https");
exports.health = (0, https_1.onRequest)((req, res) => {
    res.json({
        service: 'genesiscore-functions',
        status: 'ok',
        timestamp: new Date().toISOString(),
        note: 'PR1 architecture scaffold only.',
    });
});
