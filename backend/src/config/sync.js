sequelize.sync({ alter: true }).then(() => {
    console.log("Database & tables updated!");
  });
  
  