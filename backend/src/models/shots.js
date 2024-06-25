const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Shot = sequelize.define('Shot', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    score: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    xCoordinate: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    yCoordinate: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    timestamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    timestamps: true,
    tableName: 'shots'
  });

  return Shot;
};