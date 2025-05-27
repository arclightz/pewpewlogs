// backend/seed.js

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs'); // For hashing user passwords


// Import your Mongoose models
const User = require('./src/models/users');
const Weapon = require('./src/models/weapons');
const ShootingRange = require('./src/models/shootingRanges');
const Session = require('./src/models/sessions');

// MongoDB Connection URI (ensure this matches your docker-compose.yml)
const dbURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/pewpewlogs';

const seedDB = async () => {
    try {
        await mongoose.connect(dbURI);
        console.log('MongoDB Connected for seeding...');

        // --- Clear existing data (optional, but good for fresh seeds) ---
        console.log('Clearing existing data...');
        await User.deleteMany({});
        await Weapon.deleteMany({});
        await ShootingRange.deleteMany({});
        await Session.deleteMany({});
        console.log('Existing data cleared.');

        // --- Create Sample User ---
        console.log('Creating sample user...');
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash('password123', salt); // Use a strong password

        const adminUser = await User.create({
            name: 'Testi Käyttäjä',
            email: 'testi@example.com',
            password: hashedPassword,
        });
        console.log(`Sample user created: ${adminUser.email} (ID: ${adminUser._id})`);

        // --- Create Sample Weapons for the User ---
        console.log('Creating sample weapons...');
        const weapon1 = await Weapon.create({
            userId: adminUser._id,
            name: 'Glock 17',
            type: 'Pistooli', // Must match enum in backend/src/models/weapons.js
            caliber: '9mm',
            erva: false,
            purchaseDate: new Date('2020-01-15'),
            notes: 'Luotettava harjoitusase.'
        });

        const weapon2 = await Weapon.create({
            userId: adminUser._id,
            name: 'AR-15 (Custom)',
            type: 'Kivääri', // Must match enum
            caliber: '.223 Rem (5.56x45mm)',
            erva: true,
            purchaseDate: new Date('2022-03-10'),
            notes: 'Kilpailukäyttöön rakennettu.'
        });

        const weapon3 = await Weapon.create({
            userId: adminUser._id,
            name: 'Remington 870',
            type: 'Haulikko', // Must match enum
            caliber: '12 Gauge',
            erva: false,
            purchaseDate: new Date('2019-07-20'),
            notes: 'Luotettava pumppuhaulikko.'
        });
        console.log('Sample weapons created.');

        // --- Create Sample Shooting Ranges ---
        console.log('Creating sample shooting ranges...');
        const range1 = await ShootingRange.create({
            userId: adminUser._id,
            name: 'Keski-Suomen Ampujat ry - Ampumarata',
            address: 'Ampumaradantie 14, 41310 Laukaa',
            location: { type: 'Point', coordinates: [25.8193169, 62.3089343] }, // [lng, lat]
            notes: 'Hyvät radat, sisä- ja ulkoalueet.',
            website: 'http://www.ksary.net',
            phoneNumber: '+358 400 649 621'
        });

        const range2 = await ShootingRange.create({
            userId: adminUser._id,
            name: 'Jyväskylän Ampujat - Ilma-aserata',
            address: 'Vasarakatu 9, 40320 Jyväskylä',
            location: { type: 'Point', coordinates: [25.7766, 62.2536] }, // [lng, lat]
            notes: 'Sisärata ilma-aseille.',
            website: 'http://www.jyvaskylanampujat.fi',
            phoneNumber: '010 123 4567'
        });
        console.log('Sample shooting ranges created.');

        // --- Create Sample Sessions ---
        console.log('Creating sample sessions...');
        await Session.create({
            userId: adminUser._id,
            date: new Date('2025-05-20'),
            range: range1._id,
            weapon: weapon1._id,
            numberOfShotsFired: 100,
            type: 'Harjoitus',
            sportType: 'Practical',
            role: 'Ampuja',
            weather: 'Aurinkoinen, +18°C',
            ammunitionType: '9mm',
            ammunitionCount: 100,
            distanceToTarget: 25,
            hits: 90,
            misses: 10,
            notes: 'Hyvä päivä, parannusta nopeudessa.',
            result: '90/100',
            hitFactor: 2.15,
            compScore: 85.5,
        });

        await Session.create({
            userId: adminUser._id,
            date: new Date('2025-05-22'),
            range: range1._id,
            weapon: weapon2._id,
            numberOfShotsFired: 50,
            type: 'Kilpailu',
            sportType: 'SRA',
            role: 'Ampuja',
            weather: 'Pilvinen, +15°C',
            ammunitionType: '.223 Rem (5.56x45mm)',
            ammunitionCount: 50,
            distanceToTarget: 100,
            hits: 45,
            misses: 5,
            notes: 'Kilpailu meni odotetusti.',
            result: '45/50',
            hitFactor: 1.8,
            compScore: 78.2,
        });

        await Session.create({
            userId: adminUser._id,
            date: new Date('2025-05-25'),
            range: range2._id,
            weapon: weapon3._id,
            numberOfShotsFired: 25,
            type: 'Kuivaharjoittelu',
            sportType: 'Skeet',
            role: 'Ampuja',
            weather: null,
            ammunitionType: null,
            ammunitionCount: 0,
            distanceToTarget: null,
            hits: null,
            misses: null,
            notes: 'Harjoittelin asennon vaihtoa.',
            result: null,
            hitFactor: null,
            compScore: null,
        });
        console.log('Sample sessions created.');

    } catch (err) {
        console.error('Error seeding database:', err);
        process.exit(1);
    } finally {
        mongoose.connection.close();
        console.log('MongoDB connection closed.');
    }
};

seedDB();
