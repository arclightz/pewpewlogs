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
      allowNull: false
    },
    purchaseDate: {
      type: DataTypes.DATE,
      allowNull: true
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    userId: {
      type: DataTypes.INTEGER,  
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      }
    }
  }, {
    timestamps: true,
    tableName: 'weapons'
  });

  Weapon.associate = (models) => {
    Weapon.belongsTo(models.User, { 
      foreignKey: 'userId', 
      as: 'owner',
      constraints: false
    });
  };

  return Weapon;
};