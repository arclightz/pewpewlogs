const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Weapon = sequelize.define('Weapon', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    type: {
      type: DataTypes.STRING,
      allowNull: false
    },
    caliber: {
      type: DataTypes.STRING,
      allowNull: true
    },
    erva: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      unique: false
    },
    purchaseDate: {
      type: DataTypes.DATE,
      allowNull: true
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    timestamps: true,
    tableName: 'weapons'
  });

  return Weapon;
};