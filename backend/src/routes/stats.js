const express = require('express');
const router = express.Router();
const { authenticateUser } = require('../middleware/auth');
const { Session, Shot, Weapon } = require('../models');
const { Op } = require('sequelize');

router.use(authenticateUser);

// Get overall statistics for the user
router.get('/overall', async (req, res) => {
  try {
    const totalSessions = await Session.count({ where: { userId: req.user.id } });
    const totalShots = await Shot.count({
      include: [{
        model: Session,
        where: { userId: req.user.id }
      }]
    });
    const averageScore = await Shot.findOne({
      attributes: [[Session.sequelize.fn('AVG', Session.sequelize.col('score')), 'averageScore']],
      include: [{
        model: Session,
        where: { userId: req.user.id }
      }]
    });

    res.json({
      totalSessions,
      totalShots,
      averageScore: averageScore.getDataValue('averageScore')
    });
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving overall statistics', error: error.message });
  }
});

// Get statistics for a specific date range
router.get('/range', async (req, res) => {
  const { startDate, endDate } = req.query;
  try {
    const sessions = await Session.findAll({
      where: {
        userId: req.user.id,
        date: {
          [Op.between]: [new Date(startDate), new Date(endDate)]
        }
      },
      include: [{ model: Shot }, { model: Weapon }]
    });

    // Calculate statistics from the sessions
    // This is a simplified example. You might want to add more complex calculations.
    const statistics = sessions.map(session => ({
      date: session.date,
      weapon: session.Weapon.name,
      totalShots: session.Shots.length,
      averageScore: session.Shots.reduce((sum, shot) => sum + shot.score, 0) / session.Shots.length
    }));

    res.json(statistics);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving range statistics', error: error.message });
  }
});

// Get statistics for a specific weapon
router.get('/weapon/:weaponId', async (req, res) => {
  try {
    const weapon = await Weapon.findOne({
      where: { id: req.params.weaponId, userId: req.user.id }
    });
    if (!weapon) {
      return res.status(404).json({ message: 'Weapon not found' });
    }

    const sessions = await Session.findAll({
      where: { userId: req.user.id, WeaponId: req.params.weaponId },
      include: [{ model: Shot }]
    });

    const statistics = {
      weaponName: weapon.name,
      totalSessions: sessions.length,
      totalShots: sessions.reduce((sum, session) => sum + session.Shots.length, 0),
      averageScore: sessions.reduce((sum, session) => 
        sum + session.Shots.reduce((shotSum, shot) => shotSum + shot.score, 0), 0
      ) / sessions.reduce((sum, session) => sum + session.Shots.length, 0)
    };

    res.json(statistics);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving weapon statistics', error: error.message });
  }
});

module.exports = router;