const { sequelize } = require('../config/database');
const UserModel = require('./users');
const SessionModel = require('./sessions');
const WeaponModel = require('./weapons');
const ShotModel = require('./shots');
const TargetModel = require('./targets');

const User = UserModel(sequelize);
const Session = SessionModel(sequelize);
const Weapon = WeaponModel(sequelize);
const Shot = ShotModel(sequelize);
const Target = TargetModel(sequelize);

// Define associations
User.hasMany(Session);
Session.belongsTo(User);

User.hasMany(Weapon);
Weapon.belongsTo(User);

Session.hasMany(Shot);
Shot.belongsTo(Session);

User.hasMany(Target);
Target.belongsTo(User);

Session.belongsTo(Weapon);
Weapon.hasMany(Session);

Session.belongsTo(Target);
Target.hasMany(Session);

module.exports = {
  sequelize,
  User,
  Session,
  Weapon,
  Shot,
  Target
};