const express = require('express');
const router = express.Router();

// Import routes
const authRoutes = require('./authRoutes');
const tontineRoutes = require('./tontineRoutes');
const membershipRoutes = require('./membershipRoutes');
const cycleRoutes = require('./cycleRoutes');
const cotisationRoutes = require('./cotisationRoutes');
const distributionRoutes = require('./distributionRoutes');
const walletRoutes = require('./walletRoutes');
const notificationRoutes = require('./notificationRoutes');
const adminRoutes = require('./adminRoutes');

// Use routes
router.use('/auth', authRoutes);
router.use('/tontines', tontineRoutes);
router.use('/memberships', membershipRoutes);
router.use('/cycles', cycleRoutes);
router.use('/cotisations', cotisationRoutes);
router.use('/distributions', distributionRoutes);
router.use('/wallet', walletRoutes);
router.use('/notifications', notificationRoutes);
router.use('/admin', adminRoutes);

module.exports = router;
